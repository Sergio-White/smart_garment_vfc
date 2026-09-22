import 'package:flutter/material.dart';

class DetalleDiaScreen extends StatefulWidget {
  const DetalleDiaScreen({super.key});

  @override
  State<DetalleDiaScreen> createState() => _DetalleDiaScreenState();
}

class _DetalleDiaScreenState extends State<DetalleDiaScreen> {
  final String _fecha = '12 de septiembre';

  final List<Map<String, String>> _eventos = const [
    {'hora': '08:10', 'label': 'Sueño insuficiente', 'valor': '6/10'},
    {'hora': '13:42', 'label': 'Caminata', 'valor': '20 min'},
    {'hora': '17:18', 'label': 'Estrés', 'valor': '7/10'},
  ];

  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3);
  static const Color _altColor = Color(0xFFE79E8B);
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Actividad del día',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
            },
            icon: const Icon(Icons.more_horiz, color: Colors.white70),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _fecha,
                  style: const TextStyle(color: _mutedText, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),

              _buildGraficoCard(),
              const SizedBox(height: 16),

              _buildEventosCard(),
              const SizedBox(height: 16),

              _buildInfoBanner(
                'A las 17:18 hubo una elevación respecto a tu línea base mientras el movimiento era bajo.',
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ver señal y calidad',
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
          const Text(
            'Frecuencia cardíaca y movimiento',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(
                painter: _DetalleDiaChartPainter(
                  colorFc: _accentColor,
                  colorMovimiento: _altColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildLeyendaItem('FC', _accentColor),
              const SizedBox(width: 20),
              _buildLeyendaItem('Movimiento', _altColor),
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

  Widget _buildEventosCard() {
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
            'Eventos registrados',
            style: TextStyle(color: _mutedText, fontSize: 13),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < _eventos.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_eventos[i]['hora']} · ${_eventos[i]['label']}',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  Text(
                    _eventos[i]['valor']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(String text) {
    return Container(
      decoration: BoxDecoration(
        color: _infoBg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: _infoBar, width: 4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
      ),
    );
  }
}

class _DetalleDiaChartPainter extends CustomPainter {
  final Color colorFc;
  final Color colorMovimiento;

  _DetalleDiaChartPainter({
    required this.colorFc,
    required this.colorMovimiento,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double verticalPadding = 8;
    final double h = size.height - verticalPadding * 2;
    final double w = size.width;

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

    final List<Offset> puntosFc = [
      puntoRelativo(0.00, 0.65),
      puntoRelativo(0.15, 0.55),
      puntoRelativo(0.30, 0.20),
      puntoRelativo(0.45, 0.55),
      puntoRelativo(0.60, 0.65),
      puntoRelativo(0.68, 0.08),
      puntoRelativo(0.80, 0.55),
      puntoRelativo(0.90, 0.60),
      puntoRelativo(1.00, 0.50),
    ];
    final Path pathFc = _construirCurvaSuave(puntosFc);
    final Paint paintFc = Paint()
      ..color = colorFc
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(pathFc, paintFc);

    final List<Offset> puntosMovimiento = [
      puntoRelativo(0.00, 0.75),
      puntoRelativo(0.18, 0.78),
      puntoRelativo(0.32, 0.45),
      puntoRelativo(0.46, 0.70),
      puntoRelativo(0.62, 0.78),
      puntoRelativo(0.72, 0.42),
      puntoRelativo(0.85, 0.72),
      puntoRelativo(1.00, 0.70),
    ];
    final Path pathMovimiento = _construirCurvaSuave(puntosMovimiento);
    final Paint paintMovimiento = Paint()
      ..color = colorMovimiento
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _dibujarLineaPunteada(canvas, pathMovimiento, paintMovimiento);

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
  }

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
  bool shouldRepaint(covariant _DetalleDiaChartPainter oldDelegate) => false;
}
