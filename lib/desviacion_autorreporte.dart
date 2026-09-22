import 'package:flutter/material.dart';

/// Pantalla "3. Desviación y autorreporte"
/// Se muestra cuando se detecta un cambio respecto al patrón habitual
/// de frecuencia cardíaca, y permite al usuario dar contexto: si su
/// estado anímico se alteró, qué sintió, la intensidad percibida,
/// qué estaba haciendo, y una nota opcional.
class DesviacionAutorreporteScreen extends StatefulWidget {
  const DesviacionAutorreporteScreen({super.key});

  @override
  State<DesviacionAutorreporteScreen> createState() =>
      _DesviacionAutorreporteScreenState();
}

class _DesviacionAutorreporteScreenState
    extends State<DesviacionAutorreporteScreen> {
  // --- Estado del formulario ---
  bool? _estadoAlterado = true; // null = sin responder, true = Sí, false = No

  final Map<String, bool> _sentimientos = {
    'Estrés': true,
    'Enojo': false,
    'Tristeza': false,
    'Miedo': false,
    'Alegría': false,
    'Otro': false,
  };

  double _intensidad = 7;

  final List<String> _actividades = const [
    'Trabajando sentado',
    'Caminando',
    'Descansando',
    'Haciendo ejercicio',
    'Comiendo',
    'Otro',
  ];
  String _actividadSeleccionada = 'Trabajando sentado';

  final TextEditingController _notaController =
      TextEditingController(text: 'Tuve una discusión.');

  // --- Colores del tema oscuro (según el mockup) ---
  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3);
  static const Color _selectedBorder = Color(0xFF9FD8EE);
  static const Color _mutedText = Color(0xFF8B96A5);
  static const Color _warningBg = Color(0xFF1B2028);
  static const Color _warningBar = Color(0xFFD98B6B);

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  void _guardarEvento() {
    final sentidos =
        _sentimientos.entries.where((e) => e.value).map((e) => e.key).toList();

    // Aquí se conecta con la lógica real (API, base de datos, etc.)
    debugPrint('Estado anímico alterado: $_estadoAlterado');
    debugPrint('Sentimientos: $sentidos');
    debugPrint('Intensidad: ${_intensidad.round()}/10');
    debugPrint('Actividad: $_actividadSeleccionada');
    debugPrint('Nota: ${_notaController.text}');

    Navigator.of(context).maybePop();
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '3. Desviación y autorreporte',
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
              // --- Estado de señal ---
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                    SizedBox(width: 6),
                    Text(
                      'Señal buena',
                      style: TextStyle(color: _mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // --- Título + botón cerrar ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cuéntanos el contexto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- Aviso de cambio respecto al patrón ---
              _buildAvisoPatron(),
              const SizedBox(height: 20),

              // --- ¿Tu estado anímico se alteró? ---
              const Text(
                '¿Tu estado anímico se alteró?',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildOpcionSiNo(
                      label: 'Sí',
                      seleccionado: _estadoAlterado == true,
                      onTap: () => setState(() => _estadoAlterado = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOpcionSiNo(
                      label: 'No',
                      seleccionado: _estadoAlterado == false,
                      onTap: () => setState(() => _estadoAlterado = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Selecciona lo que sentiste ---
              const Text(
                'Selecciona lo que sentiste',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildSentimientosGrid(),
              const SizedBox(height: 20),

              // --- Intensidad percibida ---
              Text(
                'Intensidad percibida: ${_intensidad.round()}/10',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: _accentColor,
                  inactiveTrackColor: _borderColor,
                  thumbColor: Colors.white,
                  overlayColor: _accentColor.withValues(alpha: 0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _intensidad,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (valor) => setState(() => _intensidad = valor),
                ),
              ),
              const SizedBox(height: 12),

              // --- ¿Qué estabas haciendo? ---
              const Text(
                '¿Qué estabas haciendo?',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildActividadDropdown(),
              const SizedBox(height: 20),

              // --- Nota opcional ---
              const Text(
                'Nota opcional',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildNotaField(),
              const SizedBox(height: 24),

              // --- Botón Guardar evento ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardarEvento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Guardar evento',
                    style: TextStyle(
                      color: Color(0xFF0B0F14),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- Botón Omitir por ahora ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Omitir por ahora',
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

  Widget _buildAvisoPatron() {
    return Container(
      decoration: BoxDecoration(
        color: _warningBg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: _warningBar, width: 4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Cambio respecto a tu patrón',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tu frecuencia cardíaca aumentó durante 8 minutos. Esto no identifica por sí solo una causa.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionSiNo({
    required String label,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? _selectedBorder : _borderColor,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSentimientosGrid() {
    final keys = _sentimientos.keys.toList();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: keys.map((key) {
        final bool seleccionado = _sentimientos[key] ?? false;
        return _buildSentimientoChip(key, seleccionado);
      }).toList(),
    );
  }

  Widget _buildSentimientoChip(String label, bool seleccionado) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() => _sentimientos[label] = !(_sentimientos[label] ?? false));
      },
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? _selectedBorder : _borderColor,
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

  Widget _buildActividadDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _actividadSeleccionada,
          isExpanded: true,
          dropdownColor: _cardColor,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: _actividades
              .map((actividad) => DropdownMenuItem(
                    value: actividad,
                    child: Text(actividad),
                  ))
              .toList(),
          onChanged: (valor) {
            if (valor != null) {
              setState(() => _actividadSeleccionada = valor);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNotaField() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: TextField(
        controller: _notaController,
        maxLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14),
          hintText: 'Escribe una nota (opcional)',
          hintStyle: TextStyle(color: _mutedText),
        ),
      ),
    );
  }
}
