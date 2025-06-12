import 'package:flutter/material.dart';

class CalculadoraCabezaPage extends StatefulWidget {
  @override
  _CalculadoraCabezaPageState createState() => _CalculadoraCabezaPageState();
}

List<String> bombasRecomendadas = [];
class _CalculadoraCabezaPageState extends State<CalculadoraCabezaPage> {
  final _formKey = GlobalKey<FormState>();

  final _succionController = TextEditingController();
  final _descargaController = TextEditingController();
  final _longitudController = TextEditingController();
  final _caudalController = TextEditingController();
  final _presionTrabajoController = TextEditingController();

  String _diametroSeleccionado = '2'; // pulgadas
  double? resultado;
  double perdidaFriccion = 0.0;
  String bombaRecomendada = '';

  final List<String> diametros = ['0.5', '0.75', '1', '1.25', '1.5', '2'];

  final Map<double, Map<double, double>> perdidas = {
    2: {0.5: 1.8, 0.75: 0.5, 1: 0.15, 1.25: 0.04, 1.5: 0.02, 2: 0},
    4: {0.5: 6.5, 0.75: 1.82, 1: 0.55, 1.25: 0.17, 1.5: 0.09, 2: 0.03},
    6: {0.5: 13.77, 0.75: 3.85, 1: 1.16, 1.25: 0.37, 1.5: 0.19, 2: 0.06},
    8: {0.5: 23.45, 0.75: 6.56, 1: 1.98, 1.25: 0.63, 1.5: 0.32, 2: 0.11},
    10: {0.5: 35.43, 0.75: 9.92, 1: 3, 1.25: 0.96, 1.5: 0.49, 2: 0.16},
    16: {0.5: 84.53, 0.75: 23.68, 1: 7.16, 1.25: 2.29, 1.5: 1.18, 2: 0.4},
    20: {0.75: 35.78, 1: 10.82, 1.25: 3.47, 1.5: 1.79, 2: 0.6},
    26: {0.75: 58.14, 1: 17.59, 1.25: 5.64, 1.5: 2.91, 2: 0.98},
    30: {0.75: 75.76, 1: 22.92, 1.25: 7.35, 1.5: 3.8, 2: 1.28},
    36: {1: 32.11, 1.25: 10.3, 1.5: 5.32, 2: 1.8},
    40: {1: 39.03, 1.25: 12.51, 1.5: 6.47, 2: 2.19},
  };

