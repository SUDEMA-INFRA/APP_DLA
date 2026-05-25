import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AquiculturaForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool readOnly;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const AquiculturaForm({
    super.key,
    required this.data,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<AquiculturaForm> createState() => _AquiculturaFormState();
}

class _AquiculturaFormState extends State<AquiculturaForm> {
  // Theme Colors
  static const Color primaryCyan = Color(0xFF0097A7);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color errorRed = Color(0xFFDC2626);

  // Controllers to avoid LateInitializationError
  final TextEditingController _qtdTanquesController = TextEditingController();
  final TextEditingController _areaTanquesController = TextEditingController();
  
  bool _possuiAeradores = false;
  final TextEditingController _qtdAeradoresController = TextEditingController();

  // Identified equipment
  bool _bombaIdentificada = false;
  final TextEditingController _bombaSituacaoController = TextEditingController();

  bool _tubulacaoIdentificada = false;
  final TextEditingController _tubulacaoSituacaoController = TextEditingController();

  bool _captacaoIdentificada = false;
  final TextEditingController _captacaoSituacaoController = TextEditingController();

  bool _hidrometroIdentificado = false;
  final TextEditingController _hidrometroSituacaoController = TextEditingController();

  bool _outrosItensIdentificados = false;
  final TextEditingController _outrosItensSituacaoController = TextEditingController();

  // Outorga
  bool _outorga = false;
  final TextEditingController _outorgaIdentificacaoController = TextEditingController();

  // Descarte
  String? _descarteResiduos; // 'COMPOSTEIRA' or 'OUTRO'
  final TextEditingController _descarteResiduosOutroController = TextEditingController();

  // Ritos and DIFI
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

    _qtdTanquesController.text = d['qtd_tanques']?.toString() ?? '';
    _areaTanquesController.text = d['area_tanques']?.toString() ?? '';

    _possuiAeradores = d['possui_aeradores'] == true;
    _qtdAeradoresController.text = d['qtd_aeradores']?.toString() ?? '';

    _bombaIdentificada = d['bomba_identificada'] == true;
    _bombaSituacaoController.text = d['bomba_situacao']?.toString() ?? '';

    _tubulacaoIdentificada = d['tubulacao_identificada'] == true;
    _tubulacaoSituacaoController.text = d['tubulacao_situacao']?.toString() ?? '';

    _captacaoIdentificada = d['captacao_identificada'] == true;
    _captacaoSituacaoController.text = d['captacao_situacao']?.toString() ?? '';

    _hidrometroIdentificado = d['hidrometro'] == true;
    _hidrometroSituacaoController.text = d['hidrometro_situacao']?.toString() ?? '';

    _outrosItensIdentificados = d['outros_itens_identificados'] == true;
    _outrosItensSituacaoController.text = d['outros_itens_situacao']?.toString() ?? '';

    _outorga = d['outorga'] == true;
    _outorgaIdentificacaoController.text = d['outorga_identificacao']?.toString() ?? '';

    _descarteResiduos = d['descarte_residuos']?.toString().toUpperCase();
    if (_descarteResiduos != 'COMPOSTEIRA' && _descarteResiduos != 'OUTRO') {
      _descarteResiduos = 'COMPOSTEIRA';
    }
    _descarteResiduosOutroController.text = d['descarte_residuos_outro']?.toString() ?? '';

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
    _qtdTanquesController.dispose();
    _areaTanquesController.dispose();
    _qtdAeradoresController.dispose();
    _bombaSituacaoController.dispose();
    _tubulacaoSituacaoController.dispose();
    _captacaoSituacaoController.dispose();
    _hidrometroSituacaoController.dispose();
    _outrosItensSituacaoController.dispose();
    _outorgaIdentificacaoController.dispose();
    _descarteResiduosOutroController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final List<String> medidas = [];
    if (_medidaNotificacao) medidas.add('Notificação');
    if (_medidaEmbargo) medidas.add('Embargo');
    if (_medidaAuto) medidas.add('Auto de Infração');

    widget.onChanged({
      'qtd_tanques': int.tryParse(_qtdTanquesController.text),
      'area_tanques': double.tryParse(_areaTanquesController.text),
      'possui_aeradores': _possuiAeradores,
      'qtd_aeradores': int.tryParse(_qtdAeradoresController.text),
      
      'bomba_identificada': _bombaIdentificada,
      'bomba_situacao': _bombaSituacaoController.text,
      
      'tubulacao_identificada': _tubulacaoIdentificada,
      'tubulacao_situacao': _tubulacaoSituacaoController.text,
      
      'captacao_identificada': _captacaoIdentificada,
      'captacao_situacao': _captacaoSituacaoController.text,
      
      'hidrometro': _hidrometroIdentificado,
      'hidrometro_situacao': _hidrometroSituacaoController.text,
      
      'outros_itens_identificados': _outrosItensIdentificados,
      'outros_itens_situacao': _outrosItensSituacaoController.text,
      
      'outorga': _outorga,
      'outorga_identificacao': _outorgaIdentificacaoController.text,
      
      'descarte_residuos': _descarteResiduos ?? 'COMPOSTEIRA',
      'descarte_residuos_outro': _descarteResiduosOutroController.text,
      
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
      activeColor: primaryCyan,
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: darkSlate),
      ),
      value: value,
      onChanged: widget.readOnly ? null : onChanged,
    );
  }

  Widget _buildEquipmentCheck({
    required String label,
    required bool identified,
    required TextEditingController controller,
    required ValueChanged<bool?> onCheckChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkSlate),
          ),
          value: identified,
          activeColor: primaryCyan,
          onChanged: widget.readOnly ? null : onCheckChanged,
        ),
        if (identified) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: TextFormField(
              controller: controller,
              enabled: !widget.readOnly,
              decoration: const InputDecoration(
                labelText: 'Situação / Detalhes do item',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
                isDense: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sanitização de Runtime
    if (_descarteResiduos != 'COMPOSTEIRA' && _descarteResiduos != 'OUTRO') {
      _descarteResiduos = 'COMPOSTEIRA';
    }

    final aeradoresCount = int.tryParse(_qtdAeradoresController.text) ?? 0;
    final showAeradorWarning = _possuiAeradores && aeradoresCount >= 3;

    return Card(
      color: Colors.cyan.shade50,
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
                Icon(Icons.water, color: primaryCyan, size: 28),
                SizedBox(width: 10),
                Text(
                  '5. AQUICULTURA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryCyan,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Divider(color: primaryCyan, thickness: 1.5, height: 24),

            // 5.1 & 5.2 - Tanques e Área
            const Text(
              '5.1 & 5.2 Capacidade de Viveiros',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtdTanquesController,
                    enabled: !widget.readOnly,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: '5.1 Nº de tanques',
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
                    controller: _areaTanquesController,
                    enabled: !widget.readOnly,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '5.2 Área total (ha)',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (_) => _notifyChanges(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dica de referência de campo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryCyan.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: primaryCyan, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Referência de campo:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryCyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '• 1 campo de futebol ≈ 0,7 hectare\n'
                    '• DICA: Se a soma visual dos viveiros aparenta ultrapassar 7 campos de futebol (4.9 ha), a dispensa fica incompatível.',
                    style: TextStyle(fontSize: 11, color: darkSlate, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5.3 Aeradores
            const Text(
              '5.3 Sistemas de Aeração',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 4),
            _buildSwitchTile(
              label: 'O tanque possui Aeradores?',
              value: _possuiAeradores,
              onChanged: (val) {
                setState(() {
                  _possuiAeradores = val;
                  if (!val) {
                    _qtdAeradoresController.clear();
                  }
                });
                _notifyChanges();
              },
            ),
            if (_possuiAeradores) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: TextFormField(
                  controller: _qtdAeradoresController,
                  enabled: !widget.readOnly,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Quantos aeradores por tanque?',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (_) {
                    setState(() {});
                    _notifyChanges();
                  },
                ),
              ),
              if (showAeradorWarning) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alerta rápido: 3 ou mais aeradores por tanque pode indicar sistema intensivo e maior potencial poluidor.',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 16),

            // 5.4 Itens identificados no empreendimento
            const Text(
              '5.4 Equipamentos e Estruturas Identificadas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const Divider(height: 16),
            _buildEquipmentCheck(
              label: 'BOMBA',
              identified: _bombaIdentificada,
              controller: _bombaSituacaoController,
              onCheckChanged: (val) {
                setState(() {
                  _bombaIdentificada = val ?? false;
                  if (!_bombaIdentificada) _bombaSituacaoController.clear();
                });
                _notifyChanges();
              },
            ),
            _buildEquipmentCheck(
              label: 'TUBULAÇÃO',
              identified: _tubulacaoIdentificada,
              controller: _tubulacaoSituacaoController,
              onCheckChanged: (val) {
                setState(() {
                  _tubulacaoIdentificada = val ?? false;
                  if (!_tubulacaoIdentificada) _tubulacaoSituacaoController.clear();
                });
                _notifyChanges();
              },
            ),
            _buildEquipmentCheck(
              label: 'PONTO DE CAPTAÇÃO',
              identified: _captacaoIdentificada,
              controller: _captacaoSituacaoController,
              onCheckChanged: (val) {
                setState(() {
                  _captacaoIdentificada = val ?? false;
                  if (!_captacaoIdentificada) _captacaoSituacaoController.clear();
                });
                _notifyChanges();
              },
            ),
            _buildEquipmentCheck(
              label: 'HIDRÔMETRO',
              identified: _hidrometroIdentificado,
              controller: _hidrometroSituacaoController,
              onCheckChanged: (val) {
                setState(() {
                  _hidrometroIdentificado = val ?? false;
                  if (!_hidrometroIdentificado) _hidrometroSituacaoController.clear();
                });
                _notifyChanges();
              },
            ),
            _buildEquipmentCheck(
              label: 'OUTROS',
              identified: _outrosItensIdentificados,
              controller: _outrosItensSituacaoController,
              onCheckChanged: (val) {
                setState(() {
                  _outrosItensIdentificados = val ?? false;
                  if (!_outrosItensIdentificados) _outrosItensSituacaoController.clear();
                });
                _notifyChanges();
              },
            ),
            const SizedBox(height: 16),

            // 5.5 Outorga de Água
            const Text(
              '5.5 Licenciamento de Recursos Hídricos',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            _buildSwitchTile(
              label: 'Existe outorga de água?',
              value: _outorga,
              onChanged: (val) {
                setState(() {
                  _outorga = val;
                  if (!val) {
                    _outorgaIdentificacaoController.clear();
                  }
                });
                _notifyChanges();
              },
            ),
            if (_outorga) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: TextFormField(
                  controller: _outorgaIdentificacaoController,
                  enabled: !widget.readOnly,
                  decoration: const InputDecoration(
                    labelText: 'Identificação / Número do Processo',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (_) => _notifyChanges(),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // 5.6 Local de descarte de resíduos
            const Text(
              '5.6 Descarte de Resíduos',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('COMPOSTEIRA', style: TextStyle(fontSize: 12))),
                    selected: _descarteResiduos == 'COMPOSTEIRA',
                    selectedColor: primaryCyan.withOpacity(0.15),
                    checkmarkColor: primaryCyan,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _descarteResiduos == 'COMPOSTEIRA' ? primaryCyan : darkSlate,
                      fontWeight: _descarteResiduos == 'COMPOSTEIRA' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() {
                                _descarteResiduos = 'COMPOSTEIRA';
                                _descarteResiduosOutroController.clear();
                              });
                              _notifyChanges();
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('OUTRO', style: TextStyle(fontSize: 12))),
                    selected: _descarteResiduos == 'OUTRO',
                    selectedColor: primaryCyan.withOpacity(0.15),
                    checkmarkColor: primaryCyan,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _descarteResiduos == 'OUTRO' ? primaryCyan : darkSlate,
                      fontWeight: _descarteResiduos == 'OUTRO' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _descarteResiduos = 'OUTRO');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
              ],
            ),
            if (_descarteResiduos == 'OUTRO') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _descarteResiduosOutroController,
                enabled: !widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Identificação do local de descarte',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ],
            const SizedBox(height: 20),

            // Ritos Legais & Fiscalização
            const Text(
              'Ritos Legais e Fiscalização',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const Divider(height: 16),
            _buildSwitchTile(
              label: '5.7 Registro Fotográfico Georreferenciado realizado conforme rito?',
              value: _fotoGeoOk,
              onChanged: (val) {
                setState(() => _fotoGeoOk = val);
                _notifyChanges();
              },
            ),
            _buildSwitchTile(
              label: '5.8 Houve constatação de infração?',
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
                      activeColor: primaryCyan,
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
                      activeColor: primaryCyan,
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
                      activeColor: primaryCyan,
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
            const SizedBox(height: 16),

            // Dica fixa de rodapé
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryCyan.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.help_outline, color: primaryCyan, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Dica de campo:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryCyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sempre observar se existem animais, esterco, galpões, currais ou tanques muito próximos ao curso d’água, existe risco alto de irregularidade.',
                    style: TextStyle(fontSize: 11, color: darkSlate, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
