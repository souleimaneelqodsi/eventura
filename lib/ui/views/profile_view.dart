import 'package:eventura/core/viewmodels/profile_viewmodel.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  final String? userId;
  const ProfileView({super.key, this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late ProfileViewmodel viewmodel;

  @override
  void initState() {
    super.initState();
    viewmodel = ProfileViewmodel(
      userService: context.read(),
      userId: widget.userId,
    );
    viewmodel.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: AnimatedBuilder(
        animation: viewmodel,
        builder: (context, _) {
          if (viewmodel.isBusy) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewmodel.hasError) {
            return Center(child: Text('Erreur : ${viewmodel.errorMessage}'));
          } else if (viewmodel.user == null) {
            return const Center(child: Text('Utilisateur introuvable'));
          }

          final user = viewmodel.user!;
          final currentUserId = context.read<ProfileViewmodel>().userService.currentUser?.id;
          final isCurrentUser = user.userId != null && user.userId == currentUserId;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.firstName} ${user.lastName}', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                if (isCurrentUser)
                  ElevatedButton(
                    onPressed: () {
                      // Naviguer vers la page de modification du profil
                    },
                    child: const Text("Modifier le profil"),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                     context.read<FriendsViewmodel>().sendFriendRequest(user.userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Demande d'ami envoyée")),
                      );
                    },
                    child: const Text("Ajouter comme ami"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
