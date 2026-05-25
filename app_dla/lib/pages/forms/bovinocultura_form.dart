import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BovinoculturaForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool readOnly;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const BovinoculturaForm({
    super.key,
    required this.data,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<BovinoculturaForm> createState() => _BovinoculturaFormState();
}

class _BovinoculturaFormState extends State<BovinoculturaForm> {
  // Theme Colors
  static const Color primaryBrown = Color(0xFF795548);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color errorRed = Color(0xFFDC2626);

  // Core production fields
  String? _modelo; // 'EXTENSIVO' or 'INTENSIVO'
  final TextEditingController _areaHaController = TextEditingController();
  final TextEditingController _dessedentacaoController = TextEditingController();
  
  // New technical parameters
  final TextEditingController _qtdCochosController = TextEditingController();
  final TextEditingController _tamanhoCochosController = TextEditingController();
  final TextEditingController _qtdAnimaisController = TextEditingController();

  // Ritos and outcomes
  bool _fotoGeoOk = false;
  bool _infracaoConstatada = false;
  bool _medidaNotificacao = false;
  bool _medidaEmbargo = false;
  bool _medidaAuto = false;

  final TextEditingController _observacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final d = widget.data;

    // Safety initialization
    _modelo = d['modelo']?.toString()?.toUpperCase();
    if (_modelo != 'EXTENSIVO' && _modelo != 'INTENSIVO') {
      _modelo = 'EXTENSIVO';
    }

    _areaHaController.text = d['area_ha']?.toString() ?? '';
    _dessedentacaoController.text = d['dessedentacao']?.toString() ?? '';
    _qtdCochosController.text = d['qtd_cochos']?.toString() ?? '';
    _tamanhoCochosController.text = d['tamanho_cochos']?.toString() ?? '';
    _qtdAnimaisController.text = d['qtd_animais']?.toString() ?? '';

    _fotoGeoOk = d['foto_geo_ok'] == true;
    _infracaoConstatada = d['infracao_constatada'] == true;

    final sugeridas = d['medida_sugerida']?.toString() ?? '';
    _medidaNotificacao = sugeridas.contains('Notificação');
    _medidaEmbargo = sugeridas.contains('Embargo');
    _medidaAuto = sugeridas.contains('Auto de Infração');

    _observacoesController.text = d['observacoes']?.toString() ?? '';
  }

  @override
  void dispose() {
    _areaHaController.dispose();
    _dessedentacaoController.dispose();
    _qtdCochosController.dispose();
    _tamanhoCochosController.dispose();
    _qtdAnimaisController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final List<String> medidas = [];
    if (_medidaNotificacao) medidas.add('Notificação');
    if (_medidaEmbargo) medidas.add('Embargo');
    if (_medidaAuto) medidas.add('Auto de Infração');

    widget.onChanged({
      'modelo': _modelo ?? 'EXTENSIVO',
      'area_ha': double.tryParse(_areaHaController.text) ?? 0.0,
      'dessedentacao': _dessedentacaoController.text,
      'qtd_cochos': int.tryParse(_qtdCochosController.text),
      'tamanho_cochos': double.tryParse(_tamanhoCochosController.text),
      'qtd_animais': int.tryParse(_qtdAnimaisController.text),
      'foto_geo_ok': _fotoGeoOk,
      'infracao_constatada': _infracaoConstatada,
      'medida_sugerida': medidas.join(', '),
      'observacoes': _observacoesController.text,
    });
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: primaryBrown,
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: darkSlate),
      ),
      value: value,
      onChanged: widget.readOnly ? null : onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sanitização de Runtime
    if (_modelo != 'EXTENSIVO' && _modelo != 'INTENSIVO') {
      _modelo = 'EXTENSIVO';
    }

    final isIntensivo = _modelo == 'INTENSIVO';

    return Card(
      color: Colors.brown.shade50,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: const [
                Icon(Icons.grass, color: primaryBrown, size: 28),
                SizedBox(width: 10),
                Text(
                  '4. BOVINOCULTURA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Divider(color: primaryBrown, thickness: 1.5, height: 24),

            // 4.1 Modelo de Criação
            const Text(
              '4.1 Modelo de Criação',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('EXTENSIVO (Pasto)', style: TextStyle(fontSize: 12))),
                    selected: _modelo == 'EXTENSIVO',
                    selectedColor: primaryBrown.withOpacity(0.15),
                    checkmarkColor: primaryBrown,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _modelo == 'EXTENSIVO' ? primaryBrown : darkSlate,
                      fontWeight: _modelo == 'EXTENSIVO' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _modelo = 'EXTENSIVO');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('INTENSIVO (Confinamento)', style: TextStyle(fontSize: 12))),
                    selected: _modelo == 'INTENSIVO',
                    selectedColor: primaryBrown.withOpacity(0.15),
                    checkmarkColor: primaryBrown,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _modelo == 'INTENSIVO' ? primaryBrown : darkSlate,
                      fontWeight: _modelo == 'INTENSIVO' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _modelo = 'INTENSIVO');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dica conceitual de identificação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryBrown.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: primaryBrown, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Dica conceitual de identificação:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBrown),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isIntensivo
                        ? '• Sistema Intensivo: Currais de engorda, cochos fixos (concreto), linha de trato onde o alimento é distribuído, e alta concentração de animais por área.'
                        : '• Sistema Extensivo: Animais soltos em áreas amplas de pastagem. Nota: Se o pasto estiver muito desgastado, solo exposto e superlotação, o sistema pode estar intensificado.',
                    style: const TextStyle(fontSize: 11, color: darkSlate, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4.2 Área + 4.5 Quantidade de animais (Grid de 2 colunas)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _areaHaController,
                    enabled: !widget.readOnly,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '4.2 Área criação (ha)',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (_) => _notifyChanges(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _qtdAnimaisController,
                    enabled: !widget.readOnly,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: '4.5 Qtd de animais',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (_) => _notifyChanges(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4.3 Quantidade de cochos + 4.4 Tamanho dos cochos (Grid de 2 colunas)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtdCochosController,
                    enabled: !widget.readOnly,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: '4.3 Qtd de cochos',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (_) => _notifyChanges(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _tamanhoCochosController,
                    enabled: !widget.readOnly,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '4.4 Tam. cochos (m)',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (_) => _notifyChanges(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dessedentação (extra campo útil da bovinocultura legada)
            TextFormField(
              controller: _dessedentacaoController,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Forma de Dessedentação',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 20),

            // Ritos Legais & Fiscalização
            const Text(
              'Ritos Legais e Fiscalização',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const Divider(height: 16),
            _buildSwitchTile(
              label: '4.6 Registro Fotográfico Georreferenciado realizado conforme rito?',
              value: _fotoGeoOk,
              onChanged: (val) {
                setState(() => _fotoGeoOk = val);
                _notifyChanges();
              },
            ),
            _buildSwitchTile(
              label: '4.7 Houve constatação de infração?',
              value: _infracaoConstatada,
              onChanged: (val) {
                setState(() => _infracaoConstatada = val);
                _notifyChanges();
              },
            ),

            if (_infracaoConstatada) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: errorRed.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sugestão de medidas a serem adotadas pela DIFI:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: errorRed),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Notificação: Para adequação/documentos'),
                      value: _medidaNotificacao,
                      activeColor: primaryBrown,
                      onChanged: widget.readOnly
                          ? null
                          : (val) {
                              setState(() => _medidaNotificacao = val ?? false);
                              _notifyChanges();
                            },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Embargo: Para impedir continuidade de dano'),
                      value: _medidaEmbargo,
                      activeColor: primaryBrown,
                      onChanged: widget.readOnly
                          ? null
                          : (val) {
                              setState(() => _medidaEmbargo = val ?? false);
                              _notifyChanges();
                            },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Auto de Infração: Por desobediência a normas'),
                      value: _medidaAuto,
                      activeColor: primaryBrown,
                      onChanged: widget.readOnly
                          ? null
                          : (val) {
                              setState(() => _medidaAuto = val ?? false);
                              _notifyChanges();
                            },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Parecer Técnico e Observações
            const Text(
              'Informações complementares e Parecer Técnico',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observacoesController,
              enabled: !widget.readOnly,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observações técnicas ou fatos relevantes...',
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
