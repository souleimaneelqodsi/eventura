import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class EventsListViewmodel extends BaseViewModel {
  EventsListViewmodel({required this.eventService});

  final EventService eventService;


}