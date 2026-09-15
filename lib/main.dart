import 'package:flutter/material.dart';
import 'data/data_source.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Garment VFC',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      body: Center(
        child: Text(meanHR == null ? 'Esperando datos...' : '${meanHR!.toStringAsFixed(0)} BPM'),
      ),
    );
  }
}