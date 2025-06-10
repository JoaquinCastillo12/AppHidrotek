import 'package:flutter/material.dart';

class CalculadoraCabezaPage extends StatefulWidget {
  @override
  _CalculadoraCabezaPageState createState() => _CalculadoraCabezaPageState();
}

class _CalculadoraCabezaPageState extends State<CalculadoraCabezaPage> {
  final _formKey = GlobalKey<FormState>();

  final _succionController = TextEditingController();
  final _descargaController = TextEditingController();
  final _longitudController = TextEditingController();
  final _caudalController = TextEditingController();

  String _diametroSeleccionado = '50'; // en mm

  double? resultado;
  double perdidaFriccion = 0.0;

  // Lista de diámetros en mm para dropdown
  final List<String> diametrosMm = ['15', '20', '25', '32', '40', '50', '65', '80'];

  double calcularPerdidaFriccion(double caudalLps, double diametroMm, double longitudM) {
    const g = 9.81;
    double diametroM = diametroMm / 1000; // mm a m
    double area = 3.1416 * (diametroM / 2) * (diametroM / 2);
    double caudalM3s = caudalLps / 1000; // litros/s a m3/s
    double v = caudalM3s / area; // velocidad m/s

    double f = 0.02; // factor de friccion aproximado (puedes ajustarlo)
    double hf = f * (longitudM / diametroM) * (v * v) / (2 * g);

    return hf; // metros de perdida por friccion
  }

  void calcularCDT() {
    final succion = double.tryParse(_succionController.text) ?? 0;
    final descarga = double.tryParse(_descargaController.text) ?? 0;
    final longitud = double.tryParse(_longitudController.text) ?? 0;
    final caudal = double.tryParse(_caudalController.text) ?? 0;
    final diametro = double.parse(_diametroSeleccionado);

    perdidaFriccion = calcularPerdidaFriccion(caudal, diametro, longitud);

    final total = succion + descarga + perdidaFriccion;

    setState(() {
      resultado = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Cabeza Dinámica')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _succionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Altura de succión (m)',
                ),
              ),
              TextFormField(
                controller: _descargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Altura de descarga (m)',
                ),
              ),
              TextFormField(
                controller: _longitudController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Longitud de tubería (m)',
                ),
              ),
              TextFormField(
                controller: _caudalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Caudal (litros por segundo)',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _diametroSeleccionado,
                decoration: const InputDecoration(labelText: 'Diámetro de tubería (mm)'),
                items: diametrosMm.map((diam) {
                  return DropdownMenuItem<String>(
                    value: diam,
                    child: Text('$diam mm'),
                  );
                }).toList(),
                onChanged: (nuevoValor) {
                  setState(() {
                    _diametroSeleccionado = nuevoValor!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: calcularCDT,
                child: const Text('Calcular CDT'),
              ),
              const SizedBox(height: 20),
              if (resultado != null) ...[
                Text(
                  'Pérdidas por fricción: ${perdidaFriccion.toStringAsFixed(3)} m',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cabeza Dinámica Total: ${resultado!.toStringAsFixed(3)} m',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
