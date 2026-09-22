import 'package:flutter/material.dart';

/// Contenido de la pestaña "Historial" ("6. Historia cardíaca").
/// Muestra métricas resumen (FC reposo, RMSSD), un gráfico de barras de
/// sesiones válidas por semana, un listado de sesiones recientes con su
/// porcentaje de validez, y un botón para preparar el reporte mensual.
///
/// Nota: este widget ya NO incluye Scaffold, AppBar ni barra de
/// navegación inferior propios — se muestra dentro de [MainTabScreen].
class HistorialBaseScreen extends StatefulWidget {
  const HistorialBaseScreen({super.key});

  @override
  State<HistorialBaseScreen> createState() => _HistorialBaseScreenState();
}

class _HistorialBaseScreenState extends State<HistorialBaseScreen> {
  // --- Datos de ejemplo ---
  final int _fcReposo = 74;
  final int _rmssd = 33;

  // Alturas relativas (0.0 a 1.0) de las barras semanales, de izq. a der.
  final List<double> _sesionesPorSemana = const [0.45, 0.65, 0.55, 0.85];

  final List<Map<String, String>> _sesiones = const [
    {'fecha': '12 sep · 18 h 22 min', 'validez': '92% válida'},
    {'fecha': '11 sep · 20 h 03 min', 'validez': '89% válida'},
    {'fecha': '10 sep · 17 h 48 min', 'validez': '95% válida'},
  ];

  // --- Colores del tema oscuro (según el mockup) ---
  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3);
  static const Color _barColor = Color(0xFF6E97AF);
  static const Color _mutedText = Color(0xFF8B96A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        automaticallyImplyLeading: false, // es una pestaña, no una sub-pantalla
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '6. Historia cardíaca',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Etiqueta "Seguimiento" ---
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Seguimiento',
                  style: TextStyle(color: _mutedText, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),

              // --- Título "Mi historial" + ícono filtro ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mi historial',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Abrir filtros
                    },
                    icon: const Icon(Icons.filter_list,
                        color: Colors.white70, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- FC reposo y RMSSD ---
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'FC reposo',
                      '$_fcReposo lpm',
                      'mediana mensual',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'RMSSD',
                      '$_rmssd ms',
                      'mediana mensual',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Gráfico de barras: sesiones válidas por semana ---
              _buildBarrasCard(),
              const SizedBox(height: 16),

              // --- Lista de sesiones recientes ---
              _buildListaSesiones(),
              const SizedBox(height: 20),

              // --- Botón "Preparar reporte mensual" ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para preparar el reporte mensual
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Preparar reporte mensual',
                    style: TextStyle(
                      color: Color(0xFF0B0F14),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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

  Widget _buildMetricCard(String label, String valor, String nota) {
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
          Text(label, style: const TextStyle(color: _mutedText, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(nota, style: const TextStyle(color: _mutedText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBarrasCard() {
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
            'Sesiones válidas por semana',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_sesionesPorSemana.length, (index) {
                final double alturaRel = _sesionesPorSemana[index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FractionallySizedBox(
                      heightFactor: alturaRel.clamp(0.05, 1.0),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _barColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaSesiones() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _sesiones.length; i++) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _sesiones[i]['fecha']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Text(
                      _sesiones[i]['validez']!,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            if (i != _sesiones.length - 1)
              const Divider(color: _borderColor, height: 1),
          ],
        ],
      ),
    );
  }
}
