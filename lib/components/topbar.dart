import 'package:flutter/material.dart';

/// Widget que representa a barra superior (TopBar) do app.
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
     decoration: const BoxDecoration(
        color: Colors.red,
        border: Border(
          right: BorderSide(color: Colors.black, width: 2),
          top: BorderSide(color: Colors.black, width: 2),
          bottom: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // avatar usuário
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.red),
          ),
          const SizedBox(width: 12),

          // campo de busca
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // menu (ícone hambúrguer)
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.menu, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
