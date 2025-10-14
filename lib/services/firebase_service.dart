import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/weather_models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Get current user's favorites with robust error handling
  Stream<List<FavoriteCity>> getFavorites() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // ✅ Simple query without orderBy to avoid index issues
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: (sink) {
            print('Timeout loading favorites');
            //sink.add(null);
          },
        )
        .map((snapshot) {
          if (snapshot == null || snapshot.docs.isEmpty) {
            return <FavoriteCity>[];
          }

          try {
            var cities = snapshot.docs.map((doc) {
              final data = doc.data();
              return FavoriteCity.fromJson({
                ...data,
                'id': doc.id,
              });
            }).toList();

            // ✅ Sort in memory by order field
            cities.sort((a, b) {
              final orderA = a.order ?? 0;
              final orderB = b.order ?? 0;
              return orderA.compareTo(orderB);
            });

            return cities;
          } catch (e) {
            print('Error parsing favorites: $e');
            return <FavoriteCity>[];
          }
        })
        .handleError((error) {
          print('Stream error: $error');
          return <FavoriteCity>[];
        });
  }

  // ✅ Add favorite
  Future<void> addFavorite(FavoriteCity city) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final data = city.toJson();
      await _firestore.collection('favorites').doc(city.id).set({
        ...data,
        'userId': user.uid,
        'order': city.order ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  // ✅ Remove favorite
  Future<void> removeFavorite(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('favorites').doc(id).delete();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  // ✅ Update favorite order
  Future<void> updateFavoriteOrder(List<FavoriteCity> cities) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final batch = _firestore.batch();
      for (var i = 0; i < cities.length; i++) {
        final city = cities[i];
        final docRef = _firestore.collection('favorites').doc(city.id);
        batch.update(docRef, {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error updating order: $e');
    }
  }
}