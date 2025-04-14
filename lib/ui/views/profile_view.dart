import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';
import 'package:eventura/core/viewmodels/profile_viewmodel.dart';
import 'package:eventura/ui/shared/is_editing_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends StatefulWidget {
  final String userId;
  final bool fromHome;

  const ProfileView({super.key, required this.userId, required this.fromHome});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Logger logger = Logger(printer: PrettyPrinter());
  late ProfileViewmodel viewmodel;
  bool isLoading = true;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();

    viewmodel = ProfileViewmodel(
      userId: widget.userId,
      userService: Provider.of<AuthService>(context, listen: false),
    );

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      await viewmodel.loadProfile();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error loading profile data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return Container();
    }

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (viewmodel.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${viewmodel.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (viewmodel.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 48),
              const SizedBox(height: 16),
              const Text('User profile not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final user = viewmodel.user!;
    final hasVerifiedEmail = viewmodel.hasVerifiedEmail!;
    final isCurrentUser = viewmodel.isCurrentUserProfile;

    isFriend() {
      if (!isCurrentUser) {
        return Provider.of<FriendsViewmodel>(
          context,
        ).friends.values.contains(user);
      }
      return false;
    }

    isIncomingRequest() {
      if (!isCurrentUser) {
        return Provider.of<FriendsViewmodel>(
          context,
        ).pendingRequestsReceived.values.contains(user);
      }
      return false;
    }

    isSentRequest() {
      if (!isCurrentUser) {
        return Provider.of<FriendsViewmodel>(
          context,
        ).pendingRequestsSent.values.contains(user);
      }
      return false;
    }

    if (!_controllersInitialized) {
      firstNameController.text = user.firstName ?? '';
      lastNameController.text = user.lastName ?? '';
      emailController.text = user.email;
      _controllersInitialized = true;
    }

    return ChangeNotifierProvider.value(
      value: viewmodel,
      child: Consumer<ProfileEditingState>(
        builder:
            (context, state, child) => Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: !widget.fromHome,
                actions:
                    !widget.fromHome && isCurrentUser
                        ? [
                          IconButton(
                            icon:
                                state.isEditing
                                    ? const Icon(Icons.check, size: 24)
                                    : const Icon(Icons.edit, size: 24),
                            onPressed: () {
                              state.toggleEditing();
                            },
                          ),
                        ]
                        : null,
                title: Text('${user.firstName} ${user.lastName}'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: (widget.fromHome ? 120 : 300),
                    ),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.account_circle, size: 100),
                        const SizedBox(height: 10),
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 30),
                        Consumer<ProfileEditingState>(
                          builder: (context, editingState, _) {
                            final isEditing = editingState.isEditing;

                            return Column(
                              children: [
                                TextField(
                                  controller: firstNameController,
                                  enabled: isEditing && isCurrentUser,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                TextField(
                                  controller: lastNameController,
                                  enabled: isEditing && isCurrentUser,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                TextField(
                                  controller: emailController,
                                  enabled: isEditing && isCurrentUser,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                if (isEditing && isCurrentUser)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                        horizontal: 30,
                                      ),
                                      backgroundColor: Colors.purple,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      if (!(emailController.text !=
                                              user.email ||
                                          firstNameController.text !=
                                              user.firstName ||
                                          lastNameController.text !=
                                              user.lastName)) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "No changes were made.",
                                            ),
                                          ),
                                        );
                                      } else {
                                        final updatedUser = user.copyWith(
                                          firstName: firstNameController.text,
                                          lastName: lastNameController.text,
                                          email: emailController.text,
                                        );

                                        await viewmodel.updateUser(updatedUser);
                                      }
                                      if (!viewmodel.hasError) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Profile updated"),
                                            ),
                                          );
                                          _loadData();
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Error updating profile : ${viewmodel.errorMessage}",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      editingState.toggleEditing();
                                    },
                                    child: const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        if (isCurrentUser && !hasVerifiedEmail)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.orange),
                                  SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      softWrap: true,
                                      "Your email isn’t verified. If you haven’t received a verification email, press the button below to resend it (link valid for ~50 minutes).",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                              SizedBox(height: 25),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 15,
                                  ),
                                ),
                                onPressed: () async {
                                  await viewmodel.resendVerificationEmail();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Verification email sent!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child:
                                    viewmodel.isBusy
                                        ? CircularProgressIndicator()
                                        : Text(
                                          'Resend Verification Email',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        SizedBox(height: 10),
                        if (!isCurrentUser &&
                            !isFriend() &&
                            isIncomingRequest())
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32.0,
                                    right: 32,
                                  ),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "You have received a friend request from this person",

                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          iconSize: 30,
                                          color: Colors.green,
                                          icon: Icon(Icons.check),
                                          onPressed: () async {
                                            await viewmodel.acceptFriendRequest(
                                              context,
                                            );
                                            if (viewmodel.hasError) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Text(
                                                      "Error accepting friend request. Please try again or contact support: ${viewmodel.errorMessage}",
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                await Provider.of<
                                                  FriendsViewmodel
                                                >(
                                                  context,
                                                  listen: false,
                                                ).fetchFriendsAndRequests(
                                                  viewmodel
                                                      .userService
                                                      .currentUser!
                                                      .id,
                                                  context,
                                                );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Friend request from ${user.firstName} ${user.lastName} accepted.",
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                        ),
                                        Text(
                                          "Accept",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          iconSize: 30,
                                          color: Colors.red,
                                          icon: Icon(Icons.close),
                                          onPressed: () async {
                                            await viewmodel.rejectFriendRequest(
                                              context,
                                            );
                                            if (viewmodel.hasError) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Text(
                                                      "Error rejecting friend request. Please try again or contact support: ${viewmodel.errorMessage}",
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                await Provider.of<
                                                  FriendsViewmodel
                                                >(
                                                  context,
                                                  listen: false,
                                                ).fetchFriendsAndRequests(
                                                  viewmodel
                                                      .userService
                                                      .currentUser!
                                                      .id,
                                                  context,
                                                );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Friend request from ${user.firstName} ${user.lastName} rejected.",
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                        ),
                                        Text(
                                          "Reject",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (!isCurrentUser && isFriend())
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 13,
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                              ),
                              child:
                                  viewmodel.isBusy
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : SizedBox(
                                        width: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,

                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5.0),
                                            const Text(
                                              "Delete friend",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              onPressed: () async {
                                final alert = AlertDialog(
                                  title: Text(
                                    textAlign: TextAlign.center,
                                    "Do you really want to delete this friend?",
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () async {
                                        await viewmodel.deleteFriend(context);

                                        if (viewmodel.hasError) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  "Error deleting friend. Please try again or contact support: ${viewmodel.errorMessage}",
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (context.mounted) {
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              await Provider.of<
                                                FriendsViewmodel
                                              >(
                                                context,
                                                listen: false,
                                              ).fetchFriendsAndRequests(
                                                viewmodel
                                                    .userService
                                                    .currentUser!
                                                    .id,
                                                context,
                                              );
                                            }
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Friend deleted: ${user.firstName} ${user.lastName}",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        "No",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                                showDialog(
                                  builder: (context) => alert,
                                  context: context,
                                );
                              },
                            ),
                          ),
                        if (!isCurrentUser &&
                            !isFriend() &&
                            !isIncomingRequest() &&
                            !isSentRequest())
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 13,
                                ),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                await viewmodel.addFriend(context);
                                if (viewmodel.hasError) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          "Error adding friend: an error occurred or this person is already your friend: ${viewmodel.errorMessage}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Friend request sent successfully!",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child:
                                  viewmodel.isBusy
                                      ? const CircularProgressIndicator()
                                      : SizedBox(
                                        width: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,

                                          children: [
                                            Icon(Icons.person_add),
                                            SizedBox(width: 5.0),
                                            const Text(
                                              "Add as friend",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                          ),
                        if (!isCurrentUser &&
                            !isIncomingRequest() &&
                            !isFriend() &&
                            isSentRequest())
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32.0,
                                    right: 32,
                                  ),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "You have sent a friend request to this person",

                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      iconSize: 30,
                                      icon: Icon(Icons.close),
                                      onPressed: () async {
                                        await viewmodel.cancelFriendRequest(
                                          context,
                                        );
                                        if (viewmodel.hasError) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  "Error canceling friend request. Please try again or contact support: ${viewmodel.errorMessage}",
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            await Provider.of<FriendsViewmodel>(
                                              context,
                                              listen: false,
                                            ).fetchFriendsAndRequests(
                                              viewmodel
                                                  .userService
                                                  .currentUser!
                                                  .id,
                                              context,
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Friend request to ${user.firstName} ${user.lastName} canceled.",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                    Text(
                                      "Cancel",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 15),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
