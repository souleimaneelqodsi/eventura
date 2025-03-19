import 'package:flutter/material.dart';

class HomepageView extends StatelessWidget {
  const HomepageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Image.asset('assets/logo.png', height: 40), // Logo centré
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Mon Profil'),
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
          ],
        ),
      ),
      body: Padding(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/events_list');
                  },
                  child: const Text('My Events'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/events_list');
                  },
                  child: const Text('Événements'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/invitations');
                  },
                  child: const Text('Invitations'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Card(
              child: ListTile(
                title: const Text('Prochain Événement'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Nom : Nom de l\'événement'),
                    Text('Date : JJ/MM/AAAA'),
                    Text('Lieu : Lieu de l\'événement'),
                    Text('Heure : HH:MM'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              // Action pour l'icône "Cœur"
              break;
            case 2:
              Navigator.pushNamed(context, '/messages');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
