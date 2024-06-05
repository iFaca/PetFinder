import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener esta importación
import 'package:petfinder/firebase_service.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  TextEditingController typeController = TextEditingController(text: "");
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController latitudeController = TextEditingController(text: "");
  TextEditingController longitudeController = TextEditingController(text: "");
  String gender = "Macho"; // Estado inicial del Dropdown // Cambio
  bool lost = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView( // Para que no haya problemas de scroll
          child: Column(
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese tipo mascota',
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese nombre',
                ),
              ),
              TextField(
                controller: latitudeController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese latitud',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: longitudeController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese longitud',
                ),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>( // Dropdown para género // Cambio
                value: gender,
                items: <String>['Macho', 'Hembra'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: lost,
                    onChanged: (bool? value) {
                      setState(() {
                        lost = value!;
                      });
                    },
                  ),
                  const Text('Perdido'),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  GeoPoint location = GeoPoint(
                    double.parse(latitudeController.text),
                    double.parse(longitudeController.text),
                  );

                  await addPets(
                    typeController.text,
                    nameController.text,
                    location,
                    gender, // Cambio
                    lost,
                  ).then((_) {
                    Navigator.pop(context);
                  });
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
