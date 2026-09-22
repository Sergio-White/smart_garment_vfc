import 'package:flutter/material.dart';

/// Pantalla "1. Perfil y línea base"
/// Paso 2 de 3: Configurar perfil (Edad, Estatura, Peso, IMC, Factores)
class PerfilLineaBaseScreen extends StatefulWidget {
  const PerfilLineaBaseScreen({super.key});

  @override
  State<PerfilLineaBaseScreen> createState() => _PerfilLineaBaseScreenState();
}

class _PerfilLineaBaseScreenState extends State<PerfilLineaBaseScreen> {
  // --- Controladores de texto ---
  final TextEditingController _edadController =
      TextEditingController(text: '52');
  final TextEditingController _estaturaController =
      TextEditingController(text: '1.66');
  final TextEditingController _pesoController =
      TextEditingController(text: '88');

  // --- Progreso del wizard ---
  final int _pasoActual = 2;
  final int _pasoTotal = 3;

  // --- Factores de riesgo (multi-selección) ---
  final Map<String, bool> _factores = {
    'Hipertensión': true,
    'Diabetes': false,
    'Sedentarismo': true,
    'Otro': false,
  };

  // --- Colores del tema oscuro (según el mockup) ---
  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3); // celeste botón
  static const Color _accentSelected = Color(0xFF9FD8EE);
  static const Color _mutedText = Color(0xFF8B96A5);

  double get _imc {
    final double? estatura = double.tryParse(_estaturaController.text);
    final double? peso = double.tryParse(_pesoController.text);
    if (estatura == null || peso == null || estatura <= 0) return 0;
    return peso / (estatura * estatura);
  }

  void _toggleFactor(String key) {
    setState(() {
      _factores[key] = !(_factores[key] ?? false);
    });
  }

  void _crearLineaBase() {
    final factoresSeleccionados = _factores.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    // Aquí se conecta con la lógica real (API, base de datos, etc.)
    debugPrint('Edad: ${_edadController.text}');
    debugPrint('Estatura: ${_estaturaController.text} m');
    debugPrint('Peso: ${_pesoController.text} kg');
    debugPrint('IMC: ${_imc.toStringAsFixed(1)} kg/m²');
    debugPrint('Factores: $factoresSeleccionados');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creando línea base...')),
    );
  }

  @override
  void dispose() {
    _edadController.dispose();
    _estaturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

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
        title: const Text(
          '1. Perfil y línea base',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Encabezado "Configurar perfil" ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Configurar perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.shield_outlined, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 16),

              // --- Barra de progreso ---
              _buildProgressCard(),
              const SizedBox(height: 20),

              // --- Campo Edad ---
              _buildLabel('Edad'),
              _buildTextField(
                controller: _edadController,
                suffix: 'años',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // --- Campo Estatura ---
              _buildLabel('Estatura'),
              _buildTextField(
                controller: _estaturaController,
                suffix: 'm',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // --- Campo Peso ---
              _buildLabel('Peso'),
              _buildTextField(
                controller: _pesoController,
                suffix: 'kg',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // --- Tarjeta IMC calculado ---
              _buildImcCard(),
              const SizedBox(height: 24),

              // --- Factores registrados ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Factores registrados',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Lógica de edición de factores
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: const BorderSide(color: _borderColor),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                    ),
                    child: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- Grid de factores (2 columnas) ---
              _buildFactoresGrid(),
              const SizedBox(height: 24),

              // --- Botón Crear línea base ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _crearLineaBase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Crear línea base',
                    style: TextStyle(
                      color: Color(0xFF0B0F14),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- Nota inferior ---
              const Text(
                'Requiere varias sesiones válidas en reposo. No es un diagnóstico.',
                style: TextStyle(color: _mutedText, fontSize: 12),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildProgressCard() {
    final double progreso = _pasoActual / _pasoTotal;
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
          Text(
            'Paso $_pasoActual de $_pasoTotal',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 6,
              backgroundColor: _borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(_accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String suffix,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixText: suffix,
          suffixStyle: const TextStyle(color: _mutedText),
        ),
      ),
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'IMC calculado',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '${_imc.toStringAsFixed(1)} kg/m²',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Se usará únicamente para personalizar mensajes educativos.',
            style: TextStyle(color: _mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFactoresGrid() {
    final keys = _factores.keys.toList();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: keys.map((key) {
        final bool seleccionado = _factores[key] ?? false;
        return _buildFactorChip(key, seleccionado);
      }).toList(),
    );
  }

  Widget _buildFactorChip(String label, bool seleccionado) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _toggleFactor(label),
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? _accentSelected : _borderColor,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: seleccionado ? Colors.white : Colors.white70,
            fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
