import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pphonedex/services/auth_service.dart';
import 'package:pphonedex/screens/pending_phones_screen.dart';
import 'package:pphonedex/components/bottombar.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final PhoneService _phoneService = PhoneService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isAdmin = false;
  bool _isLoading = false;
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
      await user.reload();
      final updatedUser = _auth.currentUser;
      userId = updatedUser?.uid;
      _emailController.text = updatedUser?.email ?? '';

      final doc =
          await _firestore.collection('users').doc(updatedUser!.uid).get();
      if (mounted) {
        setState(() {
          username = doc.data()?['username'] ?? 'Perfil do Usuário';
          photoUrl = doc.data()?['photoURL'] ?? updatedUser.photoURL;
          isAdmin = _authService.isAdmin;
        });
      }
    }
  }

  Future<String?> _uploadProfilePicture(File image, String userId) async {
    try {
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      UploadTask uploadTask =
          ref.putFile(image, SettableMetadata(contentType: 'image/jpeg'));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro no upload da imagem: $e")),
      );
      return null;
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl = photoUrl;
      if (selectedImage != null) {
        newPhotoUrl = await _uploadProfilePicture(selectedImage!, user.uid);
      }
      if (newPhotoUrl != null && newPhotoUrl != user.photoURL) {
        await user.updatePhotoURL(newPhotoUrl);
      }
      if (_emailController.text != user.email) {
        await user.updateEmail(_emailController.text);
      }
      if (_senhaController.text.isNotEmpty) {
        await user.updatePassword(_senhaController.text);
      }
      await _firestore.collection('users').doc(user.uid).set({
        'photoURL': newPhotoUrl ?? '',
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar perfil: $e")),
      );
    } finally {
      if (mounted) {
        await _loadUserData();
        setState(() {
          selectedImage = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider image;
    if (selectedImage != null) {
      image = FileImage(selectedImage!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      image = NetworkImage(photoUrl!);
    } else {
      image = const AssetImage("assets/images/img_perfil.png");
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: Text(username ?? "Perfil do Usuário"),
        elevation: 4,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              key: ValueKey(selectedImage?.path ?? photoUrl),
                              radius: 75,
                              backgroundImage: image,
                              backgroundColor: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              icon: Icon(Icons.edit,
                                  size: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                              label: Text('Alterar Foto',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold)),
                              onPressed: _pickImage,
                            ),
                            const SizedBox(height: 24),
                            Text(username ?? "Perfil do Usuário",
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            const SizedBox(height: 32),
                            _buildTextField(
                                controller: _emailController,
                                label: "Email",
                                icon: Icons.email),
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                            const SizedBox(height: 32),
                            if (isAdmin) _buildAdminButton(),
                            if (isAdmin) const SizedBox(height: 12),
                            _buildSaveChangesButton(),
                            
                            // BOTÃO DE SAIR IMPLEMENTADO AQUI
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (!mounted) return;
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text("Sair", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (userId != null) ...[
                      const SizedBox(height: 24),
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
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
      ),
      keyboardType: TextInputType.emailAddress,
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
        fillColor: const Color(0xFFF5F5F5),
      ),
    );
  }

  Widget _buildAdminButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.pending_actions),
        label: const Text('Aprovações Pendentes'),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PendingPhonesScreen()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSaveChangesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          "Salvar Alterações",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPhoneSection(String title, Stream<List<Phone>> stream,
      {required bool showActions, double? minHeight}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 12),
            StreamBuilder<List<Phone>>(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final phones = snapshot.data!
                    .where((phone) => phone.userId == userId)
                    .toList();

                if (phones.isEmpty) {
                  return Container(
                    constraints: BoxConstraints(minHeight: minHeight ?? 0),
                    alignment: Alignment.centerLeft,
                    child: const Text("Nenhum celular encontrado.",
                        style: TextStyle(color: Colors.black54)),
                  );
                }

                return Column(
                  children: phones.map((phone) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                        title: Text(phone.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
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
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddPhoneScreen(phoneToEdit: phone),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Confirmar exclusão"),
                                          content: const Text(
                                              "Deseja realmente excluir este celular?"),
                                          actions: [
                                            TextButton(
                                                child: const Text("Cancelar"),
                                                onPressed: () =>
                                                    Navigator.pop(context, false)),
                                            TextButton(
                                                child: const Text("Excluir"),
                                                onPressed: () =>
                                                    Navigator.pop(context, true)),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _phoneService.deletePhone(phone.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text("Celular excluído.")));
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