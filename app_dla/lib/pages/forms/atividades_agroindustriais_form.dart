import 'package:flutter/material.dart';

class AtividadesAgroindustriaisForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool readOnly;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const AtividadesAgroindustriaisForm({
    super.key,
    required this.data,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<AtividadesAgroindustriaisForm> createState() => _AtividadesAgroindustriaisFormState();
}

class _AtividadesAgroindustriaisFormState extends State<AtividadesAgroindustriaisForm> {
  // Theme Colors
  static const Color primaryPurple = Colors.purple;
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color errorRed = Color(0xFFDC2626);

  // Controllers for text inputs
  final TextEditingController _localMateriaPrimaController = TextEditingController();
  final TextEditingController _efluentesColetaDestinacaoController = TextEditingController();
  final TextEditingController _residuosColetaDestinacaoController = TextEditingController();
  final TextEditingController _bagacoArmazenamentoDestinacaoController = TextEditingController();
  final TextEditingController _fontesTermicasQuaisController = TextEditingController();
  final TextEditingController _lenhaLocalArmazenamentoController = TextEditingController();
  final TextEditingController _vinhacaCondicoesController = TextEditingController();
  final TextEditingController _envaseCondicoesController = TextEditingController();
  final TextEditingController _agrotoxicosQuaisController = TextEditingController();
  final TextEditingController _agrotoxicosEmbalagensDestinacaoController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();

  // Boolean/Nullable fields for choice chips (represented as bool? for Sim/Nao/null state)
  bool? _produzEfluentes;
  bool? _produzResiduos;
  bool? _geraUtilizaBagaco;
  bool? _fontesTermicas;
  bool? _utilizaLenha;
  String? _lenhaNativaExotica; // 'NATIVA', 'EXOTICA' or null
  bool? _tanquesAdequados;
  bool? _higienizacaoControleEfluentes;
  bool? _fossaSeptica;
  bool? _equipamentosMemorial;
  bool? _chaminesControleEmissoes;
  bool? _sistemaVinhaca;
  bool? _tanquesLagoasImpermeabilizadas;
  bool? _vazamentosInfiltracoes;
  bool? _efluentesDestinadosCorretamente;
  bool? _gestaoResiduosPgrs;
  bool? _areaEspecificaEnvase;
  bool? _armazenamentoRequisitosAmbientais;
  bool? _fazUsoAgrotoxicos;
  bool? _agrotoxicosReceituario;

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
    _localMateriaPrimaController.text = d['local_materia_prima']?.toString() ?? '';
    _efluentesColetaDestinacaoController.text = d['efluentes_coleta_destinacao']?.toString() ?? '';
    _residuosColetaDestinacaoController.text = d['residuos_coleta_destinacao']?.toString() ?? d['residuos_solidos']?.toString() ?? '';
    _bagacoArmazenamentoDestinacaoController.text = d['bagaco_armazenamento_destinacao']?.toString() ?? d['bagaco']?.toString() ?? '';
    _fontesTermicasQuaisController.text = d['fontes_termicas_quais']?.toString() ?? '';
    _lenhaLocalArmazenamentoController.text = d['lenha_local_armazenamento']?.toString() ?? '';
    _vinhacaCondicoesController.text = d['vinhaca_condicoes']?.toString() ?? '';
    _envaseCondicoesController.text = d['envase_condicoes']?.toString() ?? '';
    _agrotoxicosQuaisController.text = d['agrotoxicos_quais']?.toString() ?? '';
    _agrotoxicosEmbalagensDestinacaoController.text = d['agrotoxicos_embalagens_destinacao']?.toString() ?? '';
    _observacoesController.text = d['observacoes_complementares']?.toString() ?? d['observacoes']?.toString() ?? '';

    // Load choice fields with strict parsing
    _produzEfluentes = _parseBool(d['produz_efluentes']);
    _produzResiduos = _parseBool(d['produz_residuos']);
    _geraUtilizaBagaco = _parseBool(d['gera_utiliza_bagaco']);
    _fontesTermicas = _parseBool(d['fontes_termicas']);
    _utilizaLenha = _parseBool(d['utiliza_lenha']);
    
    _lenhaNativaExotica = d['lenha_nativa_exotica']?.toString()?.toUpperCase();
    if (_lenhaNativaExotica != 'NATIVA' && _lenhaNativaExotica != 'EXOTICA') {
      _lenhaNativaExotica = null;
    }

    _tanquesAdequados = _parseBool(d['tanques_adequados']);
    _higienizacaoControleEfluentes = _parseBool(d['higienizacao_controle_efluentes']);
    _fossaSeptica = _parseBool(d['fossa_septica']);
    
    // Equipamentos: support legacy conformidade flag
    _equipamentosMemorial = _parseBool(d['equipamentos_memorial']) ?? _parseBool(d['equipamentos_conformes']);
    
    _chaminesControleEmissoes = _parseBool(d['chamines_controle_emissoes']);
    _sistemaVinhaca = _parseBool(d['sistema_vinhaca']);
    _tanquesLagoasImpermeabilizadas = _parseBool(d['tanques_lagoas_impermeabilizadas']);
    _vazamentosInfiltracoes = _parseBool(d['vazamentos_infiltracoes']);
    _efluentesDestinadosCorretamente = _parseBool(d['efluentes_destinados_corretamente']);
    _gestaoResiduosPgrs = _parseBool(d['gestao_residuos_pgrs']);
    _areaEspecificaEnvase = _parseBool(d['area_especifica_envase']);
    
    // Armazenamento: support legacy conformidade flag
    _armazenamentoRequisitosAmbientais = _parseBool(d['armazenamento_requisitos_ambientais']) ?? _parseBool(d['armazenamento_ok']);
    
    _fazUsoAgrotoxicos = _parseBool(d['faz_uso_agrotoxicos']);
    _agrotoxicosReceituario = _parseBool(d['agrotoxicos_receituario']);

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
    _localMateriaPrimaController.dispose();
    _efluentesColetaDestinacaoController.dispose();
    _residuosColetaDestinacaoController.dispose();
    _bagacoArmazenamentoDestinacaoController.dispose();
    _fontesTermicasQuaisController.dispose();
    _lenhaLocalArmazenamentoController.dispose();
    _vinhacaCondicoesController.dispose();
    _envaseCondicoesController.dispose();
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
      'local_materia_prima': _localMateriaPrimaController.text,
      'produz_efluentes': _produzEfluentes,
      'efluentes_coleta_destinacao': _efluentesColetaDestinacaoController.text,
      'produz_residuos': _produzResiduos,
      'residuos_coleta_destinacao': _residuosColetaDestinacaoController.text,
      'gera_utiliza_bagaco': _geraUtilizaBagaco,
      'bagaco_armazenamento_destinacao': _bagacoArmazenamentoDestinacaoController.text,
      'fontes_termicas': _fontesTermicas,
      'fontes_termicas_quais': _fontesTermicasQuaisController.text,
      'utiliza_lenha': _utilizaLenha,
      'lenha_nativa_exotica': _lenhaNativaExotica,
      'lenha_local_armazenamento': _lenhaLocalArmazenamentoController.text,
      'tanques_adequados': _tanquesAdequados,
      'higienizacao_controle_efluentes': _higienizacaoControleEfluentes,
      'fossa_septica': _fossaSeptica,
      'equipamentos_memorial': _equipamentosMemorial,
      'chamines_controle_emissoes': _chaminesControleEmissoes,
      'sistema_vinhaca': _sistemaVinhaca,
      'vinhaca_condicoes': _vinhacaCondicoesController.text,
      'tanques_lagoas_impermeabilizadas': _tanquesLagoasImpermeabilizadas,
      'vazamentos_infiltracoes': _vazamentosInfiltracoes,
      'efluentes_destinados_corretamente': _efluentesDestinadosCorretamente,
      'gestao_residuos_pgrs': _gestaoResiduosPgrs,
      'area_especifica_envase': _areaEspecificaEnvase,
      'envase_condicoes': _envaseCondicoesController.text,
      'armazenamento_requisitos_ambientais': _armazenamentoRequisitosAmbientais,
      'faz_uso_agrotoxicos': _fazUsoAgrotoxicos,
      'agrotoxicos_quais': _agrotoxicosQuaisController.text,
      'agrotoxicos_receituario': _agrotoxicosReceituario,
      'agrotoxicos_embalagens_destinacao': _agrotoxicosEmbalagensDestinacaoController.text,
      
      // Fiscalização
      'foto_geo_ok': _fotoGeoOk,
      'infracao_constatada': _infracaoConstatada,
      'infracao_sugestao_medidas': medidas.join(', '),
      'observacoes_complementares': _observacoesController.text,

      // Legacy mappings to preserve retrocompatibility
      'residuos_solidos': _residuosColetaDestinacaoController.text,
      'bagaco': _bagacoArmazenamentoDestinacaoController.text,
      'equipamentos_conformes': _equipamentosMemorial == true,
      'armazenamento_ok': _armazenamentoRequisitosAmbientais == true,
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
                  selectedColor: primaryPurple.withOpacity(0.15),
                  checkmarkColor: primaryPurple,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: value == true ? primaryPurple : darkSlate,
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
                  selectedColor: primaryPurple.withOpacity(0.15),
                  checkmarkColor: primaryPurple,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: value == false ? primaryPurple : darkSlate,
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
    // Sanitização de Runtime
    if (_lenhaNativaExotica != 'NATIVA' && _lenhaNativaExotica != 'EXOTICA') {
      _lenhaNativaExotica = null;
    }

    return Card(
      color: Colors.purple.shade50,
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
                Icon(Icons.factory, color: primaryPurple, size: 28),
                SizedBox(width: 10),
                Text(
                  '6. ATIVIDADES AGROINDUSTRIAIS',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Divider(color: primaryPurple, thickness: 1.5, height: 24),

            // 6.1 Matéria prima
            _buildTextField(
              controller: _localMateriaPrimaController,
              label: '6.1 Local de armazenamento da matéria-prima',
            ),

            // 6.2 Efluentes
            _buildYesNoChips(
              label: '6.2 Produz efluentes?',
              value: _produzEfluentes,
              onChanged: (val) => setState(() => _produzEfluentes = val),
            ),
            if (_produzEfluentes == true)
              _buildTextField(
                controller: _efluentesColetaDestinacaoController,
                label: 'Local de coleta e destinação dos efluentes',
              ),

            // 6.3 Resíduos sólidos
            _buildYesNoChips(
              label: '6.3 Produz resíduos sólidos?',
              value: _produzResiduos,
              onChanged: (val) => setState(() => _produzResiduos = val),
            ),
            if (_produzResiduos == true)
              _buildTextField(
                controller: _residuosColetaDestinacaoController,
                label: 'Local de coleta e destinação dos resíduos sólidos',
              ),

            // 6.4 Bagaço
            _buildYesNoChips(
              label: '6.4 Gera/Utiliza bagaço?',
              value: _geraUtilizaBagaco,
              onChanged: (val) => setState(() => _geraUtilizaBagaco = val),
            ),
            if (_geraUtilizaBagaco == true)
              _buildTextField(
                controller: _bagacoArmazenamentoDestinacaoController,
                label: 'Local de armazenamento e destinação do bagaço',
              ),

            // 6.5 Fontes térmicas
            _buildYesNoChips(
              label: '6.5 Existem fontes térmicas?',
              value: _fontesTermicas,
              onChanged: (val) => setState(() => _fontesTermicas = val),
            ),
            if (_fontesTermicas == true)
              _buildTextField(
                controller: _fontesTermicasQuaisController,
                label: 'Qual a fonte térmica utilizada?',
              ),

            // 6.6 Lenha
            _buildYesNoChips(
              label: '6.6 Utiliza lenha como combustível?',
              value: _utilizaLenha,
              onChanged: (val) => setState(() => _utilizaLenha = val),
            ),
            if (_utilizaLenha == true) ...[
              const Text(
                'Origem da lenha:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Nativa', style: TextStyle(fontSize: 11))),
                      selected: _lenhaNativaExotica == 'NATIVA',
                      selectedColor: primaryPurple.withOpacity(0.15),
                      checkmarkColor: primaryPurple,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: _lenhaNativaExotica == 'NATIVA' ? primaryPurple : darkSlate,
                        fontWeight: _lenhaNativaExotica == 'NATIVA' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (selected) {
                              setState(() => _lenhaNativaExotica = selected ? 'NATIVA' : null);
                              _notifyChanges();
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Exótica', style: TextStyle(fontSize: 11))),
                      selected: _lenhaNativaExotica == 'EXOTICA',
                      selectedColor: primaryPurple.withOpacity(0.15),
                      checkmarkColor: primaryPurple,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: _lenhaNativaExotica == 'EXOTICA' ? primaryPurple : darkSlate,
                        fontWeight: _lenhaNativaExotica == 'EXOTICA' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (selected) {
                              setState(() => _lenhaNativaExotica = selected ? 'EXOTICA' : null);
                              _notifyChanges();
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _lenhaLocalArmazenamentoController,
                label: 'Local de armazenamento da lenha',
              ),
            ],

            // 6.7 Tanques
            _buildYesNoChips(
              label: '6.7 Os tanques de armazenamento dos produtos estão adequados, íntegros e identificados?',
              value: _tanquesAdequados,
              onChanged: (val) => setState(() => _tanquesAdequados = val),
            ),

            // 6.8 Higienização
            _buildYesNoChips(
              label: '6.8 Existe higienização e controle de efluentes gerados na limpeza?',
              value: _higienizacaoControleEfluentes,
              onChanged: (val) => setState(() => _higienizacaoControleEfluentes = val),
            ),

            // 6.9 Fossa séptica
            _buildYesNoChips(
              label: '6.9 Existe fossa séptica?',
              value: _fossaSeptica,
              onChanged: (val) => setState(() => _fossaSeptica = val),
            ),

            // 6.10 Equipamentos
            _buildYesNoChips(
              label: '6.10 Os equipamentos estão em conformidade com o memorial descritivo?',
              value: _equipamentosMemorial,
              onChanged: (val) => setState(() => _equipamentosMemorial = val),
            ),

            // 6.11 Chaminés
            _buildYesNoChips(
              label: '6.11 As chaminés possuem sistemas de controle de emissões atmosféricas?',
              value: _chaminesControleEmissoes,
              onChanged: (val) => setState(() => _chaminesControleEmissoes = val),
            ),

            // 6.12 Vinhaça
            _buildYesNoChips(
              label: '6.12 Possui sistema de coleta, transporte e armazenamento da vinhaça?',
              value: _sistemaVinhaca,
              onChanged: (val) => setState(() => _sistemaVinhaca = val),
            ),
            if (_sistemaVinhaca == true)
              _buildTextField(
                controller: _vinhacaCondicoesController,
                label: 'Condições do sistema de vinhaça',
              ),

            // 6.13 Tanques lagoas impermeabilizadas
            _buildYesNoChips(
              label: '6.13 Possui Tanques/lagoas impermeabilizadas?',
              value: _tanquesLagoasImpermeabilizadas,
              onChanged: (val) => setState(() => _tanquesLagoasImpermeabilizadas = val),
            ),

            // 6.14 Vazamentos ou infiltrações
            _buildYesNoChips(
              label: '6.14 Existem vazamentos ou infiltrações tanto nas tubulações quanto no armazenamento?',
              value: _vazamentosInfiltracoes,
              onChanged: (val) => setState(() => _vazamentosInfiltracoes = val),
            ),

            // 6.15 Destinação de efluentes
            _buildYesNoChips(
              label: '6.15 Os efluentes são destinados corretamente?',
              value: _efluentesDestinadosCorretamente,
              onChanged: (val) => setState(() => _efluentesDestinadosCorretamente = val),
            ),

            // 6.16 Gestão PGRS
            _buildYesNoChips(
              label: '6.16 Há gestão dos resíduos sólidos conforme PGRS apresentado?',
              value: _gestaoResiduosPgrs,
              onChanged: (val) => setState(() => _gestaoResiduosPgrs = val),
            ),

            // 6.17 Envase
            _buildYesNoChips(
              label: '6.17 Existe área específica para envase?',
              value: _areaEspecificaEnvase,
              onChanged: (val) => setState(() => _areaEspecificaEnvase = val),
            ),
            if (_areaEspecificaEnvase == true)
              _buildTextField(
                controller: _envaseCondicoesController,
                label: 'Condições da área de envase',
              ),

            // 6.18 Armazenamento produtos
            _buildYesNoChips(
              label: '6.18 O local de armazenamento dos produtos atende aos requisitos ambientais?',
              value: _armazenamentoRequisitosAmbientais,
              onChanged: (val) => setState(() => _armazenamentoRequisitosAmbientais = val),
            ),

            // 6.19 Agrotóxicos
            _buildYesNoChips(
              label: '6.19 Faz uso de agrotóxicos?',
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
                activeColor: primaryPurple,
                title: const Text(
                  '6.20 Registro Fotográfico Georreferenciado realizado conforme rito?',
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
                activeColor: primaryPurple,
                title: const Text(
                  '6.21 Houve constatação de infração?',
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
                      activeColor: primaryPurple,
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
                      activeColor: primaryPurple,
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
                      activeColor: primaryPurple,
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
