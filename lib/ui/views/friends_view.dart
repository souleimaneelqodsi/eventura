import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';
import 'package:eventura/ui/shared/app_colors.dart';
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
      backgroundColor: AppColors.secondaryGrey,
      foregroundColor: AppColors.onSecondaryGrey,
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

  Widget _buildUserListTile({
    required UserModel user,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[300],
        backgroundImage:
            (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                ? NetworkImage(user.profilePicture!)
                : null,
        child:
            (user.profilePicture == null || user.profilePicture!.isEmpty)
                ? Icon(Icons.person, size: 24, color: Colors.grey[700])
                : null,
      ),
      title: Text(
        '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        user.email,
        style: TextStyle(
          color: AppColors.onSecondaryGreyVariant,
          fontStyle: FontStyle.italic,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing,
    );
  }

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
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
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
                            viewBackgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            viewElevation: 4.0,
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

                                return searchResults
                                    .map(
                                      (user) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 8.0,
                                              ),
                                          title: Text(
                                            '${user.firstName} ${user.lastName}',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
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
                                                        onPressed: () async {
                                                          await _viewModel
                                                              .sendFriendRequest(
                                                                _currentUser
                                                                    .userId,
                                                                user.userId,
                                                              );
                                                          if (!_viewModel
                                                              .hasError) {
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
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'An error occurred while sending the friend request: ${_viewModel.errorMessage}',
                                                                ),
                                                              ),
                                                            );
                                                            _viewModel.setError(
                                                              null,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          }
                                                        },
                                                        child: Text('Yes'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Text('No'),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                    .toList();
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
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: _buttonStyle(_pageSelect, 0),
                          onPressed:
                              () => setState(() => _pageSelect = Page.friends),
                          child: Text('My Friends'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: _buttonStyle(_pageSelect, 1),
                          onPressed:
                              () => setState(() => _pageSelect = Page.received),
                          child: Text('Received Requests'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: _buttonStyle(_pageSelect, 2),
                          onPressed:
                              () => setState(() => _pageSelect = Page.sent),
                          child: Text('Sent Requests'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Expanded(
                  child:
                      vmodel.isBusy &&
                              !vmodel.hasError &&
                              (vmodel.friends.isNotEmpty ||
                                  vmodel.pendingRequestsReceived.isNotEmpty ||
                                  vmodel.pendingRequestsSent.isNotEmpty)
                          ? const Center(child: CircularProgressIndicator())
                          : _pageSelect == Page.received
                          ? ListView(
                            children: [
                              ListTile(
                                title: Text(
                                  'Pending Requests',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              for (var entry
                                  in vmodel.pendingRequestsReceived.entries)
                                _buildUserListTile(
                                  user: entry.value!,
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
                              if (vmodel.pendingRequestsReceived.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "No pending requests received.",
                                    ),
                                  ),
                                ),
                            ],
                          )
                          : _pageSelect == Page.friends
                          ? ListView(
                            children: [
                              ListTile(
                                title: Text(
                                  'Friends',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              for (var friendship in vmodel.friends.keys)
                                _buildUserListTile(
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
                                  user: vmodel.friends[friendship]!,
                                  trailing: IconButton(
                                    icon: Icon(Icons.close, size: 24),
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
                                                          : Text(
                                                            'Yes',
                                                            style: TextStyle(
                                                              color:
                                                                  AppColors
                                                                      .errorRed,
                                                            ),
                                                          ),
                                                  onPressed: () async {
                                                    await vmodel.deleteFriend(
                                                      friendship,
                                                    );
                                                    Navigator.pop(context);

                                                    if (_viewModel.hasError) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Error: ${_viewModel.errorMessage!}",
                                                          ),
                                                        ),
                                                      );
                                                    } else {
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
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                              ),
                                            ),
                                      );
                                    },
                                  ),
                                ),
                              SizedBox(height: 10),
                              if (vmodel.friends.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "You haven't added any friends yet.",
                                    ),
                                  ),
                                ),
                            ],
                          )
                          : ListView(
                            children: [
                              ListTile(
                                title: Text(
                                  'Sent Requests',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              for (var entry
                                  in vmodel.pendingRequestsSent.entries)
                                _buildUserListTile(
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
                                  user: entry.value!,
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
                              if (vmodel.pendingRequestsSent.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("No friend requests sent."),
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
