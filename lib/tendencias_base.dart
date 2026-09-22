import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Contenido de la pestaña "Tendencias" ("4. Tendencias cruzadas").
/// Muestra la evolución de FC/VFC vs. estado anímico en el tiempo,
/// junto con coincidencias observadas entre eventos y mediciones.
///
/// Nota: este widget ya NO incluye Scaffold, AppBar ni barra de
/// navegación inferior propios — se muestra dentro de [MainTabScreen].
class TendenciasBaseScreen extends StatefulWidget {
  const TendenciasBaseScreen({super.key});

  @override
  State<TendenciasBaseScreen> createState() => _TendenciasBaseScreenState();
}

class _TendenciasBaseScreenState extends State<TendenciasBaseScreen> {
  // --- Rango seleccionado: true = 30 días, false = 7 días ---
  bool _rango30Dias = true;

  // --- Coincidencias observadas (ejemplo) ---
  final List<Map<String, String>> _coincidencias = const [
    {'label': 'Estrés', 'valor': '6 eventos'},
    {'label': 'Enojo', 'valor': '3 eventos'},
    {'label': 'Sueño insuficiente', 'valor': '5 días'},
  ];

  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3); // celeste FC/VFC
  static const Color _altColor = Color(0xFFE79E8B); // rosa Estado alterado
  static const Color _mutedText = Color(0xFF8B96A5);
  static const Color _selectedBorder = Color(0xFF9FD8EE);

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
          '4. Tendencias cruzadas',
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
              // --- Etiqueta "Últimos 30 días" ---
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _rango30Dias ? 'Últimos 30 días' : 'Últimos 7 días',
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // --- Título "Tendencias" + ícono calendario ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tendencias',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Abrir selector de fechas
                    },
                    icon: const Icon(Icons.calendar_today_outlined,
                        color: Colors.white70, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- Selector de rango 7 días / 30 días ---
              _buildRangoSelector(),
              const SizedBox(height: 16),

              // --- Tarjeta de gráfico ---
              _buildGraficoCard(),
              const SizedBox(height: 16),

              // --- Tarjeta de coincidencias observadas ---
              _buildCoincidenciasCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // WIDGETS AUXILIARES
  // ---------------------------------------------------------------------

  Widget _buildRangoSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildRangoOption(
            label: '7 días',
            seleccionado: !_rango30Dias,
            onTap: () => setState(() => _rango30Dias = false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRangoOption(
            label: '30 días',
            seleccionado: _rango30Dias,
            onTap: () => setState(() => _rango30Dias = true),
          ),
        ),
      ],
    );
  }

  Widget _buildRangoOption({
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

  Widget _buildGraficoCard() {
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
              const Expanded(
                child: Text(
                  'Mediciones y estado anímico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                child: const Text(
                  'Mensual',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Gráfico de líneas (recortado para no salir del borde) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(
                painter: _TendenciasChartPainter(
                  colorPrincipal: _accentColor,
                  colorAlterado: _altColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- Leyenda ---
          Row(
            children: [
              _buildLeyendaItem('FC/VFC', _accentColor),
              const SizedBox(width: 20),
              _buildLeyendaItem('Estado alterado', _altColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeyendaItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCoincidenciasCard() {
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
            'Coincidencias observadas',
            style: TextStyle(color: _mutedText, fontSize: 13),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < _coincidencias.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _coincidencias[i]['label']!,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  Text(
                    _coincidencias[i]['valor']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (i != _coincidencias.length - 1)
              const Divider(color: _borderColor, height: 1),
          ],
          const SizedBox(height: 8),
          const Text(
            'Coincidencia temporal, no relación causal.',
            style: TextStyle(color: _mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Dibuja las dos curvas de tendencia (FC/VFC sólida y Estado alterado
/// punteada) junto con puntos marcadores sobre la línea punteada,
/// tal como en el mockup.
class _TendenciasChartPainter extends CustomPainter {
  final Color colorPrincipal;
  final Color colorAlterado;

  _TendenciasChartPainter({
    required this.colorPrincipal,
    required this.colorAlterado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double verticalPadding = 8;
    final double h = size.height - verticalPadding * 2;
    final double w = size.width;

    // --- Líneas guía horizontales ---
    final Paint gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, verticalPadding + h * 0.2),
      Offset(w, verticalPadding + h * 0.2),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, verticalPadding + h * 0.8),
      Offset(w, verticalPadding + h * 0.8),
      gridPaint,
    );

    Offset puntoRelativo(double xRel, double yRel) {
      return Offset(xRel * w, verticalPadding + yRel * h);
    }

    // --- Curva principal (FC/VFC) sólida, con dos "jorobas" ---
    final List<Offset> puntosPrincipal = [
      puntoRelativo(0.00, 0.55),
      puntoRelativo(0.15, 0.30),
      puntoRelativo(0.30, 0.15),
      puntoRelativo(0.45, 0.45),
      puntoRelativo(0.60, 0.60),
      puntoRelativo(0.72, 0.30),
      puntoRelativo(0.85, 0.20),
      puntoRelativo(1.00, 0.40),
    ];

    final Path pathPrincipal = _construirCurvaSuave(puntosPrincipal);
    final Paint paintPrincipal = Paint()
      ..color = colorPrincipal
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(pathPrincipal, paintPrincipal);

    // --- Curva de estado alterado (punteada), más plana ---
    final List<Offset> puntosAlterado = [
      puntoRelativo(0.00, 0.65),
      puntoRelativo(0.20, 0.72),
      puntoRelativo(0.38, 0.55),
      puntoRelativo(0.55, 0.40),
      puntoRelativo(0.75, 0.55),
      puntoRelativo(1.00, 0.45),
    ];
    final Path pathAlterado = _construirCurvaSuave(puntosAlterado);
    final Paint paintAlterado = Paint()
      ..color = colorAlterado
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _dibujarLineaPunteada(canvas, pathAlterado, paintAlterado);

    // --- Puntos marcadores sobre la línea de estado alterado ---
    final Paint dotPaint = Paint()..color = colorAlterado;
    for (final xRel in [0.20, 0.38, 0.55]) {
      final metric = pathAlterado.computeMetrics().first;
      final double target = xRel * metric.length;
      final ui.Tangent? tangent = metric.getTangentForOffset(target);
      if (tangent != null) {
        canvas.drawCircle(tangent.position, 4.5, dotPaint);
      }
    }

    // Recorta cualquier exceso por fuera del área disponible.
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  /// Construye una curva suave (spline simple con curvas cuadráticas)
  /// que pasa por los puntos dados.
  Path _construirCurvaSuave(List<Offset> puntos) {
    final Path path = Path();
    if (puntos.isEmpty) return path;
    path.moveTo(puntos.first.dx, puntos.first.dy);
    for (int i = 0; i < puntos.length - 1; i++) {
      final Offset actual = puntos[i];
      final Offset siguiente = puntos[i + 1];
      final Offset medio = Offset(
        (actual.dx + siguiente.dx) / 2,
        (actual.dy + siguiente.dy) / 2,
      );
      path.quadraticBezierTo(actual.dx, actual.dy, medio.dx, medio.dy);
    }
    path.lineTo(puntos.last.dx, puntos.last.dy);
    return path;
  }

  /// Dibuja un [path] como línea punteada, extrayendo segmentos cortos
  /// a lo largo de su longitud total.
  void _dibujarLineaPunteada(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 5;
    const double dashSpace = 4;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double siguiente = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(
            distance,
            siguiente.clamp(0, metric.length),
          ),
          paint,
        );
        distance = siguiente + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TendenciasChartPainter oldDelegate) => false;
}
