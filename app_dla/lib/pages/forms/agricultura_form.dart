import 'package:flutter/material.dart';

class AgriculturaForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool readOnly;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const AgriculturaForm({
    super.key,
    required this.data,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<AgriculturaForm> createState() => _AgriculturaFormState();
}

class _AgriculturaFormState extends State<AgriculturaForm> {
  late TextEditingController _cultivoController;
  late TextEditingController _cursosHidricosController;
  late TextEditingController _agrotoxicosController;

  @override
  void initState() {
    super.initState();
    _cultivoController = TextEditingController(text: widget.data['cultivo']?.toString() ?? '');
    _cursosHidricosController = TextEditingController(text: widget.data['cursos_hidricos_entorno']?.toString() ?? '');
    _agrotoxicosController = TextEditingController(text: widget.data['agrotoxicos']?.toString() ?? '');
  }

  @override
  void dispose() {
    _cultivoController.dispose();
    _cursosHidricosController.dispose();
    _agrotoxicosController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    widget.onChanged({
      'cultivo': _cultivoController.text,
      'cursos_hidricos_entorno': _cursosHidricosController.text,
      'agrotoxicos': _agrotoxicosController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightGreen.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parâmetros Técnicos: Agricultura',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.lightGreen),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cultivoController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Tipo de Cultivo (Ex: Milho, Soja)',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cursosHidricosController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Cursos Hídricos no Entorno',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _agrotoxicosController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Uso de Agrotóxicos (Detalhar)',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
          ],
        ),
      ),
    );
  }
}
