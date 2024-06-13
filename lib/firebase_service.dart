import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Listar las mascotas de la base de datos
Future<List> getPets() async {
  List pets = [];
  CollectionReference collectionReferencePets = db.collection('pets');
  QuerySnapshot querySnapshotPets = await collectionReferencePets.get();
  querySnapshotPets.docs.forEach((documento) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    final pet = {
      "type": data['type'],
      "location": data['location'],
      "gender": data['gender'],
      "name": data['name'],
      "lost": data['lost'],
      "uid": documento.id,
      "isOwned": data['isOwned'],
      "imagePath": data['imagePath'],
      "reward": data['reward'] ?? '0',
    };
    pets.add(pet);
  });

  return pets;
}

// Guardar en base de datos
Future<void> addPets(String type, String name, GeoPoint location, String gender,
    bool lost, String isOwned, String imagePath, String reward) async {
  await db.collection("pets").add({
    "type": type,
    "name": name,
    "location": location,
    "gender": gender,
    "lost": lost,
    "isOwned": isOwned,
    "imagePath": imagePath,
    "reward": reward,
  });
}

// Actualizar en base de datos
Future<void> updatePets(String uid, String newtype, String newname,
    GeoPoint newlocation, String newgender, bool newlost, String newisOwned, String newimagePath, String newReward) async {
  await db.collection("pets").doc(uid).set({
    "type": newtype,
    "name": newname,
    "location": newlocation,
    "gender": newgender,
    "lost": newlost,
    "isOwned": newisOwned,
    "imagePath": newimagePath,
    "reward": newReward,
  });
}

// Borrar en base de datos
Future<void> deletePets(String uid) async {
  await db.collection("pets").doc(uid).delete();
}