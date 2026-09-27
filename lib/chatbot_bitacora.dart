import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// URL del backend que hace de intermediario seguro con el LLM
/// (ver backend/README.md para cómo correrlo y qué URL usar según
/// dónde estés probando la app: emulador Android, simulador iOS,
/// dispositivo físico o backend ya desplegado).
const String kBackendBaseUrl = 'http://127.0.0.1:8000';

/// Predicción de uno de los clasificadores locales propios, tal como la
/// regresa el backend (ver backend/classifier.py).
class PrediccionLocal {
  final String etiqueta;
  final double confianza;
  PrediccionLocal({required this.etiqueta, required this.confianza});

  factory PrediccionLocal.fromJson(Map<String, dynamic> json) {
    final rawConfianza = json['confianza'];
    return PrediccionLocal(
      etiqueta: json['etiqueta'] as String? ?? '',
      confianza: rawConfianza is num ? rawConfianza.toDouble() : 0.0,
    );
  }
}

/// Un mensaje del historial de chat, en el mismo formato que espera
/// la API de mensajes (role: 'user' | 'assistant').
class ChatMessage {
  final String role;
  final String content;
  final bool esAvisoMedico;
  final PrediccionLocal? sintomaDetectado;
  final PrediccionLocal? animoDetectado;

  ChatMessage({
    required this.role,
    required this.content,
    this.esAvisoMedico = false,
    this.sintomaDetectado,
    this.animoDetectado,
  });

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Evento de bitácora extraído por el LLM a partir de la conversación,
/// en el mismo formato de datos que ya usaba el formulario tradicional
/// (ver DesviacionAutorreporteScreen._guardarEvento).
class EventoExtraido {
  final bool estadoAlterado;
  final List<String> sentimientos;
  final int intensidad;
  final String actividad;
  final String nota;

  EventoExtraido({
    required this.estadoAlterado,
    required this.sentimientos,
    required this.intensidad,
    required this.actividad,
    required this.nota,
  });

  factory EventoExtraido.fromJson(Map<String, dynamic> json) {
    final rawIntensidad = json['intensidad'];
    return EventoExtraido(
      estadoAlterado: json['estado_alterado'] as bool? ?? false,
      sentimientos: List<String>.from(json['sentimientos'] as List? ?? const []),
      intensidad: rawIntensidad is int
          ? rawIntensidad
          : int.tryParse('$rawIntensidad') ?? 5,
      actividad: json['actividad'] as String? ?? 'Otro',
      nota: json['nota'] as String? ?? '',
    );
  }
}

class ChatbotBitacoraScreen extends StatefulWidget {
  const ChatbotBitacoraScreen({super.key});

  @override
  State<ChatbotBitacoraScreen> createState() => _ChatbotBitacoraScreenState();
}

class _ChatbotBitacoraScreenState extends State<ChatbotBitacoraScreen> {
  final List<ChatMessage> _mensajes = [
    ChatMessage(
      role: 'assistant',
      content: 'Hola, ¿cómo te has sentido en este momento?',
    ),
  ];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _enviando = false;
  String? _error;
  EventoExtraido? _eventoPendiente;

  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _accentColor = Color(0xFF7EC8E3);
  static const Color _mutedText = Color(0xFF8B96A5);
  static const Color _warningBg = Color(0xFF1B2028);
  static const Color _warningBar = Color(0xFFD98B6B);

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    final texto = _inputController.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() {
      _mensajes.add(ChatMessage(role: 'user', content: texto));
      _inputController.clear();
      _enviando = true;
      _error = null;
    });
    _scrollToEnd();

