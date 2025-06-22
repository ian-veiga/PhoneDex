import 'package:flutter/material.dart';
import '../models/phone_model.dart';
import '../services/phone_service.dart';

class AddPhoneScreen extends StatefulWidget {
  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ramController = TextEditingController();
  final _cameraController = TextEditingController();
  final _storageController = TextEditingController();
  final _processorController = TextEditingController();
  final _batteryController = TextEditingController();
  final _service = PhoneService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Celular')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Nome')),
              TextFormField(controller: _imageUrlController, decoration: InputDecoration(labelText: 'URL da Imagem')),
              TextFormField(controller: _ramController, decoration: InputDecoration(labelText: 'Memória RAM')),
              TextFormField(controller: _cameraController, decoration: InputDecoration(labelText: 'Megapixel da Câmera')),
              TextFormField(controller: _storageController, decoration: InputDecoration(labelText: 'Armazenamento')),
              TextFormField(controller: _processorController, decoration: InputDecoration(labelText: 'Processador')),
              TextFormField(controller: _batteryController, decoration: InputDecoration(labelText: 'Bateria')),
              SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final phone = Phone(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      imageUrl: _imageUrlController.text,
                      ram: _ramController.text,
                      camera: _cameraController.text,
                      storage: _storageController.text,
                      processor: _processorController.text,
                      battery: _batteryController.text,
                    );
                    await _service.addPhone(phone);
                    Navigator.pop(context);
                  }
                },
                child: Text('Adicionar Celular'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}