  final Map<String, Map<double, double>> curvas = {
  '4pwp 10g10': {
    0: 115, 2.6: 110, 4: 108, 5.3: 106, 6.6: 102,
    7.9: 98, 9.3: 92, 10.6: 92, 13.2: 68, 15.9: 23
  },
  '4pwp 10g15': {
    0: 168, 2.6: 162, 4: 161, 5.3: 189, 6.6: 182,
    7.9: 147, 9.3: 138, 10.6: 138, 13.2: 102, 15.9: 35
  },
  '4pwp 18g10': {
    0: 75, 6.6: 74, 7.9: 72, 9.3: 70, 10.6: 68,
    13.2: 65, 15.9: 61, 18.5: 55, 21.2: 49, 23.8: 41,
    26.5: 32, 31.7: 22
  },
  '4pwp 18g15': {
    0: 104, 6.6: 103, 7.9: 98, 9.3: 96, 10.6: 94,
    13.2: 90, 15.9: 84, 18.5: 77, 21.2: 68, 23.8: 58,
    26.5: 46, 31.7: 33
  },
  '4pwp 25g20': {
    0: 101, 7.9: 100, 9.3: 98, 10.6: 96, 13.2: 94,
    15.9: 91, 18.5: 86, 21.2: 81, 23.8: 75, 26.5: 67,
    31.7: 49
  },
  '4pwp 25g30': {
    0: 137, 7.9: 136, 9.3: 134, 10.6: 132, 13.2: 128,
    15.9: 124, 18.5: 109, 21.2: 112, 23.8: 103, 26.5: 93,
    31.7: 70
  },
  '4pwp 35g20': {
    0: 91, 9.3: 81, 10.6: 80, 13.2: 79, 15.9: 77,
    18.5: 75, 21.2: 72, 23.8: 69, 26.5: 65, 31.7: 58,
    37: 48, 42.3: 32, 47.6: 17
  },
  '4pwp 40g20': {
    0: 55, 13.2: 51, 15.9: 50, 18.5: 49, 21.2: 48,
    23.8: 47, 26.5: 47, 31.7: 45, 37: 42, 42.3: 38,
    47.5: 35, 52.9: 30, 66.1: 17
  },
  '4pwp 40g30': {
    0: 74, 13.2: 71, 15.9: 70, 18.5: 69, 21.2: 68,
    23.8: 67, 26.5: 66, 31.7: 63, 37: 60, 42.3: 56,
    47.5: 50, 52.9: 43, 66.1: 24
  },
  '4pwp 40g50': {
    0: 129, 13.2: 123, 15.9: 121, 18.5: 118, 21.2: 116,
    23.8: 115, 26.5: 113, 31.7: 108, 37: 103, 42.3: 97,
    47.5: 90, 52.9: 81, 66.1: 47
  },
  '4pwp 55g20': {
    0: 59, 21.2: 52, 23.8: 51, 26.5: 50, 31.7: 48,
    37: 46, 42.3: 43, 47.6: 40, 52.9: 36, 58.2: 31,
    63.5: 26, 68.8: 21, 74.1: 15, 79.4: 8
  },
  '4pwp 60g30': {
    0: 64, 21.2: 59, 23.8: 58, 26.35: 57, 31.7: 55,
    37: 53, 42.3: 51, 47.6: 48, 52.9: 45, 58.2: 42,
    63.5: 38, 68.8: 34, 74.1: 30, 79.4: 25, 89.9: 15
  },
  '4pwp 60g50': {
    0: 100, 21.2: 96, 23.8: 93, 26.35: 90, 31.7: 87,
    37: 83, 42.3: 80, 47.6: 75, 52.9: 71, 58.2: 67,
    63.5: 60, 68.8: 54, 74.1: 48, 79.4: 41, 89.9: 24
  },
  'pep 05': {
    0: 40, 1.32: 35, 2.64: 30, 3.96: 25, 5.28: 20,
    6.6: 15, 7.93: 10, 9.25: 5
  },
  'pep 07': {
    0: 60, 1.32: 55, 2.64: 48, 3.96: 43, 5.28: 37,
    6.6: 33, 7.93: 27, 9.25: 20, 10.57: 5
  },
  'pep 10': {
    0: 75, 1.32: 70, 2.64: 63, 3.96: 55, 5.28: 48,
    6.6: 42, 7.93: 34, 9.25: 27, 10.57: 20, 13.21: 5
  },
  'cep 10': {
    0: 35, 2.64: 34.5, 5.28: 33.5, 6.6: 33, 7.93: 32.5,
    10.57: 31, 13.21: 29, 15.85: 24, 18.49: 24, 21.13: 20, 23.77: 16
  },
  'c2p 20': {
    0: 50, 5.28: 49, 10.57: 48, 15.85: 45, 21.13: 42,
    26.42: 38, 31.7: 33, 36.98: 25
  },
  'c2p 30': {
    0: 60, 5.28: 59, 10.57: 57, 15.85: 54, 21.13: 50,
    26.42: 46, 31.7: 41, 36.98: 36, 42.27: 29
  },
  'jcp 07': {
    0: 42, 1.32: 37, 2.64: 33, 3.96: 30, 5.28: 27,
    6.6: 25, 7.93: 23, 9.25: 21, 10.57: 20, 11.89: 18,
    13.21: 17
  },
  'jcp 10': {
    0: 48, 1.32: 44, 2.64: 42, 3.96: 39, 5.28: 37,
    6.6: 35, 7.93: 33, 9.25: 31, 10.57: 29, 11.89: 28,
    13.21: 26, 15.85: 24, 21.13: 21
  },
  'jcp 15': {
    0: 57, 1.32: 55, 2.64: 53, 3.96: 51, 5.28: 49,
    6.6: 46, 7.93: 45, 9.25: 43, 10.57: 41, 11.89: 39,
    13.21: 37, 15.85: 34, 21.13: 27, 26.42: 25
  },
  'minisub 05': {
    0: 52, 2.5: 52, 5: 50, 7.5: 51, 10: 46,
    12.5: 41, 15: 38, 17.5: 35, 20: 30, 22.5: 26, 25: 20
  },
  'minisub 07': {
    0: 63, 2.5: 63, 5: 61, 7.5: 59, 10: 57,
    12.5: 53, 15: 50, 17.5: 47, 20: 42, 22.5: 37, 25: 27, 30: 14
  }
};

