import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io' show Platform;

class MensajesPage extends StatefulWidget {
  final String token;

  const MensajesPage({super.key, required this.token});

  @override
  _MensajesPageState createState() => _MensajesPageState();
}

class _MensajesPageState extends State<MensajesPage> {
  List mensajes = [];
  List leidos = [];
  List noLeidos = [];

  @override
  void initState() {
    super.initState();
    fetchMensajes();
  }

  Future<void> fetchMensajes() async {
    final url = Uri.parse('https://hidrotek.onrender.com/api/contact-messages/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        mensajes = data;
        // Si tu backend tiene un campo 'leido', úsalo aquí:
        leidos = mensajes.where((m) => m['leido'] == true).toList();
        noLeidos = mensajes.where((m) => m['leido'] != true).toList();
      });
    } else {
      print('Error al cargar los mensajes: ${response.statusCode}');
    }
  }

  void marcarComoLeido(int index) {
    setState(() {
      final mensaje = noLeidos.removeAt(index);
      mensaje['leido'] = true;
      leidos.insert(0, mensaje);
    });
  }

  void _abrirWhatsApp(String numero) async {
    final numeroLimpio = numero.replaceAll(RegExp(r'\D'), '');
    final mensaje = ""; // Puedes personalizar el mensaje si quieres
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: 'https://wa.me/$numeroLimpio?text=$mensaje',
        package: 'com.whatsapp',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } else {
      final uri = Uri.parse('https://wa.me/$numeroLimpio?text=$mensaje');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _enviarCorreo(String correo) async {
  if (Platform.isAndroid) {
    final intent = AndroidIntent(
      action: 'action_view', // <-- Cambia aquí
      data: 'mailto:$correo',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  } else {
    final uri = Uri(
      scheme: 'mailto',
      path: correo,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No leídos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: noLeidos.length,
              itemBuilder: (context, index) {
                final mensaje = noLeidos[index];
                return Dismissible(
                  key: Key(mensaje['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    marcarComoLeido(index);
                  },
                  child: _buildMensajeCard(mensaje),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Leídos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: leidos.length,
              itemBuilder: (context, index) {
                final mensaje = leidos[index];
                return _buildMensajeCard(mensaje);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensajeCard(dynamic mensaje) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '${mensaje['nombre'] ?? ''} ${mensaje['apellido'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (mensaje['email'] != null && mensaje['email'].toString().isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.green),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _enviarCorreo(mensaje['email']),
                    child: Text(
                      mensaje['email'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (mensaje['telefono'] != null && mensaje['telefono'].toString().isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.orange),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _abrirWhatsApp(mensaje['telefono'].toString()),
                    child: Text(
                      mensaje['telefono'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.green,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            const Divider(height: 24),
            Text(
              mensaje['mensaje'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
