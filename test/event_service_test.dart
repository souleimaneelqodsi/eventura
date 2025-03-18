import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';

void main() {
  late SupabaseClient mockSupabase;
  late MockSupabaseHttpClient mockHttpClient;
  late EventService eventService;

  final testEvent = Event(
    eventId: 1,
    organizerId: 'test_organizer_123',
    dateOfBeginning: DateTime(2025, 4, 1, 18, 0),
    title: 'Test Event',
    description: 'This is a test event',
    location: 'Test Location',
    capacity: 100,
    isPrivate: false,
    coverPicture: 'https://example.com/image.jpg',
  );

  final testEventJson = {
    'event_id': 1,
    'organizer_id': 'test_organizer_123',
    'date_of_beginning': DateTime(2025, 4, 1, 18, 0).toIso8601String(),
    'title': 'Test Event',
    'description': 'This is a test event',
    'location': 'Test Location',
    'capacity': 100,
    'is_private': false,
    'cover_picture': 'https://example.com/image.jpg',
  };

  setUp(() {
    mockHttpClient = MockSupabaseHttpClient();
    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fake_anon_key',
      httpClient: mockHttpClient,
    );
    eventService = EventService(supabaseClient: mockSupabase);
  });

  tearDown(() => mockHttpClient.reset());

  group('EventService Tests', () {
    group('getEventById', () {
      test('returns Event when event exists', () async {
        await mockSupabase.from('events').insert(testEventJson);

        try {
          final retrievedEvent = await eventService.getEventById(1);

          expect(retrievedEvent, isA<Event>());
          expect(retrievedEvent?.eventId, 1);
          expect(retrievedEvent?.title, 'Test Event');
        } catch (e) {
          fail("Test failed due to mock implementation: $e");
        }
      });

      test('throws Exception when event does not exist', () async {
        expectLater(
          () async => await eventService.getEventById(999),
          throwsException,
        );
      });
    });

    group('getAllEvents', () {
      test('returns empty list when no events exist', () async {
        final events = await eventService.getAllEvents();
        expect(events, isA<List<Event>>());
        expect(events.isEmpty, true);
      });

      test('returns all events when they exist', () async {
        await mockSupabase.from('events').insert([
          testEventJson,
          {
            'event_id': 2,
            'organizer_id': 'test_organizer_456',
            'date_of_beginning':
                DateTime(2025, 5, 15, 19, 30).toIso8601String(),
            'title': 'Second Test Event',
            'description': 'This is another test event',
            'location': 'Another Location',
            'capacity': 50,
            'is_private': true,
            'cover_picture': 'https://example.com/image2.jpg',
          },
        ]);

        final events = await eventService.getAllEvents();

        expect(events.length, 2);
        expect(events[0].eventId, 1);
        expect(events[1].eventId, 2);
        expect(events[1].title, 'Second Test Event');
      });
    });

    group('createEvent', () {
      test('returns created Event on success', () async {
        final newEvent = Event(
          organizerId: 'new_organizer_789',
          dateOfBeginning: DateTime(2025, 6, 20, 14, 0),
          title: 'New Event',
          description: 'This is a new event',
          location: 'New Location',
          capacity: 200,
          isPrivate: true,
        );

        final createdEvent = await eventService.createEvent(newEvent);

        expect(createdEvent, isA<Event>());
        expect(createdEvent?.title, 'New Event');
        expect(createdEvent?.organizerId, 'new_organizer_789');

        final events = await mockSupabase.from('events').select();
        expect(events.length, 1);
      });
    });

    group('updateEvent', () {
      test('returns updated Event on success', () async {
        await mockSupabase.from('events').insert(testEventJson);

        final updatedEvent = testEvent.copyWith(
          title: 'Updated Title',
          capacity: 150,
        );

        final result = await eventService.updateEvent(updatedEvent);

        expect(result, isA<Event>());
        expect(result?.eventId, 1);
        expect(result?.title, 'Updated Title');
        expect(result?.capacity, 150);

        final events = await mockSupabase.from('events').select();
        expect(events[0]['title'], 'Updated Title');
        expect(events[0]['capacity'], 150);
      });

      test('throws Exception when updating event without ID', () async {
        final eventWithoutId = Event(
          organizerId: 'organizer_id',
          dateOfBeginning: DateTime(2025, 6, 20),
          title: 'Test Event',
          description: 'Description',
          location: 'Location',
          capacity: 100,
          isPrivate: false,
        );

        expect(() => eventService.updateEvent(eventWithoutId), throwsException);
      });
    });

    group('deleteEvent', () {
      test('successfully deletes an event', () async {
        await mockSupabase.from('events').insert(testEventJson);

        var events = await mockSupabase.from('events').select();
        expect(events.length, 1);

        await eventService.deleteEvent(1);

        events = await mockSupabase.from('events').select();
        expect(events.isEmpty, true);
      });
    });

    test('getEventsStream returns a Stream of Event lists', () {
      final stream = eventService.getEventsStream();
      expect(stream, isA<Stream<List<Event>>>());
    });
  });
}
