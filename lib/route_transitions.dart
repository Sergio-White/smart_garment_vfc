import 'package:flutter/material.dart';

/// Crea una ruta con una transición suave (fundido + deslizamiento leve)
/// en lugar del salto abrupto por defecto de [MaterialPageRoute].
///
/// [name] permite identificar la ruta más adelante (por ejemplo con
/// `Navigator.popUntil`) para volver directamente a una pantalla
/// específica sin importar cuántas pantallas haya encima.
///
/// Úsala así en cualquier pantalla:
/// ```dart
/// Navigator.push(context, fadeThroughRoute(const MiPantalla(), name: '/miPantalla'));
/// ```
Route<T> fadeThroughRoute<T>(Widget page, {String? name}) {
  return PageRouteBuilder<T>(
    settings: RouteSettings(name: name),
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      // Fundido de opacidad combinado con un desplazamiento vertical leve,
      // efecto similar al "fade through" de Material.
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
