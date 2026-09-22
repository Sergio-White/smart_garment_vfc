import 'package:flutter/material.dart';
import 'data/data_source.dart';
import 'main_tab_screen.dart';
import 'desviacion_autorreporte.dart';
import 'detalle_de_un_dia.dart';
import 'orientacion_perfil.dart';
import 'reporte_mensual.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataSource fuente = SimulatedDataSource();
  double? meanHR;
  final List<int> rrBuffer = [];

  @override
  void initState() {
    super.initState();
    fuente.start();
    fuente.rrStream.listen((packet) {
      if (packet.isValid) {
        rrBuffer.add(packet.rrIntervalMs);
        setState(() {
          meanHR = 60000 / (rrBuffer.reduce((a, b) => a + b) / rrBuffer.length);
        });
      }
    });
  }

  @override
  void dispose() {
    fuente.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.apps, size: 18),
                    label: const Text('Ver App completa'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MainTabScreen()),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.report_gmailerrorred_outlined,
                        size: 18),
                    label: const Text('Ver Autorreporte'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DesviacionAutorreporteScreen(),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_view_day_outlined,
                        size: 18),
                    label: const Text('Ver Detalle del día'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DetalleDiaScreen()),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.favorite_outline, size: 18),
                    label: const Text('Ver Orientación'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrientacionPerfilScreen()),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('Ver Reporte mensual'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReporteMensualScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Text(
                  meanHR == null
                      ? 'Esperando datos...'
                      : '${meanHR!.toStringAsFixed(0)} BPM',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
