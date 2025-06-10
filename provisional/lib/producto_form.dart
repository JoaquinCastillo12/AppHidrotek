import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ProductoForm extends StatefulWidget {
  final int? productoId;
  final String token;

  const ProductoForm({super.key, this.productoId, required this.token});

  @override
  State<ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();

  final String baseUrl = 'https://hidrotek.onrender.com/api';

  List<dynamic> _categorias = [];
  List<dynamic> _marcas = [];
  int? _categoriaSeleccionada;
  int? _marcaSeleccionada;
  File? _imagenFile;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
    cargarMarcas();
    if (widget.productoId != null) {
      cargarProducto(widget.productoId!);
    }
  }

  Future<void> cargarCategorias() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categoria/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      final categorias = json.decode(response.body);
      setState(() {
        _categorias = categorias;
        if (_categorias.isNotEmpty && _categoriaSeleccionada == null) {
          _categoriaSeleccionada = _categorias[0]['id'];
        }
      });
    }
  }

  Future<void> cargarMarcas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/marca/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      final marcas = json.decode(response.body);
      setState(() {
        _marcas = marcas;
        if (_marcas.isNotEmpty && _marcaSeleccionada == null) {
          _marcaSeleccionada = _marcas[0]['id'];
        }
      });
    }
  }

  Future<void> cargarProducto(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/productos/$id/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _nombreController.text = data['nombre'] ?? '';
        _descripcionController.text = data['descripcion'] ?? '';
        _precioController.text = data['precio'].toString();
        _stockController.text = data['stock'].toString();
        _categoriaSeleccionada = data['categoria'];
        _marcaSeleccionada = data['marca'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagenFile = File(pickedFile.path);
      });
    }
  }

  Future<void> guardarProducto() async {
    final uri = widget.productoId == null
        ? Uri.parse('$baseUrl/productos/add/')
        : Uri.parse('$baseUrl/productos/${widget.productoId}/update/');

    final request = http.MultipartRequest(
      widget.productoId == null ? 'POST' : 'PUT',
      uri,
    );
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    request.fields['nombre'] = _nombreController.text;
    request.fields['descripcion'] = _descripcionController.text;
    request.fields['precio'] = _precioController.text;
    request.fields['stock'] = _stockController.text;
    request.fields['categoria'] = _categoriaSeleccionada.toString();
    request.fields['marca'] = _marcaSeleccionada.toString();

    if (_imagenFile != null) {
      request.files.add(await http.MultipartFile.fromPath('imagen', _imagenFile!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto guardado correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el producto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productoId == null ? 'Crear Producto' : 'Editar Producto'),
        backgroundColor: azul,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildCampoTexto('Nombre', _nombreController),
              buildCampoTexto('Descripción', _descripcionController),
              buildCampoTexto('Precio', _precioController, tipo: TextInputType.number),
              buildCampoTexto('Stock', _stockController, tipo: TextInputType.number),
              const SizedBox(height: 16),
              buildDropdown(
                label: 'Categoría',
                items: _categorias,
                value: _categoriaSeleccionada,
                onChanged: (value) => setState(() => _categoriaSeleccionada = value),
              ),
              const SizedBox(height: 16),
              buildDropdown(
                label: 'Marca',
                items: _marcas,
                value: _marcaSeleccionada,
                onChanged: (value) => setState(() => _marcaSeleccionada = value),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _imagenFile == null
                    ? Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: azul),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Toca para tomar o elegir imagen'),
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_imagenFile!, height: 150),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: guardarProducto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azul,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.save),
                  label: Text(widget.productoId == null ? 'Crear Producto' : 'Actualizar Producto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCampoTexto(String label, TextEditingController controller, {TextInputType tipo = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required List<dynamic> items,
    required int? value,
    required void Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items
          .map<DropdownMenuItem<int>>(
            (item) => DropdownMenuItem<int>(
          value: item['id'],
          child: Text(item['nombre']),
        ),
      )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null ? 'Seleccione una opción' : null,
    );
  }
}
