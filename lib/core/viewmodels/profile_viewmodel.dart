import 'package:eventura/core/services/supabase_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class ProfileViewmodel extends BaseViewModel {

  ProfileViewmodel({required this.userService, required this.userId});

  final SupabaseService userService;
  final String userId;

}