import 'package:eventura/core/services/event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class CreateEventViewmodel extends BaseViewModel {
  CreateEventViewmodel({required this.eventService});

  final EventService eventService;


}