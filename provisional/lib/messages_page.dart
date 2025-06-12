import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MensajesPage extends StatefulWidget {
  final String token;

  const MensajesPage({super.key, required this.token});

  @override
  _MensajesPageState createState() => _MensajesPageState();
}

class _MensajesPageState extends State<MensajesPage> {
  List mensajes = [];

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
      setState(() {
        mensajes = jsonDecode(response.body);
      });
    } else {
      print('Error al cargar los mensajes: ${response.statusCode}');
    }
  }

  void _abrirWhatsApp(String numero) async {
    final uri = Uri.parse('https://wa.me/$numero');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _enviarCorreo(String correo) async {
    final uri = Uri(
      scheme: 'mailto',
      path: correo,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: ListView.builder(
        itemCount: mensajes.length,
        itemBuilder: (context, index) {
          final mensaje = mensajes[index];
          return ListTile(
            title: Text(mensaje['nombre']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mensaje['mensaje']),
                if (mensaje['telefono'] != null && mensaje['telefono'].toString().isNotEmpty)
                  GestureDetector(
                    onTap: () => _abrirWhatsApp(mensaje['telefono'].toString().replaceAll(RegExp(r'\D'), '')),
                    child: Text(
                      mensaje['telefono'],
                      style: const TextStyle(color: Colors.green, decoration: TextDecoration.underline),
                    ),
                  ),
                if (mensaje['correo'] != null && mensaje['correo'].toString().isNotEmpty)
                  GestureDetector(
                    onTap: () => _enviarCorreo(mensaje['correo']),
                    child: Text(
                      mensaje['correo'],
                      style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
