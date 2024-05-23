//FireStore
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//Listmos de la base de datos
Future<List> getPets () async {
  List pets = [];
    CollectionReference collectionReferencePets = db.collection('pets');
    QuerySnapshot querySnapshotPets = await collectionReferencePets.get();
    querySnapshotPets.docs.forEach((documento) {
      pets.add(documento.data());
    });

  return pets;
}

//Guardar en base de datos
Future<void> addPets (String type) async {
  await db.collection("pets").add({"type": type});
}