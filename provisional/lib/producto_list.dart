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
  final String baseUrl = 'https://apigo.online/api';
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

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: (imagenUrl != null && imagenUrl.toString().isNotEmpty && Uri.tryParse(imagenUrl)?.hasAbsolutePath == true)
                                    ? Image.network(
                                        imagenUrl,
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: double.infinity,
                                          height: 180,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.image_not_supported, size: 60),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 180,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.image_not_supported, size: 60),
                                      ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      tooltip: 'Editar',
                                      onPressed: () => abrirFormulario(producto['id']),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.blueAccent.withOpacity(0.8),
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.white),
                                      tooltip: 'Borrar',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('La opción de borrar no está habilitada.')),
                                        );
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            producto['nombre'] ?? 'Sin nombre',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text('Precio: \$${producto['precio'].toString()}'),
                        ],
                      ),
                    ),
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

  // Agrega esta función al final de tu clase:
  Future<void> borrarProducto(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/productos/$id/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 204) {
      cargarProductos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto borrado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al borrar producto')),
      );
    }
  }
}
