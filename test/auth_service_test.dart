import 'package:flutter_test/flutter_test.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';


void main() {
  late SupabaseClient mockSupabase;
  late MockSupabaseHttpClient mockHttpClient;

setUpAll(() {
  mockHttpClient = MockSupabaseHttpClient();
  mockSupabase = SupabaseClient(
    'https://mock.supabase.co',
    'fake_anon_key',
    httpClient: mockHttpClient,
  );
});

  tearDown(() => mockHttpClient.reset());

  group('AuthService Tests', () {
    test('getUserById returns UserModel when user exists', () async {
      // Insert mock user
      await mockSupabase.from('users').insert({
        'user_id': 'test_id',
        'email': 'test@example.com',
      });

      final authService = AuthService(supabaseClient: mockSupabase);
      final user = await authService.getUserById('test_id');
      
      expect(user, isA<UserModel>());
      expect(user?.userId, 'test_id');
      expect(user?.email, 'test@example.com');
    });

    test('getUserById returns null when user does not exist', () async {
      final authService = AuthService(supabaseClient: mockSupabase);
      final user = await authService.getUserById('non_existent_id');
      expect(user, isNull);
    });

    test('createUser returns UserModel on success', () async {
      final authService = AuthService(supabaseClient: mockSupabase);
      final user = UserModel(userId: 'test_id', email: 'test@example.com');
      
      final createdUser = await authService.createUser(user);
      
      expect(createdUser, isA<UserModel>());
      expect(createdUser?.userId, 'test_id');
      
      // Verify the user was created
      final users = await mockSupabase.from('users').select();
      expect(users.length, 1);
    });

    test('updateUser returns updated UserModel', () async {
      // Insert initial user
      await mockSupabase.from('users').insert({
        'user_id': 'test_id',
        'email': 'old@example.com',
      });

      final authService = AuthService(supabaseClient: mockSupabase);
      final updatedUser = await authService.updateUser(
        UserModel(userId: 'test_id', email: 'new@example.com'),
      );

      expect(updatedUser, isA<UserModel>());
      expect(updatedUser?.email, 'new@example.com');

      // Verify the update
      final users = await mockSupabase.from('users').select();
      expect(users[0]['email'], 'new@example.com');
    });

    test('deleteUser removes user', () async {
      // Insert a user to delete
      await mockSupabase.from('users').insert({
        'user_id': 'test_id',
        'email': 'test@example.com',
      });

      final authService = AuthService(supabaseClient: mockSupabase);
      await authService.deleteUser('test_id');

      // Verify deletion
      final users = await mockSupabase.from('users').select();
      expect(users.isEmpty, true);
    });
  });
}