import 'package:flutter/material.dart';

/// Pantalla "7. Orientación breve según perfil"
/// Muestra una recomendación educativa breve con base en el IMC
/// registrado del usuario, sugerencias de qué podría registrar hoy,
/// y un acceso para actualizar peso y estatura.
class OrientacionPerfilScreen extends StatelessWidget {
  const OrientacionPerfilScreen({super.key});

  // --- Datos de ejemplo ---
  final double _imc = 31.9;

  // --- Sugerencias del día, con su ícono ---
  static const List<(String, IconData)> _sugerencias = [
    ('Registrar alimentos y horarios', Icons.restaurant_outlined),
    ('Realizar la actividad autorizada', Icons.directions_run_outlined),
    ('Registrar cómo te sentiste', Icons.edit_note_outlined),
  ];

  // --- Colores del tema oscuro (según el mockup) ---
  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3);
  static const Color _mutedText = Color(0xFF8B96A5);
  static const Color _infoBg = Color(0xFF1C2733);
  static const Color _infoBar = Color(0xFF5FA8D3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '7. Orientación breve según perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Etiqueta "Bienestar" ---
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Bienestar',
                  style: TextStyle(color: _mutedText, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),

              // --- Título "Información para ti" + ícono info ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Información para ti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Mostrar más información
                    },
                    icon: const Icon(Icons.info_outline, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Tarjeta de IMC ---
              _buildImcCard(),
              const SizedBox(height: 16),

              // --- Recomendación educativa ---
              _buildRecomendacionBanner(),
              const SizedBox(height: 16),

              // --- Tarjeta "Hoy podría ser útil" ---
              _buildSugerenciasCard(),
              const SizedBox(height: 16),

              // --- Nota legal ---
              const Text(
                'La aplicación no prescribe dietas, ejercicio ni cambios de tratamiento. El IMC es solo un dato de contexto.',
                style: TextStyle(color: _mutedText, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),

              // --- Botón "Actualizar peso y estatura" ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // Navegar a actualizar peso y estatura
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Actualizar peso y estatura',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // WIDGETS AUXILIARES
  // ---------------------------------------------------------------------

  Widget _buildImcCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Con base en tu perfil registrado',
            style: TextStyle(color: _mutedText, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IMC: ${_imc.toStringAsFixed(1)} kg/m²',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                child: const Text(
                  'Dato editable',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendacionBanner() {
    return Container(
      decoration: BoxDecoration(
        color: _infoBg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: _infoBar, width: 4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Pequeña recomendación educativa',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Una alimentación equilibrada y actividad física adaptada pueden ser beneficiosas para la salud cardiovascular. Consulta con tu médico qué tipo e intensidad son adecuados para ti.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSugerenciasCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Hoy podría ser útil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (int i = 0; i < _sugerencias.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _sugerencias[i].$1,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Icon(_sugerencias[i].$2, color: _accentColor, size: 20),
                ],
              ),
            ),
            if (i != _sugerencias.length - 1)
              const Divider(color: _borderColor, height: 1),
          ],
        ],
      ),
    );
  }
}
