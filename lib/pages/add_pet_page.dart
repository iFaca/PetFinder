import 'package:flutter/material.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet'),
      ),
      body: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Ingrese mascota',
            ),
          ),
          ElevatedButton(onPressed: (){}, child: const Text("Guardar"))
        ],
      ),
    );
  }
}