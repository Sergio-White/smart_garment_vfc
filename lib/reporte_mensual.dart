import 'package:flutter/material.dart';

class ReporteMensualScreen extends StatefulWidget {
  const ReporteMensualScreen({super.key});

  @override
  State<ReporteMensualScreen> createState() => _ReporteMensualScreenState();
}

class _ReporteMensualScreenState extends State<ReporteMensualScreen> {

  final String _rangoFechas = '1 ago – 31 ago';

  final List<Map<String, String>> _resumen = const [
    {'label': 'Tiempo registrado', 'valor': '476 h'},
    {'label': 'Señal válida', 'valor': '91%'},
    {'label': 'Eventos emocionales', 'valor': '14'},
    {'label': 'Síntomas registrados', 'valor': '3'},
  ];

  final Map<String, bool> _seccionesPdf = {
    'Resumen y tendencias': true,
    'FC, RR, RMSSD y SDNN': true,
    'Actividad y estado anímico': true,
    'Síntomas y notas': true,
    'Calidad y datos excluidos': true,
  };

  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3);
  static const Color _mutedText = Color(0xFF8B96A5);
  static const Color _infoBg = Color(0xFF1C2733);
  static const Color _infoBar = Color(0xFF5FA8D3);

  void _descargarPdf() {
    final secciones =
        _seccionesPdf.entries.where((e) => e.value).map((e) => e.key).toList();

    debugPrint('Generando PDF con secciones: $secciones');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando PDF...')),
    );
  }

  void _compartirArchivo() {

    debugPrint('Compartiendo archivo...');
  }

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
          'Vista previa del reporte',
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
            icon: const Icon(Icons.description_outlined, color: Colors.white70),
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
                  _rangoFechas,
                  style: const TextStyle(color: _mutedText, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),

              _buildResumenCard(),
              const SizedBox(height: 16),

              _buildIncluirPdfCard(),
              const SizedBox(height: 16),

              _buildAvisoPrototipo(),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _descargarPdf,
                  icon: const Icon(Icons.file_download_outlined,
                      color: Color(0xFF0B0F14)),
                  label: const Text(
                    'Descargar PDF',
                    style: TextStyle(
                      color: Color(0xFF0B0F14),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _compartirArchivo,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Compartir archivo',
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

  Widget _buildResumenCard() {
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
            'Resumen del periodo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final fila in _resumen)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fila['label']!,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  Text(
                    fila['valor']!,
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

  Widget _buildIncluirPdfCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 14, bottom: 4),
            child: Text(
              'Incluir en PDF',
              style: TextStyle(color: _mutedText, fontSize: 13),
            ),
          ),
          for (final entrada in _seccionesPdf.entries)
            CheckboxListTile(
              value: entrada.value,
              onChanged: (valor) {
                setState(() => _seccionesPdf[entrada.key] = valor ?? false);
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.trailing,
              activeColor: _accentColor,
              checkColor: const Color(0xFF0B0F14),
              side: const BorderSide(color: _borderColor),
              title: Text(
                entrada.key,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildAvisoPrototipo() {
    return Container(
      decoration: BoxDecoration(
        color: _infoBg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: _infoBar, width: 4)),
      ),
      padding: const EdgeInsets.all(14),
      child: const Text(
        'El documento indicará que procede de un prototipo y no equivale a un estudio diagnóstico.',
        style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
      ),
    );
  }
}
