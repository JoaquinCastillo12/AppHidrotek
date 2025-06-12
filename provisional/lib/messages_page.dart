import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: ListView.builder(
        itemCount: mensajes.length,
        itemBuilder: (context, index) {
          final mensaje = mensajes[index];
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
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(mensaje['email'] ?? '', style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(mensaje['telefono'] ?? '', style: const TextStyle(fontSize: 15)),
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
        },
      ),
    );
  }
}
