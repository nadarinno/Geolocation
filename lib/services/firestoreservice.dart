import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/store.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Store>> getStores() async {
    final snapshot = await _firestore.collection('stores').get();

    return snapshot.docs.map((doc) {
      return Store.fromMap(doc.data(), doc.id);
    }).toList();
  }
}


