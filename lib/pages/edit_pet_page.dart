import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener esta importación
import 'package:petfinder/firebase_service.dart';

class EditPetPage extends StatefulWidget {
  const EditPetPage({super.key});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  TextEditingController typeController = TextEditingController(text: "");
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController latitudeController = TextEditingController(text: "");
  TextEditingController longitudeController = TextEditingController(text: "");
  String gender = "Macho"; // Estado inicial del Dropdown
  bool lost = false;
  bool _isInitialized = false;

  // Variables para almacenar los datos de los argumentos
  late String uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

      // Inicializa los valores de los controladores y el estado solo una vez
      uid = arguments['uid'];
      typeController.text = arguments['type'];
      nameController.text = arguments['name'];
      latitudeController.text = arguments['location'].latitude.toString();
      longitudeController.text = arguments['location'].longitude.toString();
      gender = arguments['gender'] ?? 'Macho'; // Valor por defecto si es nulo
      lost = arguments['lost'] ?? false;

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar mascota'),
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
              DropdownButton<String>(
                value: gender,
                hint: const Text('Seleccione género'),
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
                        print(lost);
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

                  await updatePets(
                    uid,
                    typeController.text,
                    nameController.text,
                    location,
                    gender,
                    lost,
                  ).then((_) {
                    Navigator.pop(context);
                  });
                },
                child: const Text("Actualizar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
