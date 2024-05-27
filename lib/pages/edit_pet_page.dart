import 'package:flutter/material.dart';
import 'package:petfinder/firebase_service.dart';

class EditPetPage extends StatefulWidget {
  const EditPetPage({super.key});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {

  TextEditingController petController = TextEditingController(text:"");

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    petController.text = arguments['type'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar mascota'),
      ),
    body: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
           TextField(
            controller: petController,
            decoration: const InputDecoration(
              hintText: 'Ingrese tipo mascota',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
            await updatePets(arguments['uid'],petController.text).then((_) {
              Navigator.pop(context);
            });
          },
              child: const Text("Actualizar"))
        ],
      ),
     ),
    );
  }
}