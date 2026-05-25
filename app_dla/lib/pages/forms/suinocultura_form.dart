import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuinoculturaForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool readOnly;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SuinoculturaForm({
    super.key,
    required this.data,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<SuinoculturaForm> createState() => _SuinoculturaFormState();
}

class _SuinoculturaFormState extends State<SuinoculturaForm> {
  // Theme Colors
  static const Color primaryPink = Color(0xFFD81B60);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color errorRed = Color(0xFFDC2626);

  // Core production fields
  String? _modelo; // 'CAIPIRA' or 'INDUSTRIAL'
  final TextEditingController _qtdGalpoesController = TextEditingController();
  final TextEditingController _qtdMedioPorGalpaoController = TextEditingController();

  // Phases of production
  bool _faseTerminacao = false;
  final TextEditingController _faseTerminacaoQtdController = TextEditingController();
  bool _faseMatrizes = false;
  final TextEditingController _faseMatrizesQtdController = TextEditingController();
  bool _faseReprodutores = false;
  final TextEditingController _faseReprodutoresQtdController = TextEditingController();
  bool _faseAdulto = false;
  final TextEditingController _faseAdultoQtdController = TextEditingController();

  // Environmental aspects
  bool _acumuloResiduos = false;
  bool _vazamentoDejetos = false;
  bool _odorExtremo = false;
  bool _dejetosTransbordando = false;
  bool _impermeabilizacaoContencao = false;
  bool _destinacaoAdequada = true;

  // Scale & Handling
  bool _indiciosPorteMaior = false;
  final TextEditingController _indiciosPorteMaiorDetalheController = TextEditingController();

  // Dead animals
  bool _mortosIncinerados = true;
  final TextEditingController _mortosDestinoController = TextEditingController();

  // DIFI & Infractions
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

    // Model - Dropdown & Option Safety
    _modelo = d['modelo']?.toString()?.toUpperCase();
    if (_modelo != 'CAIPIRA' && _modelo != 'INDUSTRIAL') {
      _modelo = 'CAIPIRA'; // Safe default
    }

    _qtdGalpoesController.text = d['qtd_galpoes']?.toString() ?? '';
    _qtdMedioPorGalpaoController.text = d['qtd_medio_por_galpao']?.toString() ?? '';

    // Phases
    _faseTerminacao = d['fase_terminacao'] == true;
    _faseTerminacaoQtdController.text = d['fase_terminacao_qtd']?.toString() ?? '';
    _faseMatrizes = d['fase_matrizes'] == true;
    _faseMatrizesQtdController.text = d['fase_matrizes_qtd']?.toString() ?? '';
    _faseReprodutores = d['fase_reprodutores'] == true;
    _faseReprodutoresQtdController.text = d['fase_reprodutores_qtd']?.toString() ?? '';
    _faseAdulto = d['fase_adulto'] == true;
    _faseAdultoQtdController.text = d['fase_adulto_qtd']?.toString() ?? '';

    // Environmental Aspects
    _acumuloResiduos = d['acumulo_residuos'] == true;
    _vazamentoDejetos = d['vazamento_dejetos'] == true;
    _odorExtremo = d['odor_extremo'] == true;
    _dejetosTransbordando = d['dejetos_transbordando'] == true;
    _impermeabilizacaoContencao = d['impermeabilizacao_contencao'] == true;
    _destinacaoAdequada = d['destinacao_adequada'] != false; // Default true

    // Handling
    _indiciosPorteMaior = d['indicios_porte_maior'] == true;
    _indiciosPorteMaiorDetalheController.text = d['indicios_porte_maior_detalhe']?.toString() ?? '';

    // Dead Animals
    _mortosIncinerados = d['mortos_incinerados'] != false; // Default true
    _mortosDestinoController.text = d['mortos_destino']?.toString() ?? '';

    // Outcomes
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
    _qtdGalpoesController.dispose();
    _qtdMedioPorGalpaoController.dispose();
    _faseTerminacaoQtdController.dispose();
    _faseMatrizesQtdController.dispose();
    _faseReprodutoresQtdController.dispose();
    _faseAdultoQtdController.dispose();
    _indiciosPorteMaiorDetalheController.dispose();
    _mortosDestinoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final int qtdGalpoes = int.tryParse(_qtdGalpoesController.text) ?? 0;
    final int qtdMedio = int.tryParse(_qtdMedioPorGalpaoController.text) ?? 0;
    final int totalQtd = qtdGalpoes * qtdMedio;

    // Aggregate phases list for backward compatibility
    final List<String> fasesSelected = [];
    if (_faseTerminacao) fasesSelected.add('Terminação');
    if (_faseMatrizes) fasesSelected.add('Matrizes Gestantes');
    if (_faseReprodutores) fasesSelected.add('Reprodutores');
    if (_faseAdulto) fasesSelected.add('Suíno Adulto');

    final String dejetosDest = _destinacaoAdequada ? 'Destinação Adequada/Tratamento' : 'Inadequada';

    // Medidas sugeridas join
    final List<String> medidas = [];
    if (_medidaNotificacao) medidas.add('Notificação');
    if (_medidaEmbargo) medidas.add('Embargo');
    if (_medidaAuto) medidas.add('Auto de Infração');

    widget.onChanged({
      'modelo': _modelo ?? 'CAIPIRA',
      'qtd_galpoes': qtdGalpoes,
      'qtd_medio_por_galpao': qtdMedio,
      'fase_terminacao': _faseTerminacao,
      'fase_terminacao_qtd': _faseTerminacaoQtdController.text,
      'fase_matrizes': _faseMatrizes,
      'fase_matrizes_qtd': _faseMatrizesQtdController.text,
      'fase_reprodutores': _faseReprodutores,
      'fase_reprodutores_qtd': _faseReprodutoresQtdController.text,
      'fase_adulto': _faseAdulto,
      'fase_adulto_qtd': _faseAdultoQtdController.text,
      'acumulo_residuos': _acumuloResiduos,
      'vazamento_dejetos': _vazamentoDejetos,
      'odor_extremo': _odorExtremo,
      'dejetos_transbordando': _dejetosTransbordando,
      'impermeabilizacao_contencao': _impermeabilizacaoContencao,
      'destinacao_adequada': _destinacaoAdequada,
      'indicios_porte_maior': _indiciosPorteMaior,
      'indicios_porte_maior_detalhe': _indiciosPorteMaiorDetalheController.text,
      'mortos_incinerados': _mortosIncinerados,
      'mortos_destino': _mortosDestinoController.text,
      'foto_geo_ok': _fotoGeoOk,
      'infracao_constatada': _infracaoConstatada,
      'medida_sugerida': medidas.join(', '),
      'observacoes': _observacoesController.text,

      // Compatibility mappings
      'qtd_animais': totalQtd,
      'fase_producao': fasesSelected.join(', '),
      'dejetos_destinacao': dejetosDest,
      'conformidade': !_infracaoConstatada,
    });
  }

  @override
  Widget build(BuildContext context) {
    // RuntimeDropdown Protection (Sanitization block)
    if (_modelo != 'CAIPIRA' && _modelo != 'INDUSTRIAL') {
      _modelo = 'CAIPIRA';
    }

    final int calculatedTotal = (int.tryParse(_qtdGalpoesController.text) ?? 0) *
        (int.tryParse(_qtdMedioPorGalpaoController.text) ?? 0);

    return Card(
      color: Colors.pink.shade50,
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
                Icon(Icons.pets, color: primaryPink, size: 28),
                SizedBox(width: 10),
                Text(
                  '3. SUINOCULTURA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryPink,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Divider(color: primaryPink, thickness: 1.5, height: 24),

            // 3.1 Modelo de Produção
            const Text(
              '3.1 Modelo de Produção',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('CAIPIRA', style: TextStyle(fontSize: 12))),
                    selected: _modelo == 'CAIPIRA',
                    selectedColor: primaryPink.withOpacity(0.15),
                    checkmarkColor: primaryPink,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _modelo == 'CAIPIRA' ? primaryPink : darkSlate,
                      fontWeight: _modelo == 'CAIPIRA' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _modelo = 'CAIPIRA');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('INDUSTRIAL', style: TextStyle(fontSize: 12))),
                    selected: _modelo == 'INDUSTRIAL',
                    selectedColor: primaryPink.withOpacity(0.15),
                    checkmarkColor: primaryPink,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _modelo == 'INDUSTRIAL' ? primaryPink : darkSlate,
                      fontWeight: _modelo == 'INDUSTRIAL' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _modelo = 'INDUSTRIAL');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dicas visuais baseadas no modelo selecionado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryPink.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: primaryPink, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Diretriz de Identificação em Campo:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryPink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _modelo == 'CAIPIRA'
                        ? '• Acesso a piquetes externos\n• Estruturas simples e abertas\n• Menor densidade de confinamento'
                        : '• Baias de concreto e canaletas coletoras\n• Piso ripado em alguns casos\n• Grande escala, galpão fechado e alta densidade',
                    style: const TextStyle(fontSize: 12, color: darkSlate, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3.2 e 3.3 Estruturas & Capacidade
            const Text(
              'Capacidade e Infraestrutura',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtdGalpoesController,
                    enabled: !widget.readOnly,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Nº de Galpões (3.2)',
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
                    controller: _qtdMedioPorGalpaoController,
                    enabled: !widget.readOnly,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Média Animais/Galpão (3.3)',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (_) => _notifyChanges(),
                  ),
                ),
              ],
            ),
            if (calculatedTotal > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Estimativa Total: $calculatedTotal suínos',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryPink),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 3.4 Fase de Produção (Checklist com estimativa individual)
            const Text(
              '3.4 Fase de Produção & Estimativas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 8),

            // Fases individualmente
            _buildPhaseRow(
              label: 'Suíno em terminação',
              value: _faseTerminacao,
              controller: _faseTerminacaoQtdController,
              onChanged: (val) {
                setState(() => _faseTerminacao = val ?? false);
                _notifyChanges();
              },
            ),
            const SizedBox(height: 10),
            _buildPhaseRow(
              label: 'Matrizes gestantes',
              value: _faseMatrizes,
              controller: _faseMatrizesQtdController,
              onChanged: (val) {
                setState(() => _faseMatrizes = val ?? false);
                _notifyChanges();
              },
            ),
            const SizedBox(height: 10),
            _buildPhaseRow(
              label: 'Reprodutores',
              value: _faseReprodutores,
              controller: _faseReprodutoresQtdController,
              onChanged: (val) {
                setState(() => _faseReprodutores = val ?? false);
                _notifyChanges();
              },
            ),
            const SizedBox(height: 10),
            _buildPhaseRow(
              label: 'Suíno adulto',
              value: _faseAdulto,
              controller: _faseAdultoQtdController,
              onChanged: (val) {
                setState(() => _faseAdulto = val ?? false);
                _notifyChanges();
              },
            ),
            const SizedBox(height: 20),

            // Diagnóstico de Dejetos e Aspectos Ambientais (3.5 - 3.10)
            const Text(
              'Diagnóstico Sanitário e Ambiental',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 8),

            _buildSwitchTile(
              label: '3.5 Existe acúmulo de Resíduos?',
              value: _acumuloResiduos,
              onChanged: (val) {
                setState(() => _acumuloResiduos = val);
                _notifyChanges();
              },
            ),
            _buildSwitchTile(
              label: '3.6 Há vazamento de dejetos para fora do sistema?',
              value: _vazamentoDejetos,
              onChanged: (val) {
                setState(() => _vazamentoDejetos = val);
                _notifyChanges();
              },
            ),
            _buildSwitchTile(
              label: '3.7 Há odor extremo?',
              value: _odorExtremo,
              onChanged: (val) {
                setState(() => _odorExtremo = val);
                _notifyChanges();
              },
            ),
            _buildSwitchTile(
              label: '3.8 Os dejetos estão transbordando?',
              value: _dejetosTransbordando,
              onChanged: (val) {
                setState(() => _dejetosTransbordando = val);
                _notifyChanges();
              },
            ),
            _buildSwitchTile(
              label: '3.9 Existe sistema de impermeabilização e contenção?',
              value: _impermeabilizacaoContencao,
              onChanged: (val) {
                setState(() => _impermeabilizacaoContencao = val);
                _notifyChanges();
              },
            ),
            _buildSwitchTile(
              label: '3.10 Existe destinação adequada/tratamento dos dejetos?',
              value: _destinacaoAdequada,
              onChanged: (val) {
                setState(() => _destinacaoAdequada = val);
                _notifyChanges();
              },
            ),
            const SizedBox(height: 10),

            // 3.11 Indícios de Porte Maior
            _buildSwitchTile(
              label: '3.11 Indícios de porte maior ou manejo inadequado?',
              value: _indiciosPorteMaior,
              onChanged: (val) {
                setState(() => _indiciosPorteMaior = val);
                _notifyChanges();
              },
            ),
            if (_indiciosPorteMaior) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _indiciosPorteMaiorDetalheController,
                enabled: !widget.readOnly,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Detalhar Porte ou Manejo Inadequado',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ],
            const SizedBox(height: 15),

            // 3.12 Destinação de Animais Mortos
            _buildSwitchTile(
              label: '3.12 Animais mortos por causas eventuais são incinerados?',
              value: _mortosIncinerados,
              onChanged: (val) {
                setState(() => _mortosIncinerados = val);
                _notifyChanges();
              },
            ),
            if (!_mortosIncinerados) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _mortosDestinoController,
                enabled: !widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Qual o destino dos animais mortos?',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ],
            const SizedBox(height: 15),

            // Ritos e Constatação de Infração
            const Text(
              'Ritos Legais e Constatação de Infração',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              label: 'Registro Fotográfico Georreferenciado realizado?',
              value: _fotoGeoOk,
              onChanged: (val) {
                setState(() => _fotoGeoOk = val);
                _notifyChanges();
              },
            ),
            _buildSwitchTile(
              label: 'Houve constatação de infração?',
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
                      activeColor: primaryPink,
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
                      activeColor: primaryPink,
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
                      activeColor: primaryPink,
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
            const SizedBox(height: 15),

            // Observações
            TextFormField(
              controller: _observacoesController,
              enabled: !widget.readOnly,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Informações complementares e observações técnicas',
                alignLabelWithHint: true,
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

  // Row helper for Phase selections
  Widget _buildPhaseRow({
    required String label,
    required bool value,
    required TextEditingController controller,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          activeColor: primaryPink,
          onChanged: widget.readOnly ? null : onChanged,
        ),
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: darkSlate),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: controller,
            enabled: !widget.readOnly && value,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Estimativa',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: const OutlineInputBorder(),
              fillColor: value ? Colors.white : Colors.grey.shade200,
              filled: true,
            ),
            onChanged: (_) => _notifyChanges(),
          ),
        ),
      ],
    );
  }

  // Helper to build a styled SwitchListTile
  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: primaryPink,
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: darkSlate),
      ),
      value: value,
      onChanged: widget.readOnly ? null : onChanged,
    );
  }
}
