import 'package:flutter/material.dart';

class PhoneDetailScreen extends StatelessWidget {
  const PhoneDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>;

    final String phoneName = args['phoneName'] ?? 'Smartphone';
    final String imageUrl = args['imageUrl'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(
          phoneName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Card inferior (painel cinza claro) com margem e bordas arredondadas
          Positioned(
            top: 200, // ⬅️ Subiu de 220 para 200
            left: 24,
            right: 24,
            bottom: 16, // ⬅️ Pequena margem inferior para evitar grudar na borda
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Imagem flutuante centralizada
          Positioned(
            top: 110, // ⬅️ Subiu para acompanhar o cinza escuro maior
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imageUrl,
                  width: 140,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 140,
                    height: 200,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
