import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  bool _pageSwitch = false;
  late FriendsViewmodel _viewModel;
  late UserModel _currentUser;

  // ignore: prefer_function_declarations_over_variables
  final _buttonStyle = (pageSwitch, pageIndex) {
    return pageIndex == 1
        ? (pageSwitch
            ? ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            )
            : ElevatedButton.styleFrom(
              backgroundColor: null,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ))
        : (pageSwitch
            ? ElevatedButton.styleFrom(
              backgroundColor: null,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            )
            : ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ));
  };

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<FriendsViewmodel>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    var authService = Provider.of<AuthService>(context, listen: false);

    _currentUser =
        await authService.getUserById(authService.currentUser!.id) as UserModel;

    if (mounted) {
      await _viewModel.fetchFriendsAndRequests(_currentUser.userId, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsViewmodel>(
      builder: (context, vmodel, child) {
        if (vmodel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  "Something went wrong",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    vmodel.errorMessage ?? 'Unknown error',
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(onPressed: _loadData, child: Text("Try Again")),
              ],
            ),
          );
        }
        return Scaffold(
          floatingActionButton: SizedBox(
            height: 50,
            width: 50,
            child: FloatingActionButton(
              onPressed: () async {
                Dialog addAFriend = Dialog(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Add a friend",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Enter the email of the person you want to add",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          SearchAnchor.bar(
                            barHintText: "Search by email",
                            viewConstraints: const BoxConstraints(
                              maxHeight: 300,
                            ),
                            suggestionsBuilder: (
                              BuildContext context,
                              SearchController controller,
                            ) async {
                              var searchResults =
                                  await Provider.of<AuthService>(
                                    context,
                                    listen: false,
                                  ).searchUsers(controller.value.text);
                              return searchResults.map(
                                (user) => ListTile(
                                  title: Text(
                                    '${user.firstName} ${user.lastName}',
                                  ),
                                  subtitle: Text(user.email ?? ''),
                                  onTap: () {
                                    controller.closeView('${user.email}');
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text(
                                              'Do you really want to add ${user.firstName} ${user.lastName} as a friend?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _viewModel.sendFriendRequest(
                                                    _currentUser.userId,
                                                    user.userId,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Friend request sent!',
                                                      ),
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Yes'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                showDialog(builder: (_) => addAFriend, context: context);
                await _loadData();
              },
              mini: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
              ),
              backgroundColor: Colors.purple,
              child: const Icon(
                Icons.person_add,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: _buttonStyle(_pageSwitch, 0),
                        onPressed:
                            () => setState(() => _pageSwitch = !_pageSwitch),
                        child: Text(
                          'My Friends',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 15),
                      ElevatedButton(
                        style: _buttonStyle(_pageSwitch, 1),
                        onPressed:
                            () => setState(() => _pageSwitch = !_pageSwitch),
                        child: Text(
                          'Friend Requests',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Expanded(
                  child:
                      vmodel.isBusy
                          ? const Center(child: CircularProgressIndicator())
                          : _pageSwitch
                          ? ListView(
                            children: [
                              const ListTile(
                                title: Text(
                                  'Pending Requests',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              for (var entry in vmodel.pendingRequests.entries)
                                ListTile(
                                  leading: Icon(Icons.person, size: 32),

                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.value!.firstName} ${entry.value!.lastName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        entry.value!.email ?? '',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        iconSize: 25,
                                        icon: const Icon(Icons.check),
                                        onPressed: () async {
                                          await _viewModel.acceptFriendRequest(
                                            entry.key.friendshipId,
                                          );
                                          await _loadData();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'You and ${entry.value!.firstName} ${entry.value!.lastName} are now friends!',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        iconSize: 25,
                                        icon: const Icon(Icons.close),
                                        onPressed: () async {
                                          await _viewModel.rejectFriendRequest(
                                            entry.key.friendshipId,
                                          );
                                          await _loadData();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'You have rejected ${entry.value!.firstName} ${entry.value!.lastName}\'s friend request.',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )
                          : ListView(
                            children: [
                              for (var friendship in vmodel.friends.keys)
                                ListTile(
                                  leading: Icon(Icons.account_circle, size: 32),
                                  title: Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    '${vmodel.friends[friendship]?.firstName} ${vmodel.friends[friendship]?.lastName}',
                                  ),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'since ',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        TextSpan(
                                          text: friendship.createdAt,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
