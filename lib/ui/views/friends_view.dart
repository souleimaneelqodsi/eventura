import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  late FriendsViewmodel _viewModel;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<FriendsViewmodel>();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';// Récupère l'ID utilisateur
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.fetchFriendsAndRequests(_currentUserId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _viewModel.busy;
    final friends = _viewModel.friends;
    final pendingRequests = _viewModel.pendingRequests;

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: isBusy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // --- Pending requests ---
                const ListTile(title: Text('Pending Requests')),
                for (var req in pendingRequests)
                  ListTile(
                    title: Text('Demande de: ${req['requestor_id']}'),
                    subtitle: Text('Status: ${req['status']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () async {
                            await _viewModel.acceptFriendRequest(req['id']);
                            await _loadData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            await _viewModel.rejectFriendRequest(req['id']);
                            await _loadData();
                          },
                        ),
                      ],
                    ),
                  ),
                const Divider(), // Ligne de séparation
                // --- Accepted friends ---
                const ListTile(title: Text('My Friends')),
                for (var friend in friends) // Boucle sur les amis
                  ListTile(
                    title: Text(
                      friend['requestor_id'] == _currentUserId
                          ? friend['receiver_id']
                          : friend['requestor_id'],
                    ),
                    subtitle: Text('Status: ${friend['status']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.block),
                      onPressed: () async {
                        await _viewModel.blockUser(friend['id']);
                        await _loadData();
                      },
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Envoyer une demande en dur pour tester
          const anotherUserId = 'ID_D_AUTRE_UTILISATEUR';
          await _viewModel.sendFriendRequest(_currentUserId, anotherUserId);
          await _loadData();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
