import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'producto_form.dart'; 

class ProductosList extends StatefulWidget {
  final String token;
  const ProductosList({super.key, required this.token});

  @override
  State<ProductosList> createState() => _ProductosListState();
}

class _ProductosListState extends State<ProductosList> {
  final String baseUrl = 'https://hidrotek.onrender.com/api';
  List<dynamic> productos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/productos/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        productos = json.decode(response.body);
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar productos')),
      );
    }
  }

  void abrirFormulario([int? productoId]) async {
    // Navega a ProductoForm y espera resultado para recargar lista
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoForm(
          productoId: productoId,
          token: widget.token,
        ),
      ),
    );

    if (resultado == true) {
      cargarProductos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        backgroundColor: azul,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: cargarProductos,
        child: ListView.builder(
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index];
            final imagenUrl = producto['imagen'] ?? '';

            return ListTile(
              leading: imagenUrl.isNotEmpty
                  ? Image.network(imagenUrl, width: 50, height: 50, fit: BoxFit.cover)
                  : Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported),
              ),
              title: Text(producto['nombre'] ?? 'Sin nombre'),
              subtitle: Text('Precio: \$${producto['precio'].toString()}'),
              onTap: () => abrirFormulario(producto['id']),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(null),
        backgroundColor: azul,
        child: const Icon(Icons.add),
        tooltip: 'Crear producto',
      ),
    );
  }
}
