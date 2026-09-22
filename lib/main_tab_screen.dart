import 'package:flutter/material.dart';
import 'corazon_base.dart';
import 'tendencias_base.dart';
import 'historial_base.dart';
import 'perfil_base.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3);
  static const Color _mutedText = Color(0xFF8B96A5);

  final List<Widget> _screens = const [
    MiCorazonScreen(),
    TendenciasBaseScreen(),
    HistorialBaseScreen(),
    PerfilBaseScreen(),
  ];

  final List<(String, IconData)> _items = const [
    ('Inicio', Icons.favorite_border),
    ('Tendencias', Icons.show_chart),
    ('Historial', Icons.badge_outlined),
    ('Perfil', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,

      body: Stack(
        children: List.generate(_screens.length, (index) {
          final bool seleccionada = index == _selectedIndex;
          return IgnorePointer(
            ignoring: !seleccionada,
            child: AnimatedOpacity(
              opacity: seleccionada ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: _screens[index],
            ),
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_items.length, (index) {
            final (label, icon) = _items[index];
            final bool seleccionado = index == _selectedIndex;
            final Color color = seleccionado ? _accentColor : _mutedText;
            return InkWell(
              onTap: () => setState(() => _selectedIndex = index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight:
                          seleccionado ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
