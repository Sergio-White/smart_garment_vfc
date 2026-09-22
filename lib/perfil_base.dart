import 'package:flutter/material.dart';

class PerfilBaseScreen extends StatefulWidget {
  const PerfilBaseScreen({super.key});

  @override
  State<PerfilBaseScreen> createState() => _PerfilBaseScreenState();
}

class _PerfilBaseScreenState extends State<PerfilBaseScreen> {
  // --- Estado del dispositivo (ejemplo) ---
  bool _dispositivoConectado = true;
  final int _bateria = 84;

  // --- Opciones de configuración con navegación por chevron ---
  final List<String> _opciones = const [
    'Mi perfil e IMC',
    'Plan médico y síntomas de alarma',
    'Notificaciones',
    'Privacidad y consentimiento',
    'Exportar todos mis datos',
    'Eliminar mis datos',
  ];

  // --- Colores del tema oscuro (según el mockup) ---
  static const Color _bgColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF141A22);
  static const Color _borderColor = Color(0xFF2A3340);
  static const Color _mutedText = Color(0xFF8B96A5);
  static const Color _warningBg = Color(0xFF20222A);
  static const Color _warningBar = Color(0xFFD98B6B);

  void _mostrarDesconexion() {
    setState(() => _dispositivoConectado = !_dispositivoConectado);
  }

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
          '9. Dispositivo, privacidad y ayuda',
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
              // --- Etiqueta "Perfil" ---
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Perfil',
                  style: TextStyle(color: _mutedText, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),

              // --- Título "Configuración" + ícono de persona ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Configuración',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.person_outline, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 16),

              // --- Tarjeta del dispositivo conectado ---
              _buildDispositivoCard(),
              const SizedBox(height: 16),

              // --- Lista de opciones de configuración ---
              _buildListaOpciones(),
              const SizedBox(height: 16),

              // --- Aviso de emergencia ---
              _buildAvisoEmergencia(),
              const SizedBox(height: 16),

              // --- Botón "Ayuda y alcance del prototipo" ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // Abrir ayuda / alcance del prototipo
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ayuda y alcance del prototipo',
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

  Widget _buildDispositivoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Garment VFC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dispositivoConectado
                      ? 'Conectado · batería $_bateria%'
                      : 'Desconectado',
                  style: const TextStyle(color: _mutedText, fontSize: 13),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _mostrarDesconexion,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              _dispositivoConectado ? 'Desconectar' : 'Conectar',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaOpciones() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _opciones.length; i++) ...[
            InkWell(
              borderRadius: i == 0
                  ? const BorderRadius.vertical(top: Radius.circular(14))
                  : i == _opciones.length - 1
                      ? const BorderRadius.vertical(
                          bottom: Radius.circular(14))
                      : BorderRadius.zero,
              onTap: () {
                // Navegar a la sub-pantalla correspondiente
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _opciones[i],
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Icon(Icons.chevron_right,
                        color: _mutedText, size: 20),
                  ],
                ),
              ),
            ),
            if (i != _opciones.length - 1)
              const Divider(color: _borderColor, height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildAvisoEmergencia() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 46, 75, 114),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: const Color.fromARGB(255, 214, 108, 89), width: 4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '¿Tienes dolor torácico, falta de aire intensa o desmayo?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'La app no puede confirmar ni descartar una urgencia. Sigue tu plan médico o solicita atención de emergencia.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
