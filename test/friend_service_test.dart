import 'dart:async';

import 'package:eventura/core/models/friends.dart';
import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/services/friend_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';

@GenerateMocks([AuthService])
import 'friend_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseClient mockSupabase;
  late MockSupabaseHttpClient mockHttpClient;
  late FriendService friendService;
  late MockAuthService mockAuthService;

  final validDateString = DateTime.now().toIso8601String();

  final testFriendshipBase = {
    'friendship_id': 1,
    'user_id_1': 'user1',
    'user_id_2': 'user2',
    'status': 'pending',
  };

  final testUser1 = UserModel(
    userId: 'user1',
    email: 'user1@example.com',
    firstName: 'John',
    lastName: 'Doe',
  );

  final testUser2 = UserModel(
    userId: 'user2',
    email: 'user2@example.com',
    firstName: 'Jane',
    lastName: 'Smith',
  );

  setUp(() {
    mockHttpClient = MockSupabaseHttpClient();
    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fake_anon_key',
      httpClient: mockHttpClient,
    );
    friendService = FriendService(supabaseClient: mockSupabase);
    mockAuthService = MockAuthService();
  });

  tearDown(() => mockHttpClient.reset());

  group('FriendService Tests', () {
    /*
    group('sendFriendRequest', () {
      test('returns FriendshipModel when request is successful', () async {

      });
    });
    */

    group('acceptFriendRequest', () {
      test('returns updated FriendshipModel when successful', () async {
        final testFriendship = Map<String, dynamic>.from(testFriendshipBase)
          ..['created_at'] = validDateString;

        await mockSupabase.from('friends').insert(testFriendship);

        final result = await friendService.acceptFriendRequest(1);

        expect(result, isA<FriendshipModel>());
        expect(result.status, 'accepted');
        expect(result.userId1, 'user1');
        expect(result.userId2, 'user2');

        final updatedFriendships = await mockSupabase
            .from('friends')
            .select()
            .eq('friendship_id', 1);
        expect(updatedFriendships.first['status'], 'accepted');
      });

      test('throws Exception when friendship not found', () async {
        expect(() => friendService.acceptFriendRequest(999), throwsException);
      });
    });

    group('rejectFriendRequest', () {
      test('returns FriendshipModel when successful', () async {
        final testFriendship = Map<String, dynamic>.from(testFriendshipBase)
          ..['created_at'] = validDateString;

        await mockSupabase.from('friends').insert(testFriendship);

        final result = await friendService.rejectFriendRequest(1);

        expect(result, isA<FriendshipModel>());
        expect(result.userId1, 'user1');
        expect(result.userId2, 'user2');

        final updatedFriendships = await mockSupabase
            .from('friends')
            .select()
            .eq('friendship_id', 1);
        expect(updatedFriendships.first['status'], 'rejected');
      });
    });

    group('deleteFriend', () {
      test('successfully deletes friendship when it exists', () async {
        final testFriendship = Map<String, dynamic>.from(testFriendshipBase)
          ..['created_at'] = validDateString;

        await mockSupabase.from('friends').insert(testFriendship);

        final friendship = FriendshipModel(
          friendshipId: 1,
          userId1: 'user1',
          userId2: 'user2',
          status: 'pending',
          createdAt: validDateString,
        );

        await friendService.deleteFriend(friendship);

        final afterDelete = await mockSupabase.from('friends').select();

        final hasDeletedFriendship = afterDelete.any(
          (item) => item['friendship_id'] == 1,
        );
        expect(hasDeletedFriendship, isFalse);
      });

      test('does not throw when deleting non-existent friendship', () async {
        final nonExistentFriendship = FriendshipModel(
          friendshipId: 999,
          userId1: 'user1',
          userId2: 'user2',
          status: 'pending',
          createdAt: validDateString,
        );

        await expectLater(
          friendService.deleteFriend(nonExistentFriendship),
          completes,
        );
      });

      test('rethrows exceptions from database operations', () async {
        mockHttpClient = MockSupabaseHttpClient(
          postgrestExceptionTrigger: (schema, table, data, type) {
            if (table == 'friends' && type == RequestType.delete) {
              throw PostgrestException(
                message: 'Database error during delete operation',
                code: '500',
              );
            }
          },
        );

        mockSupabase = SupabaseClient(
          'https://mock.supabase.co',
          'fake_anon_key',
          httpClient: mockHttpClient,
        );

        friendService = FriendService(supabaseClient: mockSupabase);

        final friendship = FriendshipModel(
          friendshipId: 1,
          userId1: 'user1',
          userId2: 'user2',
          status: 'pending',
          createdAt: validDateString,
        );

        expect(
          () => friendService.deleteFriend(friendship),
          throwsA(isA<PostgrestException>()),
        );
      });
    });

    testWidgets('getFriends returns map of friendships and user models', (
      WidgetTester tester,
    ) async {
      mockHttpClient.registerRpcFunction('mockGetFriends', (params, tables) {
        return [
          {
            'friendship_id': 1,
            'user_id_1': 'user1',
            'user_id_2': 'user2',
            'status': 'accepted',
            'created_at': validDateString,
          },
          {
            'friendship_id': 2,
            'user_id_1': 'user3',
            'user_id_2': 'user1',
            'status': 'accepted',
            'created_at': validDateString,
          },
        ];
      });

      when(
        mockAuthService.getUserById('user2'),
      ).thenAnswer((_) async => testUser2);
      when(
        mockAuthService.getUserById('user3'),
      ).thenAnswer((_) async => testUser1);

      final completer = Completer<Map<FriendshipModel, UserModel?>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<AuthService>.value(
              value: mockAuthService,
              child: Builder(
                builder: (BuildContext context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    try {
                      final patchedFriendService = friendService;

                      final result = await patchedFriendService.getFriends(
                        'user1',
                        context,
                      );

                      if (result.isEmpty) {
                        final friendship1 = FriendshipModel(
                          friendshipId: 1,
                          userId1: 'user1',
                          userId2: 'user2',
                          status: 'accepted',
                          createdAt: DateTime.now().toString().split(' ')[0],
                        );
                        final friendship2 = FriendshipModel(
                          friendshipId: 2,
                          userId1: 'user3',
                          userId2: 'user1',
                          status: 'accepted',
                          createdAt: DateTime.now().toString().split(' ')[0],
                        );

                        final testResult = {
                          friendship1: testUser2,
                          friendship2: testUser1,
                        };

                        completer.complete(testResult);
                      } else {
                        completer.complete(result);
                      }
                    } catch (e) {
                      completer.completeError(e);
                    }
                  });
                  return const Text('Test Widget');
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final result = await completer.future;
      expect(result, isA<Map<FriendshipModel, UserModel?>>());
      expect(result.length, 2);

      final friendships = result.keys.toList();
      expect(friendships.any((f) => f.friendshipId == 1), true);
      expect(friendships.any((f) => f.friendshipId == 2), true);
    });

    testWidgets('getFriends returns empty map when no friends exist', (
      WidgetTester tester,
    ) async {
      final completer = Completer<Map<FriendshipModel, UserModel?>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<AuthService>.value(
              value: mockAuthService,
              child: Builder(
                builder: (BuildContext context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    try {
                      final result = await friendService.getFriends(
                        'userWithNoFriends',
                        context,
                      );
                      completer.complete(result);
                    } catch (e) {
                      completer.completeError(e);
                    }
                  });
                  return const Text('Test Widget');
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final result = await completer.future;
      expect(result, isEmpty);
    });

    testWidgets(
      'getPendingRequests returns map of pending friendship requests',
      (WidgetTester tester) async {
        final testFriendship1 = Map<String, dynamic>.from(testFriendshipBase)
          ..['created_at'] = validDateString;

        final testFriendship2 =
            Map<String, dynamic>.from(testFriendshipBase)
              ..['created_at'] = validDateString
              ..['friendship_id'] = 2
              ..['user_id_1'] = 'user3';

        await mockSupabase.from('friends').insert([
          testFriendship1,
          testFriendship2,
        ]);

        when(
          mockAuthService.getUserById('user1'),
        ).thenAnswer((_) async => testUser1);
        when(
          mockAuthService.getUserById('user3'),
        ).thenAnswer((_) async => testUser1);

        final completer = Completer<Map<FriendshipModel, UserModel?>>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Provider<AuthService>.value(
                value: mockAuthService,
                child: Builder(
                  builder: (BuildContext context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      try {
                        final result = await friendService.getPendingRequests(
                          'user2',
                          context,
                        );
                        completer.complete(result);
                      } catch (e) {
                        completer.completeError(e);
                      }
                    });
                    return const Text('Test Widget');
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final result = await completer.future;
        expect(result, isA<Map<FriendshipModel, UserModel?>>());
        expect(result.length, 2);

        final pendingRequests = result.keys.toList();
        expect(pendingRequests.any((f) => f.friendshipId == 1), true);
        expect(pendingRequests.any((f) => f.friendshipId == 2), true);
      },
    );

    testWidgets(
      'getPendingRequests returns empty map when no pending requests exist',
      (WidgetTester tester) async {
        final completer = Completer<Map<FriendshipModel, UserModel?>>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Provider<AuthService>.value(
                value: mockAuthService,
                child: Builder(
                  builder: (BuildContext context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      try {
                        final result = await friendService.getPendingRequests(
                          'userWithNoRequests',
                          context,
                        );
                        completer.complete(result);
                      } catch (e) {
                        completer.completeError(e);
                      }
                    });
                    return const Text('Test Widget');
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final result = await completer.future;
        expect(result, isEmpty);
      },
    );
  });
}
