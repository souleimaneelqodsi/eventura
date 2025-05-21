import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/profile_viewmodel.dart';
import 'package:eventura/ui/shared/app_colors.dart';
import 'package:eventura/ui/shared/is_editing_profile.dart';
import 'package:eventura/ui/static/event_list_type.dart';
import 'package:eventura/ui/views/events_list_view.dart';
import 'package:eventura/ui/views/friends_view.dart';
import 'package:eventura/ui/views/messages_view.dart';
import 'package:eventura/ui/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomepageView extends StatefulWidget {
  const HomepageView({super.key});

  @override
  State<HomepageView> createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  late ProfileViewmodel _profileViewmodel;
  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser!.id;
    _profileViewmodel = ProfileViewmodel(
      userService: authService,
      userId: currentUserId,
    );
    _profileViewmodel.loadProfile();
  }

  final friendsView = FriendsView();

  int _eventTypeIndex = 0;
  int currentPageIndex = 0;

  final _pressedStyle =
      (int i, int currentPage) => ElevatedButton.styleFrom(
        backgroundColor:
            currentPage == i ? Colors.purple : AppColors.secondaryGrey,
        foregroundColor:
            currentPage == i ? Colors.white : AppColors.onSecondaryGrey,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      );

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser!.id;
    final titleMedium = Theme.of(context).textTheme.titleMedium;

    final profileView = ProfileView(userId: currentUserId, fromHome: true);
    return ChangeNotifierProvider.value(
      value: _profileViewmodel,
      child: Consumer<ProfileViewmodel>(
        builder:
            (context, profileViewmodel, child) => Scaffold(
              floatingActionButton:
                  currentPageIndex == 0
                      ? SizedBox(
                        width: 50,
                        height: 50,
                        child: FloatingActionButton(
                          mini: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                          ),

                          backgroundColor: Colors.purple,
                          child: Icon(Icons.add, color: Colors.white),
                          onPressed:
                              () =>
                                  Navigator.pushNamed(context, '/create_event'),
                        ),
                      )
                      : null,
              appBar: AppBar(
                leading: Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu, size: 30),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                ),
                title: Image.asset('assets/icon/icon.png', height: 50),
                actions: [
                  if (currentPageIndex != 4 &&
                      profileViewmodel.currentUser != null)
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              (profileViewmodel.currentUser!.profilePicture !=
                                          null &&
                                      profileViewmodel
                                          .currentUser!
                                          .profilePicture!
                                          .isNotEmpty)
                                  ? NetworkImage(
                                    profileViewmodel
                                        .currentUser!
                                        .profilePicture!,
                                  )
                                  : null,
                          child:
                              (profileViewmodel.currentUser!.profilePicture ==
                                          null ||
                                      profileViewmodel
                                          .currentUser!
                                          .profilePicture!
                                          .isEmpty)
                                  ? Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Colors.grey[700],
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  if (currentPageIndex == 4 &&
                      profileViewmodel.isCurrentUserProfile)
                    Consumer<ProfileEditingState>(
                      builder: (context, editingState, _) {
                        return IconButton(
                          icon: Icon(
                            editingState.isEditing ? Icons.check : Icons.edit,
                            size: 25,
                          ),
                          onPressed: () {
                            editingState.toggleEditing();
                          },
                        );
                      },
                    ),
                ],
              ),
              drawer: Drawer(
                width: MediaQuery.of(context).size.width * 0.6,

                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(8),
                        children: [
                          SizedBox(
                            height: 125,
                            child: DrawerHeader(
                              child: Text(
                                'Menu',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            title: Text('Home', style: titleMedium),
                            onTap: () {
                              Navigator.pushNamed(context, '/home');
                            },
                          ),
                          const Divider(indent: 7, thickness: 2),
                          ListTile(
                            title: Text('Profile', style: titleMedium),
                            onTap: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                          const Divider(indent: 7, thickness: 2),
                          ListTile(
                            title: Text('Settings', style: titleMedium),
                            onTap: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),
                          const Divider(indent: 7, thickness: 2),
                          ListTile(
                            title: Text('FAQ', style: titleMedium),
                            onTap: () {
                              Navigator.pushNamed(context, '/faq');
                            },
                          ),
                          const Divider(indent: 7, thickness: 2),
                          ListTile(
                            title: Text('About', style: titleMedium),
                            onTap: () {
                              Navigator.pushNamed(context, '/about');
                            },
                          ),
                          const Divider(indent: 7, thickness: 2),
                          ListTile(
                            title: Text('Contact', style: titleMedium),
                            onTap: () {
                              Navigator.pushNamed(context, '/contact');
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Version 1.0.0",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.onSecondaryGrey,
                        ),
                      ),
                    ),
                    SizedBox(height: 48.0),
                  ],
                ),
              ),
              body:
                  [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search Events',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: _pressedStyle(0, _eventTypeIndex),
                                      onPressed: () {
                                        setState(() => _eventTypeIndex = 0);
                                      },
                                      child: const Text('My Events'),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      style: _pressedStyle(1, _eventTypeIndex),
                                      onPressed: () {
                                        setState(() => _eventTypeIndex = 1);
                                      },
                                      child: const Text('Events'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child:
                              _eventTypeIndex == 0
                                  ? EventListView()
                                  : EventListView(
                                    pageType: EventListType.events,
                                  ),
                        ),
                      ],
                    ),

                    EventListView(pageType: EventListType.favorites),
                    friendsView,
                    MessagesView(),
                    profileView,
                  ][currentPageIndex],

              bottomNavigationBar: NavigationBar(
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                animationDuration: Duration(milliseconds: 500),
                destinations: [
                  NavigationDestination(icon: Icon(Icons.home), label: "Home"),
                  NavigationDestination(
                    icon: Icon(Icons.favorite),
                    label: "Favorites",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.group_rounded),
                    label: "Friends",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.message),
                    label: "Messages",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_circle),
                    label: "Account",
                  ),
                ],
                selectedIndex: currentPageIndex,
                onDestinationSelected: (index) {
                  if (index == 4) {
                    Provider.of<AuthService>(context, listen: false).refresh();
                  }
                  setState(() => currentPageIndex = index);
                },
              ),
            ),
      ),
    );
  }
}
