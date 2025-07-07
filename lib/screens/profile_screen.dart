import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/phone_model.dart';
import '../services/phone_service.dart';
import 'add_phone_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PhoneService _phoneService = PhoneService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String? photoUrl;
  File? selectedImage;
  bool showPassword = false;
  String? username;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      _emailController.text = user.email ?? '';
      photoUrl = user.photoURL;

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        username = doc.data()?['username'] ?? 'Perfil do Usuário';
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;

    try {
      if (_emailController.text != user!.email) {
        await user.updateEmail(_emailController.text);
      }

      if (_senhaController.text.isNotEmpty) {
        await user.updatePassword(_senhaController.text);
      }

      if (selectedImage != null) {
        String newPhotoUrl = "https://placehold.co/100x100";
        await user.updatePhotoURL(newPhotoUrl);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permissão negada para acessar a galeria.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = selectedImage != null
        ? FileImage(selectedImage!)
        : (photoUrl != null
            ? NetworkImage(photoUrl!)
            : const AssetImage("assets/images/img_perfil.png") as ImageProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(username ?? "Perfil do Usuário"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF8A80), Color(0xFFFFCDD2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  username ?? "Perfil do Usuário",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(radius: 75, backgroundImage: image),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildTextField(_emailController, "Email", Icons.email),
                const SizedBox(height: 24),
                _buildPasswordField(),
                const SizedBox(height: 40),
                if (userId != null) ...[
                  _buildPhoneSection(
                  "Celulares Aprovados",
                  _phoneService.getPhones(),
                  showActions: false,
                  minHeight: 180,
                  ),
                  const SizedBox(height: 24),
                  _buildPhoneSection(
                  "Celulares Pendentes",
                  _phoneService.getPendingPhones(),
                  showActions: true,
                  minHeight: 180,
                  ),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Salvar Alterações", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _senhaController,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: "Nova Senha",
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => showPassword = !showPassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPhoneSection(String title, Stream<List<Phone>> stream, {required bool showActions, double? minHeight}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            StreamBuilder<List<Phone>>(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final phones = snapshot.data!.where((phone) => phone.userId == userId).toList();

                if (phones.isEmpty) {
                  return Container(
                    constraints: BoxConstraints(minHeight: minHeight ?? 0),
                    alignment: Alignment.centerLeft,
                    child: const Text("Nenhum celular encontrado.", style: TextStyle(color: Colors.black54)),
                  );
                }

                return Column(
                  children: phones.map((phone) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            phone.imageUrl,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        ),
                        title: Text(phone.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Armazenamento: ${phone.storage}"),
                            Text("RAM: ${phone.ram}"),
                          ],
                        ),
                        trailing: showActions
                            ? Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddPhoneScreen(phoneToEdit: phone),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Confirmar exclusão"),
                                          content: const Text("Deseja realmente excluir este celular?"),
                                          actions: [
                                            TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context, false)),
                                            TextButton(child: const Text("Excluir"), onPressed: () => Navigator.pop(context, true)),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _phoneService.deletePhone(phone.id);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Celular excluído.")));
                                      }
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 
