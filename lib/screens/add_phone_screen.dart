import 'package:firebase_auth/firebase_auth.dart'; // IMPORTAR
import 'package:flutter/material.dart';
import '../models/phone_model.dart';
import '../services/phone_service.dart';

class AddPhoneScreen extends StatefulWidget {
  final Phone? phoneToEdit; // Adicionar para edição

  const AddPhoneScreen({super.key, this.phoneToEdit}); // Modificar construtor

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
  final _colorsController = TextEditingController();
  final _screenSizeController = TextEditingController();

  final _service = PhoneService();
  bool get isEditing => widget.phoneToEdit != null; // NOVO

  @override
  void initState() {
    super.initState();
    if (isEditing) { // NOVO
      final phone = widget.phoneToEdit!;
      _nameController.text = phone.name;
      _imageUrlController.text = phone.imageUrl;
      _ramController.text = phone.ram;
      _cameraController.text = phone.camera;
      _storageController.text = phone.storage;
      _processorController.text = phone.processor;
      _batteryController.text = phone.battery;
      _colorsController.text = phone.colors;
      _screenSizeController.text = phone.screenSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Celular' : 'Adicionar Celular'), // MODIFICADO
        backgroundColor: const Color(0xFFFF8A80),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF8A80), Color(0xFFFFCDD2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add_circle, // MODIFICADO
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  buildTextField(_nameController, 'Nome', Icons.smartphone),
                  buildTextField(_imageUrlController, 'URL da Imagem', Icons.image),
                  buildTextField(_ramController, 'Memória RAM', Icons.memory),
                  buildTextField(_cameraController, 'Megapixel da Câmera', Icons.camera),
                  buildTextField(_storageController, 'Armazenamento', Icons.sd_storage),
                  buildTextField(_processorController, 'Processador', Icons.precision_manufacturing),
                  buildTextField(_batteryController, 'Bateria', Icons.battery_charging_full),
                  buildTextField(_colorsController, 'Cores', Icons.color_lens),
                  buildTextField(_screenSizeController, 'Tamanho da Tela', Icons.straighten),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
  if (!_formKey.currentState!.validate()) {
    return; // Não faz nada se o formulário for inválido
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Você precisa estar logado para realizar esta ação.')),
    );
    return;
  }

  // --- INÍCIO DA MODIFICAÇÃO: Adicionando o try/catch ---
  try {
    // Monta o objeto Phone
    final phone = Phone(
      id: isEditing ? widget.phoneToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      imageUrl: _imageUrlController.text,
      ram: _ramController.text,
      camera: _cameraController.text,
      storage: _storageController.text,
      processor: _processorController.text,
      battery: _batteryController.text,
      colors: _colorsController.text,
      screenSize: _screenSizeController.text,
      userId: user.uid,
      status: 'pending', // Garante que o status é 'pending'
    );

    // Tenta adicionar o celular ao banco de dados
    if (isEditing) {
      await _service.updatePhone(phone);
    } else {
      await _service.addPhone(phone);
    }

    // Se a operação for bem-sucedida, mostra a mensagem de sucesso e volta
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Celular enviado para aprovação!')),
    );
    Navigator.pop(context);

  } catch (e) {
    // Se ocorrer um erro, ele será capturado aqui
    // e exibido em uma SnackBar para depuração.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
    );
  }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Salvar Alterações' : 'Adicionar Celular', // MODIFICADO
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Preencha o campo $label';
          }
          return null;
        },
      ),
    );
  }
}