  double? calcularPerdidaDesdeTabla(double caudalGpm, double diametroPulgadas, double longitudM) {
    double? caudalRedondeado = _valorMasCercano(perdidas.keys, caudalGpm);
    if (caudalRedondeado == null) return null;

    Map<double, double>? fila = perdidas[caudalRedondeado];
    if (fila == null) return null;

    double? diametroRedondeado = _valorMasCercano(fila.keys, diametroPulgadas);
    if (diametroRedondeado == null) return null;

    double? perdidaPor100m = fila[diametroRedondeado];
    if (perdidaPor100m == null) return null;

    return (perdidaPor100m / 100) * longitudM;
  }

  double? _valorMasCercano(Iterable<double> valores, double objetivo) {
    if (valores.isEmpty) return null;
    return valores.reduce((a, b) => (a - objetivo).abs() < (b - objetivo).abs() ? a : b);
  }

  void calcularCDT() {
  final succion = double.tryParse(_succionController.text) ?? 0;
  final descarga = double.tryParse(_descargaController.text) ?? 0;
  final longitud = double.tryParse(_longitudController.text) ?? 0;
  final caudal = double.tryParse(_caudalController.text) ?? 0;
  final presionTrabajo = double.tryParse(_presionTrabajoController.text) ?? 0;
  final diametro = double.parse(_diametroSeleccionado);

  final friccion = calcularPerdidaDesdeTabla(caudal, diametro, longitud);
  if (friccion == null) {
    setState(() {
      resultado = null;
      perdidaFriccion = 0.0;
      bombasRecomendadas = [];
    });
    return;
  }

  perdidaFriccion = friccion;
  final total = succion + descarga + perdidaFriccion + presionTrabajo;
  final recomendaciones = _recomendarBombas(caudal, total);

  setState(() {
    resultado = total;
    bombasRecomendadas = recomendaciones;
  });
}

 List<String> _recomendarBombas(double caudal, double cdt) {
  double maximoAltura = cdt + 5;
  double minimoAltura = cdt;
  double margenCaudal = caudal * 0.25; // 10% de margen
  List<String> opciones = [];

  for (var entry in curvas.entries) {
    String nombre = entry.key;
    Map<double, double> datos = entry.value;

    for (var punto in datos.entries) {
      if (punto.key > 0 &&
          (punto.key >= caudal - margenCaudal && punto.key <= caudal + margenCaudal) &&
          punto.value >= minimoAltura &&
          punto.value <= maximoAltura) {
        opciones.add('$nombre (${punto.key} GPM, ${punto.value} m)');
        break; // Solo una vez por bomba
      }
    }
  }
  return opciones;
}

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora CDT + Bomba')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _succionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Altura de succión (m)'),
              ),
              TextFormField(
                controller: _descargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Altura de descarga (m)'),
              ),
              TextFormField(
                controller: _longitudController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Longitud de tubería (m)'),
              ),
              TextFormField(
                controller: _caudalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Caudal (GPM)'),
              ),
              TextFormField(
                controller: _presionTrabajoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Presión de trabajo (m)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _diametroSeleccionado,
                decoration: const InputDecoration(labelText: 'Diámetro de tubería (pulgadas)'),
                items: diametros.map((diam) {
                  return DropdownMenuItem<String>(
                    value: diam,
                    child: Text('$diam"'),
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
  child: const Text('Calcular CDT y recomendar bombas'),
),
const SizedBox(height: 20),
// Aquí sigue el bloque de resultados:
if (resultado != null) ...[
  Text('Pérdidas por fricción: ${perdidaFriccion.toStringAsFixed(2)} m'),
  const SizedBox(height: 8),
  Text('Cabeza Dinámica Total: ${resultado!.toStringAsFixed(2)} m',
      style: const TextStyle(fontWeight: FontWeight.bold)),
  const SizedBox(height: 8),
  if (bombasRecomendadas.isNotEmpty) ...[
    const Text('Bombas recomendadas:', style: TextStyle(fontWeight: FontWeight.bold)),
    ...bombasRecomendadas.map((b) => Text(b, style: const TextStyle(color: Colors.green))),
  ] else ...[
    const Text('Ninguna bomba disponible cubre los requisitos.', style: TextStyle(color: Colors.red)),
  ]
] else ...[
  const Text('No se pudo calcular la CDT.', style: TextStyle(color: Colors.red)),
]
            ],
          ),
        ),
      ),
    );
  }
}

