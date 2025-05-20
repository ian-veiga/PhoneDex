import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.only(top: 32),
      decoration: const BoxDecoration(
        color: Colors.red,
        border: Border(
          right: BorderSide(color: Colors.black, width: 2),
          top: BorderSide(color: Colors.black, width: 2),
          bottom: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          // home: círculo amarelo
          _SidebarCustomButton(
            child: Icon(Icons.home, color: Colors.black),
            background: Colors.yellow,
          ),
          SizedBox(height: 16),

          // VS: texto
          _SidebarCustomButton(
            child: Text(
              'VS',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            background: Colors.white,
          ),
          SizedBox(height: 16),

          // globo
          _SidebarCustomButton(
            child: Icon(Icons.public, color: Colors.blue),
            background: Colors.white,
          ),
          SizedBox(height: 16),

          // estrela
          _SidebarCustomButton(
            child: Icon(Icons.star, color: Colors.black),
            background: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Botão genérico usado na sidebar para customizar cor e ícone/texto
class _SidebarCustomButton extends StatelessWidget {
  final Widget child;
  final Color background;

  const _SidebarCustomButton({
    required this.child,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: background,
      child: child,
    );
  }
}
