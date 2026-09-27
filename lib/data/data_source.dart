import 'dart:async';
import 'dart:math';
// 
// MODELOS DE DATOS — mismo formato que los paquetes BLE definidos
// 

/// Representa un latido individual recibido (real o simulado).
class RRPacket {
  final int seq;              // número de secuencia
  final int timestampMs;      // tiempo relativo al origen del stream
  final int rrIntervalMs;     // intervalo RR en milisegundos
  final int qualityFlag;      // bitfield: bit0=contacto débil,
                               // bit1=artefacto movimiento,
                               // bit2=RR fuera de rango, bit3=batería baja
  final int rAmplitude;       // amplitud relativa del pico R

  RRPacket({
    required this.seq,
    required this.timestampMs,
    required this.rrIntervalMs,
    required this.qualityFlag,
    required this.rAmplitude,
  });

  bool get isValid => qualityFlag == 0;
}

/// Muestra de contexto de movimiento.
class MotionPacket {
  final int seq;
  final int timestampMs;
  final double accelMagnitudeAvg;
  final int motionClass; // 0=reposo, 1=leve, 2=intenso

  MotionPacket({
    required this.seq,
    required this.timestampMs,
    required this.accelMagnitudeAvg,
    required this.motionClass,
  });
}

/// Estado general del dispositivo.
class DeviceStatus {
  final int batteryPct;
  final int electrodeContact;
  final int errorCode;
  final int uptimeS;

  DeviceStatus({
    required this.batteryPct,
    required this.electrodeContact,
    required this.errorCode,
    required this.uptimeS,
  });
}

// 
// INTERFAZ ABSTRACTA — el contrato que ambas fuentes deben cumplir
// 

/// Contrato común para cualquier fuente de datos fisiológicos,
/// sea el simulador o el dispositivo BLE real.
/// El resto de la app (cálculo de métricas, base de datos, UI)
/// depende únicamente de esta interfaz, nunca de la implementación.
abstract class DataSource {
  /// Stream continuo de paquetes RR (uno por latido).
  Stream<RRPacket> get rrStream;

  /// Stream continuo de contexto de movimiento.
  Stream<MotionPacket> get motionStream;

  /// Stream de estado del dispositivo (batería, errores, etc.)
  Stream<DeviceStatus> get statusStream;

  /// Indica si la fuente está actualmente "conectada" (real o simulada).
  bool get isConnected;

  /// Inicia la fuente de datos (conectar BLE real, o arrancar el timer del simulador).
  Future<void> start();

  /// Detiene la fuente y libera recursos.
  Future<void> stop();
}

// 
// Simulador (úsala mientras no hay hardware)
// 

class SimulatedDataSource implements DataSource {
  final _rrController = StreamController<RRPacket>.broadcast();
  final _motionController = StreamController<MotionPacket>.broadcast();
  final _statusController = StreamController<DeviceStatus>.broadcast();

  Timer? _rrTimer;
  Timer? _motionTimer;
  Timer? _statusTimer;
  Timer? _modeTimer;

  int _seqRR = 0;
  int _seqMotion = 0;
  int _elapsedMs = 0;
  double _currentBaseRR = 850; // ms, ~70 BPM en reposo
  final Random _rand = Random();

  @override
  Stream<RRPacket> get rrStream => _rrController.stream;

  @override
  Stream<MotionPacket> get motionStream => _motionController.stream;

  @override
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  @override
  bool get isConnected => _rrTimer != null;

  @override
  Future<void> start() async {
    // Cambia el RR base cada ~20s para simular reposo/actividad
    _modeTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _currentBaseRR = _rand.nextBool() ? 850 : 500;
    });

    _rrTimer = Timer.periodic(Duration(milliseconds: _currentBaseRR.toInt()), (_) {
      _elapsedMs += _currentBaseRR.toInt();

      // Simula hueco de secuencia ocasional (1% de probabilidad)
      final skipSeq = _rand.nextDouble() < 0.01;
      _seqRR += skipSeq ? 2 : 1;

      // Ruido gaussiano-like aproximado sobre el RR base
      final noise = (_rand.nextDouble() - 0.5) * 60; // ±30ms aprox
      final rr = (_currentBaseRR + noise).round();

      // Simula mala calidad ocasional (3% de probabilidad)
      final quality = _rand.nextDouble() < 0.03 ? 1 : 0;

      _rrController.add(RRPacket(
        seq: _seqRR,
        timestampMs: _elapsedMs,
        rrIntervalMs: rr,
        qualityFlag: quality,
        rAmplitude: 800 + _rand.nextInt(200),
      ));
    });

    _motionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _seqMotion++;
      final motionClass = _currentBaseRR < 700 ? 2 : 0;
      _motionController.add(MotionPacket(
        seq: _seqMotion,
        timestampMs: _elapsedMs,
        accelMagnitudeAvg: motionClass == 2 ? 1.8 : 0.2,
        motionClass: motionClass,
      ));
    });

    _statusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _statusController.add(DeviceStatus(
        batteryPct: 90,
        electrodeContact: 0x03, // ambos electrodos ok
        errorCode: 0,
        uptimeS: _elapsedMs ~/ 1000,
      ));
    });
  }

  @override
  Future<void> stop() async {
    _rrTimer?.cancel();
    _motionTimer?.cancel();
    _statusTimer?.cancel();
    _modeTimer?.cancel();
  }
}

// 
// BLE real (esqueleto, se completa con el hardware)
// 

class BleDataSource implements DataSource {
  final _rrController = StreamController<RRPacket>.broadcast();
  final _motionController = StreamController<MotionPacket>.broadcast();
  final _statusController = StreamController<DeviceStatus>.broadcast();

 final bool _connected = false;

  @override
  Stream<RRPacket> get rrStream => _rrController.stream;

  @override
  Stream<MotionPacket> get motionStream => _motionController.stream;

  @override
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> start() async {
    // TODO cuando el hardware esté listo:
    // Escanear y conectar con flutter
    // Suscribirse a las 3 características (RR_STREAM, MOTION_STREAM, DEVICE_STATUS)
    // Parsear cada paquete de bytes (little-endian) al modelo correspondiente
    //    y emitirlo por el controller respectivo.
    // El resto de la app NO CAMBIA — sigue consumiendo rrStream/motionStream/statusStream.
    throw UnimplementedError('Pendiente de integración con hardware real');
  }

  @override
  Future<void> stop() async {
    // TODO: desconectar BLE
  }
}
