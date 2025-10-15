
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xam_ap/app.dart';
import '../services/firebase_service.dart';
import '../models/weather_models.dart';

class FavoriteDrawer extends StatefulWidget {
  final FirebaseService firebaseService;
  final Function(String) onCitySelected;

  const FavoriteDrawer({
    super.key,
    required this.firebaseService,
    required this.onCitySelected,
  });

  @override
  State<FavoriteDrawer> createState() => _FavoriteDrawerState();
}

class _FavoriteDrawerState extends State<FavoriteDrawer> {
  final TextEditingController _addCityController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _addFavorite() {
    final cityName = _addCityController.text.trim();
    if (cityName.isNotEmpty) {
      final city = FavoriteCity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: cityName,
        order: 0,
      );
      widget.firebaseService.addFavorite(city);
      _addCityController.clear();
      Navigator.pop(context);
    }
  }

  void _removeFavorite(String id) {
    widget.firebaseService.removeFavorite(id);
  }

  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.blue.shade900,
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Close the drawer first
        Navigator.pop(context);
        
        // Sign out - AuthWrapper will automatically handle navigation
        await _auth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthWrapper()));
        // No need to manually navigate - AuthWrapper stream will update
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user for display
    final User? user = _auth.currentUser;
    final String displayEmail = user?.email ?? 'User';
    final String displayName = displayEmail.split('@').first; // Show student ID part only

    return Drawer(
      backgroundColor: Colors.blue.shade900.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Drawer Header with User Info
            const SizedBox(height: 40),
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 60,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    displayEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Favorite Cities Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Favorite Cities',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Add City Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _addCityController,
                      decoration: InputDecoration(
                        hintText: 'Add city...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.add, color: Colors.white.withOpacity(0.7)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.check, color: Colors.white.withOpacity(0.7)),
                          onPressed: _addFavorite,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _addFavorite(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Favorites List
                  Expanded(
                    child: StreamBuilder<List<FavoriteCity>>(
                      stream: widget.firebaseService.getFavorites(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        final favorites = snapshot.data ?? [];

                        if (favorites.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_city,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 50,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No favorite cities yet',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Add cities to see them here',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final city = favorites[index];
                            return Card(
                              color: Colors.white.withOpacity(0.1),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.location_city, color: Colors.white),
                                title: Text(
                                  city.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeFavorite(city.id),
                                ),
                                onTap: () {
                                  widget.onCitySelected(city.name);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Logout Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}