//FireStore
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//Listmos de la base de datos
Future<List> getPets () async {
  List pets = [];
    CollectionReference collectionReferencePets = db.collection('pets');
    QuerySnapshot querySnapshotPets = await collectionReferencePets.get();
    querySnapshotPets.docs.forEach((documento) {
      final Map<String, dynamic> data = documento.data() as Map<String, dynamic> ;
      final pet = {
        "type": data['type'],
        "uid":documento.id,
      };
      pets.add(pet);
    });

  return pets;
}

//Guardar en base de datos
Future<void> addPets (String type) async {
  await db.collection("pets").add({"type": type});
}

//Actualizar en base de datos
Future<void> updatePets (String uid, String newtype) async {
  await db.collection("pets").doc(uid).set({"type": newtype});
}