//FireStore
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore bd = FirebaseFirestore.instance;

Future<List> getPets () async {
  List pets = [];
    CollectionReference collectionReferencePets = db.collection('pets');
    QuerySnapshot querySnapshotPets = await collectionReferencePets.get();
    querySnapshotPets.docs.forEach((documento) {
      people.add(documento.data())
    });

  return pets;
}