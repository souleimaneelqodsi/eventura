import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/ui/views/events_list_view.dart';
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
  int _eventTypeIndex = 1;
  int currentPageIndex = 0;
  // ignore: prefer_function_declarations_over_variables
  final _pressedStyle =
      (int i, int currentPage) => ElevatedButton.styleFrom(
        backgroundColor: currentPage == i ? Colors.purple : null,
        foregroundColor: currentPage == i ? Colors.white : Colors.purple,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButton: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            mini: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(60)),
            ),

            backgroundColor: Colors.purple,
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/create_event'),
          ),
        ),
        appBar: AppBar(
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
          ),
          title: Image.asset('assets/icon/icon.png', height: 45),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 125,
                child: const DrawerHeader(
                  //decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Menu',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                title: const Text('FAQ'),
                onTap: () {
                  Navigator.pushNamed(context, '/faq');
                },
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              ListTile(
                title: const Text('Contact'),
                onTap: () {
                  Navigator.pushNamed(context, '/contact');
                },
              ),
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
                            hintText: 'Rechercher des événements',
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: _pressedStyle(1, _eventTypeIndex),
                                onPressed: () {
                                  setState(() => _eventTypeIndex = 1);
                                },
                                child: const Text(
                                  'My Events',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                style: _pressedStyle(2, _eventTypeIndex),
                                onPressed: () {
                                  setState(() => _eventTypeIndex = 2);
                                },
                                child: const Text(
                                  'Événements',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                style: _pressedStyle(3, _eventTypeIndex),
                                onPressed: () {
                                  setState(() => _eventTypeIndex = 3);
                                },
                                child: const Text(
                                  'Invitations',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //if (currentPageIndex == 1)
                  Expanded(
                    child:
                        _eventTypeIndex == 1
                            ? EventListView() // my events
                            : _eventTypeIndex == 2
                            ? EventListView() // public events
                            : EventListView(), // invitations
                  ),
                ],
              ),
              EventListView(), // favorites
              MessagesView(), // messages
              ProfileView(
                // user's profile
                userId: Provider.of<AuthService>(context).currentUser!.id,
              ),
            ][currentPageIndex],

        bottomNavigationBar: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          animationDuration: Duration(milliseconds: 500),
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(
              icon: Icon(Icons.favorite),
              label: "Favorites",
            ),
            NavigationDestination(icon: Icon(Icons.message), label: "Messages"),
            NavigationDestination(
              icon: Icon(Icons.account_circle),
              label: "Account",
            ),
          ],
          selectedIndex: currentPageIndex,
          onDestinationSelected: (index) {
            setState(() => currentPageIndex = index);
          },
        ),
      ),
    );
  }
}
