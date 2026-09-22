import 'package:flutter/material.dart';

class MiCorazonScreen extends StatefulWidget {
  const MiCorazonScreen({super.key});

  @override
  State<MiCorazonScreen> createState() => _MiCorazonScreenState();
}

class _MiCorazonScreenState extends State<MiCorazonScreen> {
  final int _frecuenciaCardiaca = 78;
  final String _calidadSenal = 'Señal buena';
  final int _rmssd = 34;
  final String _movimiento = 'Reposo';
  final bool _prendaConectada = true;

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
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: const Text(
          '2. Inicio y monitoreo continuo',
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
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: _prendaConectada
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _prendaConectada
                        ? 'Prenda conectada'
                        : 'Prenda desconectada',
                    style: const TextStyle(
                      color: _mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mi corazón',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildFrecuenciaCard(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('RMSSD', '$_rmssd ms'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard('Movimiento', _movimiento),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildInfoBanner(
                'Registro continuo activo. La app conserva tendencias y descarta segmentos con mala calidad.',
              ),
              const SizedBox(height: 16),

              _buildActionButton(
                icon: Icons.mood_outlined,
                label: 'Registrar cómo me siento',
                onTap: () {
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.edit_note_outlined,
                label: 'Registrar síntoma o actividad',
                onTap: () {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrecuenciaCard() {
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
                'Frecuencia cardíaca',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                child: Text(
                  _calidadSenal,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_frecuenciaCardiaca',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'lpm',
                style: TextStyle(color: _mutedText, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(

            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(
                painter: _EcgPainter(color: _accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
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
            label,
            style: const TextStyle(color: _mutedText, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white70, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final Color color;

  _EcgPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double verticalPadding = 6;
    final double drawableHeight = size.height - verticalPadding * 2;

    final Paint gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, verticalPadding + drawableHeight * 0.15),
      Offset(size.width, verticalPadding + drawableHeight * 0.15),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, verticalPadding + drawableHeight * 0.85),
      Offset(size.width, verticalPadding + drawableHeight * 0.85),
      gridPaint,
    );

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path();
    final double midY = verticalPadding + drawableHeight / 2;

    final List<Offset> patronLatido = [
      const Offset(0.0, 0.0),
      const Offset(0.12, 0.0),
      const Offset(0.16, -0.15),
      const Offset(0.20, 0.10),
      const Offset(0.24, 0.0),
      const Offset(0.32, 0.0),
      const Offset(0.36, -0.75),
      const Offset(0.40, 0.55),
      const Offset(0.44, 0.0),
      const Offset(0.55, 0.0),
      const Offset(0.60, -0.20),
      const Offset(0.64, 0.05),
      const Offset(0.68, 0.0),
      const Offset(1.0, 0.0),
    ];

    const double anchoLatido = 140;
    final int repeticiones = (size.width / anchoLatido).ceil() + 2;

    bool first = true;
    for (int rep = 0; rep < repeticiones; rep++) {
      final double offsetX = rep * anchoLatido;
      for (final punto in patronLatido) {
        final double x = offsetX + punto.dx * anchoLatido;
        final double y = midY + punto.dy * (drawableHeight * 0.45);
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, linePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) => false;
}
