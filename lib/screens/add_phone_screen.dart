import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pphonedex/components/bottombar.dart';
import '../models/phone_model.dart';
import '../services/phone_service.dart';

class AddPhoneScreen extends StatefulWidget {
  final Phone? phoneToEdit;

  const AddPhoneScreen({super.key, this.phoneToEdit});

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
  bool get isEditing => widget.phoneToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
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
      // Fundo cinza, conforme o tema do app
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // O título e a cor são definidos pelo tema global em main.dart
        title: Text(isEditing ? 'Editar Celular' : 'Adicionar Celular'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          // Formulário dentro de um Card para se destacar no fundo cinza
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone com a cor primária do tema
                    Icon(
                      isEditing ? Icons.edit_note : Icons.add_circle_outline,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 24),
                    buildTextField(_nameController, 'Nome', Icons.smartphone),
                    buildTextField(_imageUrlController, 'URL da Imagem', Icons.image),
                    buildTextField(_ramController, 'Memória RAM', Icons.memory),
                    buildTextField(_cameraController, 'Megapixel da Câmera', Icons.camera_alt),
                    buildTextField(_storageController, 'Armazenamento', Icons.sd_storage),
                    buildTextField(_processorController, 'Processador', Icons.precision_manufacturing),
                    buildTextField(_batteryController, 'Bateria (mAh)', Icons.battery_charging_full),
                    buildTextField(_colorsController, 'Cores', Icons.color_lens),
                    buildTextField(_screenSizeController, 'Tamanho da Tela (polegadas)', Icons.straighten),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Você precisa estar logado para realizar esta ação.')),
                            );
                            return;
                          }

                          try {
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
                              status: 'pending',
                            );

                            if (isEditing) {
                              await _service.updatePhone(phone);
                            } else {
                              await _service.addPhone(phone);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEditing ? 'Celular atualizado com sucesso!' : 'Celular enviado para aprovação!')),
                            );
                            Navigator.pop(context);

                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
                            );
                          }
                        },
                        // Estilo do botão alinhado com o tema
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Salvar Alterações' : 'Adicionar Celular',
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
      ),
      // Barra de navegação inferior
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  // Widget para criar os campos de texto com estilo padronizado
  Widget buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
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
