import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';
import 'package:eventura/ui/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

enum Page { friends, received, sent }

class _FriendsViewState extends State<FriendsView> {
  Page _pageSelect = Page.friends;
  late FriendsViewmodel _viewModel;
  late UserModel _currentUser;

  final _buttonStyle = (pageSwitch, pageIndex) {
    final selected = ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    );
    final unselected = ElevatedButton.styleFrom(
      backgroundColor: null,
      foregroundColor: Colors.black,
    );
    switch (pageSwitch) {
      case Page.friends:
        if (pageIndex == 0) {
          return selected;
        }
        return unselected;
      case Page.received:
        if (pageIndex == 1) {
          return selected;
        }
        return unselected;
      case Page.sent:
        if (pageIndex == 2) {
          return selected;
        }
        return unselected;
    }
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
                              if (controller.value.text.isEmpty) {
                                return [
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text("Type an email to search"),
                                    ),
                                  ),
                                ];
                              }

                              try {
                                var searchResults =
                                    await Provider.of<AuthService>(
                                      context,
                                      listen: false,
                                    ).searchUsers(controller.value.text);

                                searchResults =
                                    searchResults.where((user) {
                                      if (user.userId == _currentUser.userId) {
                                        return false;
                                      }

                                      for (var friend
                                          in vmodel.friends.values) {
                                        if (friend?.userId == user.userId) {
                                          return false;
                                        }
                                      }

                                      for (var pending
                                          in vmodel
                                              .pendingRequestsReceived
                                              .values) {
                                        if (pending?.userId == user.userId) {
                                          return false;
                                        }
                                      }

                                      return true;
                                    }).toList();

                                if (searchResults.isEmpty) {
                                  return [
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "No users found or all users are already in your network",
                                        ),
                                      ),
                                    ),
                                  ];
                                }

                                return searchResults.map(
                                  (user) => ListTile(
                                    title: Text(
                                      '${user.firstName} ${user.lastName}',
                                    ),
                                    subtitle: Text(user.email),
                                    onTap: () {
                                      controller.closeView(user.email);
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
                                                    _viewModel
                                                        .sendFriendRequest(
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
                                                    _loadData();
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('No'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                );
                              } catch (e) {
                                if (e.toString().contains(
                                  "Search failed: no data returned",
                                )) {
                                  return [
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text("No users found"),
                                      ),
                                    ),
                                  ];
                                } else {
                                  rethrow;
                                }
                              }
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
                        style: _buttonStyle(_pageSelect, 0),
                        onPressed:
                            () => setState(() => _pageSelect = Page.friends),
                        child: Text(
                          'My Friends',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 15),
                      ElevatedButton(
                        style: _buttonStyle(_pageSelect, 1),
                        onPressed:
                            () => setState(() => _pageSelect = Page.received),
                        child: Text(
                          'Received Requests',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 15),
                      ElevatedButton(
                        style: _buttonStyle(_pageSelect, 2),
                        onPressed:
                            () => setState(() => _pageSelect = Page.sent),
                        child: Text(
                          'Sent Requests',
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
                          : _pageSelect == Page.received
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
                              for (var entry
                                  in vmodel.pendingRequestsReceived.entries)
                                ListTile(
                                  onTap: () {
                                    final friendUserId =
                                        vmodel
                                            .pendingRequestsReceived[entry.key]!
                                            .userId;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProfileView(
                                              fromHome: false,
                                              userId: friendUserId,
                                            ),
                                      ),
                                    );
                                  },
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
                                        entry.value!.email,
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
                              SizedBox(height: 10),
                            ],
                          )
                          : _pageSelect == Page.friends
                          ? ListView(
                            children: [
                              const ListTile(
                                title: Text(
                                  'Friends',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              for (var friendship in vmodel.friends.keys)
                                ListTile(
                                  onTap: () {
                                    final friendUserId =
                                        vmodel.friends[friendship]!.userId;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProfileView(
                                              fromHome: false,
                                              userId: friendUserId,
                                            ),
                                      ),
                                    );
                                  },
                                  leading: Icon(Icons.account_circle, size: 32),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, size: 24),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              actions: [
                                                TextButton(
                                                  child:
                                                      vmodel.isBusy
                                                          ? CircularProgressIndicator()
                                                          : Text('Yes'),
                                                  onPressed: () async {
                                                    await vmodel.deleteFriend(
                                                      friendship,
                                                    );
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                    }

                                                    if (_viewModel.hasError) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            content: Text(
                                                              "Error: ${_viewModel.errorMessage!}",
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Friend deleted: ${vmodel.friends[friendship]!.firstName} ${vmodel.friends[friendship]!.lastName}',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    }
                                                    _loadData();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('No'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                              content: Text(
                                                'Are you sure you want to delete this friend?',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                      );
                                    },
                                  ),
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
                              SizedBox(height: 10),
                            ],
                          )
                          : ListView(
                            children: [
                              const ListTile(
                                title: Text(
                                  'Sent Requests',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              for (var entry
                                  in vmodel.pendingRequestsSent.entries)
                                ListTile(
                                  onTap: () {
                                    final friendUserId =
                                        vmodel
                                            .pendingRequestsSent[entry.key]!
                                            .userId;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProfileView(
                                              fromHome: false,
                                              userId: friendUserId,
                                            ),
                                      ),
                                    );
                                  },
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
                                        entry.value!.email,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    iconSize: 25,
                                    icon: const Icon(Icons.close),
                                    onPressed: () async {
                                      await _viewModel.cancelFriendRequest(
                                        entry.value!.userId,
                                      );
                                      if (_viewModel.hasError) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                "Error cancelling friend request: ${_viewModel.errorMessage}",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'You have cancelled your friend request to ${entry.value!.firstName} ${entry.value!.lastName}.',
                                            ),
                                          ),
                                        );
                                      }
                                      _loadData();
                                    },
                                  ),
                                ),
                              SizedBox(height: 10),
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
