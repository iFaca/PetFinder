import 'package:flutter/material.dart';
import 'package:petfinder/firebase_service.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {

  TextEditingController petController = TextEditingController(text:"");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar mascota'),
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
          ElevatedButton(onPressed: () async {
            await addPets(petController.text).then((_) {
              Navigator.pop(context);
            });
          }, child: const Text("Guardar"))
        ],
      ),
     ),
    );
  }
}