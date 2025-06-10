import 'package:flutter/material.dart';
import 'login_page.dart';
import 'producto_list.dart';
import 'producto_form.dart';
import 'calculator_page.dart';
import 'messages_page.dart';

void main() => runApp(const MiApp());

class MiApp extends StatefulWidget {
  const MiApp({super.key});

  @override
  State<MiApp> createState() => _MiAppState();
}

class _MiAppState extends State<MiApp> {
  String? _token;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productos App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: _token == null
          ? LoginPage(
        onLogin: (token) {
          setState(() {
            _token = token;
          });
        },
      )
          : HomePage(token: _token!),
    );
  }
}

class HomePage extends StatelessWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú Principal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Lista de Productos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductosList(token: token),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Calculadora de Cabeza Dinámica Total'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalculadoraCabezaPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Listado de Mensajes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MensajesPage(token: token),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
