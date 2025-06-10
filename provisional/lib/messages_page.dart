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
          return ListTile(
            title: Text(mensaje['nombre']),
            subtitle: Text(mensaje['mensaje']),
          );
        },
      ),
    );
  }
}
