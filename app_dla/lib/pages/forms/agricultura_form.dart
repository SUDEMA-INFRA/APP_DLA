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
  // Theme Colors
  static const Color primaryGreen = Color(0xFF006b33);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color errorRed = Color(0xFFDC2626);

  // Controllers for text inputs
  final TextEditingController _atividadeAgricolaController = TextEditingController();
  final TextEditingController _irrigadaOutorgaController = TextEditingController();
  final TextEditingController _agrotoxicosQuaisController = TextEditingController();
  final TextEditingController _agrotoxicosEmbalagensDestinacaoController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();

  // Boolean/Nullable fields for choice chips
  bool? _atividadeIrrigada;
  bool? _fazUsoAgrotoxicos;
  bool? _agrotoxicosReceituario;
  bool? _temCursosHidricos;

  // Fiscalização & Ritos
  bool _fotoGeoOk = false;
  bool _infracaoConstatada = false;
  bool _medidaNotificacao = false;
  bool _medidaEmbargo = false;
  bool _medidaAuto = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;

    // Load text controllers
    _atividadeAgricolaController.text = d['atividade_agricola']?.toString() ?? d['cultivo']?.toString() ?? '';
    _irrigadaOutorgaController.text = d['irrigada_outorga']?.toString() ?? '';
    _agrotoxicosQuaisController.text = d['agrotoxicos_quais']?.toString() ?? d['agrotoxicos']?.toString() ?? '';
    _agrotoxicosEmbalagensDestinacaoController.text = d['agrotoxicos_embalagens_destinacao']?.toString() ?? '';
    _observacoesController.text = d['observacoes_complementares']?.toString() ?? d['observacoes']?.toString() ?? '';

    // Load choice fields with strict parsing
    _atividadeIrrigada = _parseBool(d['atividade_irrigada']);
    _fazUsoAgrotoxicos = _parseBool(d['faz_uso_agrotoxicos']);
    _agrotoxicosReceituario = _parseBool(d['agrotoxicos_receituario']);
    
    // Support loading legacy courses field as boolean if it was saved that way, or if it matches
    _temCursosHidricos = _parseBool(d['tem_cursos_hidricos']) ?? _parseBool(d['cursos_hidricos_entorno']);

    _fotoGeoOk = d['foto_geo_ok'] == true;
    _infracaoConstatada = d['infracao_constatada'] == true;

    final sugeridas = d['infracao_sugestao_medidas']?.toString() ?? d['medida_sugerida']?.toString() ?? '';
    _medidaNotificacao = sugeridas.contains('Notificação');
    _medidaEmbargo = sugeridas.contains('Embargo');
    _medidaAuto = sugeridas.contains('Auto de Infração');
  }

  bool? _parseBool(dynamic val) {
    if (val == null) return null;
    if (val is bool) return val;
    if (val == 1 || val == '1' || val.toString().toLowerCase() == 'true' || val.toString().toLowerCase() == 'sim') return true;
    if (val == 0 || val == '0' || val.toString().toLowerCase() == 'false' || val.toString().toLowerCase() == 'não' || val.toString().toLowerCase() == 'nao') return false;
    return null;
  }

  @override
  void dispose() {
    _atividadeAgricolaController.dispose();
    _irrigadaOutorgaController.dispose();
    _agrotoxicosQuaisController.dispose();
    _agrotoxicosEmbalagensDestinacaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final List<String> medidas = [];
    if (_medidaNotificacao) medidas.add('Notificação');
    if (_medidaEmbargo) medidas.add('Embargo');
    if (_medidaAuto) medidas.add('Auto de Infração');

    widget.onChanged({
      'atividade_agricola': _atividadeAgricolaController.text,
      'atividade_irrigada': _atividadeIrrigada,
      'irrigada_outorga': _irrigadaOutorgaController.text,
      'faz_uso_agrotoxicos': _fazUsoAgrotoxicos,
      'agrotoxicos_quais': _agrotoxicosQuaisController.text,
      'agrotoxicos_receituario': _agrotoxicosReceituario,
      'agrotoxicos_embalagens_destinacao': _agrotoxicosEmbalagensDestinacaoController.text,
      'tem_cursos_hidricos': _temCursosHidricos,
      
      // Fiscalização
      'foto_geo_ok': _fotoGeoOk,
      'infracao_constatada': _infracaoConstatada,
      'infracao_sugestao_medidas': medidas.join(', '),
      'observacoes_complementares': _observacoesController.text,

      // Legacy mappings to preserve retrocompatibility
      'cultivo': _atividadeAgricolaController.text,
      'cursos_hidricos_entorno': _temCursosHidricos == true ? 'Sim' : 'Não',
      'agrotoxicos': _agrotoxicosQuaisController.text,
    });
  }

  Widget _buildYesNoChips({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkSlate),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Sim', style: TextStyle(fontSize: 12))),
                  selected: value == true,
                  selectedColor: primaryGreen.withOpacity(0.15),
                  checkmarkColor: primaryGreen,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: value == true ? primaryGreen : darkSlate,
                    fontWeight: value == true ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: widget.readOnly
                      ? null
                      : (selected) {
                          onChanged(selected ? true : null);
                          _notifyChanges();
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Não', style: TextStyle(fontSize: 12))),
                  selected: value == false,
                  selectedColor: primaryGreen.withOpacity(0.15),
                  checkmarkColor: primaryGreen,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: value == false ? primaryGreen : darkSlate,
                    fontWeight: value == false ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: widget.readOnly
                      ? null
                      : (selected) {
                          onChanged(selected ? false : null);
                          _notifyChanges();
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !widget.readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          border: const OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: (_) => _notifyChanges(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightGreen.shade50,
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
                Icon(Icons.agriculture, color: primaryGreen, size: 28),
                SizedBox(width: 10),
                Text(
                  '7. ATIVIDADES AGRÍCOLAS',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Divider(color: primaryGreen, thickness: 1.5, height: 24),

            // 7.1 Atividade agrícola
            _buildTextField(
              controller: _atividadeAgricolaController,
              label: '7.1 Atividade agrícola (Ex: Milho, Feijão, etc.)',
            ),

            // 7.2 Atividade é Irrigada?
            _buildYesNoChips(
              label: '7.2 Atividade é Irrigada?',
              value: _atividadeIrrigada,
              onChanged: (val) => setState(() => _atividadeIrrigada = val),
            ),
            if (_atividadeIrrigada == true)
              _buildTextField(
                controller: _irrigadaOutorgaController,
                label: 'Possui outorga de captação/uso de água?',
              ),

            // 7.3 Faz uso de agrotóxicos?
            _buildYesNoChips(
              label: '7.3 Faz uso de agrotóxicos?',
              value: _fazUsoAgrotoxicos,
              onChanged: (val) => setState(() => _fazUsoAgrotoxicos = val),
            ),
            if (_fazUsoAgrotoxicos == true) ...[
              _buildTextField(
                controller: _agrotoxicosQuaisController,
                label: 'Quais agrotóxicos utiliza?',
              ),
              _buildYesNoChips(
                label: 'Possui receituário agronômico?',
                value: _agrotoxicosReceituario,
                onChanged: (val) => setState(() => _agrotoxicosReceituario = val),
              ),
              _buildTextField(
                controller: _agrotoxicosEmbalagensDestinacaoController,
                label: 'Qual a destinação dada às embalagens?',
              ),
            ],

            // 7.4 Cursos hídricos no entorno
            _buildYesNoChips(
              label: '7.4 Existem cursos hídricos, nascentes, reservatórios de água ou qualquer corpo hídrico no entorno do cultivo?',
              value: _temCursosHidricos,
              onChanged: (val) => setState(() => _temCursosHidricos = val),
            ),

            const SizedBox(height: 16),
            // Ritos Legais & Fiscalização
            const Text(
              'Ritos Legais e Fiscalização',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const Divider(height: 16),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: primaryGreen,
                title: const Text(
                  '7.5 Registro Fotográfico Georreferenciado realizado conforme rito?',
                  style: TextStyle(fontSize: 13, color: darkSlate),
                ),
                value: _fotoGeoOk,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _fotoGeoOk = val);
                        _notifyChanges();
                      },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: primaryGreen,
                title: const Text(
                  '7.6 Houve constatação de infração?',
                  style: TextStyle(fontSize: 13, color: darkSlate),
                ),
                value: _infracaoConstatada,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _infracaoConstatada = val);
                        _notifyChanges();
                      },
              ),
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
                      activeColor: primaryGreen,
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
                      activeColor: primaryGreen,
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
                      activeColor: primaryGreen,
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

            // Observações Técnicas
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
                labelText: 'Informações complementares, observações técnicas ou fatos relevantes...',
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
