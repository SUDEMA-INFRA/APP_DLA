import 'package:flutter/material.dart';

class SucroalcooleiroForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool readOnly;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SucroalcooleiroForm({
    super.key,
    required this.data,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<SucroalcooleiroForm> createState() => _SucroalcooleiroFormState();
}

class _SucroalcooleiroFormState extends State<SucroalcooleiroForm> {
  late TextEditingController _residuosController;
  late TextEditingController _bagacoController;
  late bool _equipamentosConformes;
  late bool _armazenamentoOk;

  @override
  void initState() {
    super.initState();
    _residuosController = TextEditingController(text: widget.data['residuos_solidos']?.toString() ?? '');
    _bagacoController = TextEditingController(text: widget.data['bagaco']?.toString() ?? '');
    _equipamentosConformes = widget.data['equipamentos_conformes'] != false;
    _armazenamentoOk = widget.data['armazenamento_ok'] != false;
  }

  @override
  void dispose() {
    _residuosController.dispose();
    _bagacoController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    widget.onChanged({
      'residuos_solidos': _residuosController.text,
      'bagaco': _bagacoController.text,
      'equipamentos_conformes': _equipamentosConformes,
      'armazenamento_ok': _armazenamentoOk,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parâmetros Técnicos: Sucroalcooleiro',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _residuosController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Destinação de Resíduos Sólidos',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bagacoController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Destinação do Bagaço',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Equipamentos estão conformes?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _equipamentosConformes,
              activeColor: const Color(0xFF006b33),
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _equipamentosConformes = val);
                      _notifyChanges();
                    },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Armazenamento está OK?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _armazenamentoOk,
              activeColor: const Color(0xFF006b33),
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _armazenamentoOk = val);
                      _notifyChanges();
                    },
            ),
          ],
        ),
      ),
    );
  }
}
