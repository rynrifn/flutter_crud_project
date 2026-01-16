import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'items';

  // ================= CREATE =================
  Future<void> addItem(Item item) async {
    await _firestore.collection(_collection).add({
      'name': item.name,
      'description': item.description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= READ (STREAM) =================
  Stream<List<Item>> getItemsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        final Timestamp? createdAt = data['createdAt'];
        final Timestamp? updatedAt = data['updatedAt'];

        return Item(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          createdAt: createdAt?.toDate() ?? DateTime.now(),
          updatedAt: updatedAt?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  // ================= UPDATE =================
  Future<void> updateItem(Item item) async {
    await _firestore.collection(_collection).doc(item.id).update({
      'name': item.name,
      'description': item.description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= DELETE =================
  Future<void> deleteItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
