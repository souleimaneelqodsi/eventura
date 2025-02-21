import 'package:eventura/core/services/message_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class MessagesListViewmodel extends BaseViewModel {
  MessagesListViewmodel({required this.messageService});

  final MessageService messageService;

}