    try {
      // Historial previo a este mensaje (el backend agrega el mensaje actual).
      final historyPayload = _mensajes
          .sublist(0, _mensajes.length - 1)
          .map((m) => m.toJson())
          .toList();

      final response = await http
          .post(
            Uri.parse('$kBackendBaseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': texto, 'history': historyPayload}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('El servidor respondió ${response.statusCode}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final reply = data['reply'] as String? ?? '...';
      final extraction = data['extraction'] as Map<String, dynamic>?;
      final clasificacion = data['clasificacion_local'] as Map<String, dynamic>?;
      final avisoMedico = data['aviso_medico'] as bool? ?? false;

      setState(() {
        _mensajes.add(ChatMessage(
          role: 'assistant',
          content: reply,
          esAvisoMedico: avisoMedico,
          sintomaDetectado: clasificacion != null
              ? PrediccionLocal.fromJson(clasificacion['sintoma'] as Map<String, dynamic>)
              : null,
          animoDetectado: clasificacion != null
              ? PrediccionLocal.fromJson(clasificacion['animo'] as Map<String, dynamic>)
              : null,
        ));
        if (extraction != null) {
          _eventoPendiente = EventoExtraido.fromJson(extraction);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'No pude conectarme con el servidor. ¿Intentamos de nuevo?';
      });
    } finally {
      setState(() => _enviando = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _confirmarGuardado() {
    final evento = _eventoPendiente;
    if (evento == null) return;

    // TODO: conectar aquí con el almacenamiento real (base de datos / historial),
    // reutilizando el mismo formato que DesviacionAutorreporteScreen._guardarEvento().
    debugPrint('Estado anímico alterado: ${evento.estadoAlterado}');
    debugPrint('Sentimientos: ${evento.sentimientos}');
    debugPrint('Intensidad: ${evento.intensidad}/10');
    debugPrint('Actividad: ${evento.actividad}');
    debugPrint('Nota: ${evento.nota}');

    setState(() => _eventoPendiente = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento guardado en tu bitácora')),
    );
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
          'Bitácora conversacional',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _mensajes.length,
                itemBuilder: (context, index) => _buildBurbuja(_mensajes[index]),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            if (_eventoPendiente != null) _buildTarjetaConfirmacion(_eventoPendiente!),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBurbuja(ChatMessage mensaje) {
    final esUsuario = mensaje.role == 'user';
    final esAviso = mensaje.esAvisoMedico;
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: esUsuario ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: esUsuario ? _accentColor : (esAviso ? _warningBg : _cardColor),
              borderRadius: BorderRadius.circular(16),
              border: esUsuario
                  ? null
                  : Border.all(color: esAviso ? _warningBar : _borderColor, width: esAviso ? 1.5 : 1),
            ),
            child: Text(
              mensaje.content,
              style: TextStyle(
                color: esUsuario ? const Color(0xFF0B0F14) : Colors.white,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
          if (!esUsuario && (mensaje.sintomaDetectado != null || mensaje.animoDetectado != null))
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _resumenClasificacion(mensaje),
                style: const TextStyle(color: _mutedText, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  /// Texto pequeño de transparencia: qué detectó el modelo propio (útil para
  /// mostrar en la demo/defensa que la extracción no la "adivina" el LLM).
  String _resumenClasificacion(ChatMessage mensaje) {
    final partes = <String>[];
    final s = mensaje.sintomaDetectado;
    final a = mensaje.animoDetectado;
    if (s != null) {
      partes.add('síntoma: ${s.etiqueta} (${(s.confianza * 100).round()}%)');
    }
    if (a != null) {
      partes.add('ánimo: ${a.etiqueta} (${(a.confianza * 100).round()}%)');
    }
    return '🔎 Modelo local — ${partes.join(' · ')}';
  }

  Widget _buildTarjetaConfirmacion(EventoExtraido evento) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accentColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esto es lo que voy a guardar en tu bitácora:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text('Estado alterado: ${evento.estadoAlterado ? "Sí" : "No"}',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text('Sentimientos: ${evento.sentimientos.join(", ")}',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text('Intensidad: ${evento.intensidad}/10',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text('Actividad: ${evento.actividad}',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          if (evento.nota.isNotEmpty)
            Text('Nota: ${evento.nota}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _eventoPendiente = null),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: _borderColor)),
                  child: const Text('Descartar', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _confirmarGuardado,
                  style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Color(0xFF0B0F14), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: !_enviando,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe cómo te sientes...',
                hintStyle: const TextStyle(color: _mutedText),
                filled: true,
                fillColor: _cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _enviarMensaje(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _enviando ? null : _enviarMensaje,
            icon: _enviando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _accentColor),
                  )
                : const Icon(Icons.send, color: _accentColor),
          ),
        ],
      ),
    );
  }
}
