import 'package:flutter/material.dart';

class SupressaoForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool readOnly;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SupressaoForm({
    super.key,
    required this.data,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<SupressaoForm> createState() => _SupressaoFormState();
}

class _SupressaoFormState extends State<SupressaoForm> {
  // Styles & Colors
  static const Color forestGreen = Color(0xFF70B324);
  static const Color darkSlate = Color(0xFF1e293b);

  // States
  bool _temCursoDagua = false;
  bool _appPreservada = true;
  bool _indiciosUsoApp = false;
  bool _rlIsolada = true;
  bool _rlNativaCompativel = true;
  String? _bioma; // 'MA' or 'CAATINGA'

  // Bloco A - Mata Atlântica
  String? _blocoAEstagioSucessional;
  String? _blocoADapOption;
  String? _blocoAAlturaOption;
  String? _blocoASerapilheiraOption;
  String? _blocoAEpifitasOption;
  String? _blocoASubbosqueOption;
  late TextEditingController _blocoAInfoAdicionaisController;

  // Bloco B - Caatinga
  String? _blocoBEstruturaOption;
  late TextEditingController _blocoBInfoAdicionaisController;

  // Invasoras / Exóticas
  bool _presencaInvasoras = false;
  bool _presencaExoticas = false;
  late TextEditingController _especiesInvasorasController;
  String? _grauInfestacaoOption;
  bool _locApp = false;
  bool _locRl = false;
  bool _locUas = false;

  // Outros
  bool _pastosAbandonados = false;
  bool _supressaoSolo = false;
  bool _fogoApp = false;
  bool _fogoRl = false;
  bool _fogoUas = false;
  bool _fogoOutras = false;
  bool _fotoGeoOk = false;

  // Infração & DIFI
  bool _infracao = false;
  late TextEditingController _infracaoDescController;
  bool _medidaNotificacao = false;
  bool _medidaEmbargo = false;
  bool _medidaAuto = false;

  // Pareceres
  late TextEditingController _supressaoObsController;
  late TextEditingController _fatosRelevantesController;
  late TextEditingController _complementacaoNecessariaController;

  @override
  void initState() {
    super.initState();
    final d = widget.data;

    _temCursoDagua = d['tem_curso_dagua'] == true;
    _appPreservada = d['app_preservada'] != false;
    _indiciosUsoApp = d['indicios_uso_app'] == true;
    _rlIsolada = d['rl_isolada'] != false;
    _rlNativaCompativel = d['rl_nativa_compativel'] != false;
    
    _bioma = d['bioma']?.toString().toUpperCase();
    if (_bioma != 'MA' && _bioma != 'CAATINGA') {
      _bioma = 'MA';
    }

    final String? rawEstagio = d['bloco_a_estagio_sucessional']?.toString();
    const estagiosValidos = ['Inicial', 'Médio', 'Avançado'];
    if (rawEstagio != null && estagiosValidos.contains(rawEstagio)) {
      _blocoAEstagioSucessional = rawEstagio;
    } else if (rawEstagio != null && rawEstagio.startsWith('Inicial')) {
      _blocoAEstagioSucessional = 'Inicial';
    } else if (rawEstagio != null && (rawEstagio.startsWith('Médio') || rawEstagio.startsWith('Medio'))) {
      _blocoAEstagioSucessional = 'Médio';
    } else if (rawEstagio != null && rawEstagio.startsWith('Avançado')) {
      _blocoAEstagioSucessional = 'Avançado';
    } else {
      _blocoAEstagioSucessional = 'Inicial';
    }

    _blocoADapOption = d['bloco_a_dap_opcao']?.toString() ?? 'Até 8 cm';
    _blocoAAlturaOption = d['bloco_a_altura_opcao']?.toString() ?? 'Até 5 m';
    _blocoASerapilheiraOption = d['bloco_a_serapilheira_opcao']?.toString() ?? 'Inexistente ou rala';
    _blocoAEpifitasOption = d['bloco_a_epifitas_opcao']?.toString() ?? 'Ausentes';
    _blocoASubbosqueOption = d['bloco_a_subbosque_opcao']?.toString() ?? 'Ausente';
    _blocoAInfoAdicionaisController = TextEditingController(text: d['bloco_a_observacoes']?.toString() ?? '');

    _blocoBEstruturaOption = d['bloco_b_estrutura']?.toString() ?? 'Herbáceo-Arbustiva';
    _blocoBInfoAdicionaisController = TextEditingController(text: d['bloco_b_observacoes']?.toString() ?? '');

    _presencaInvasoras = d['presenca_invasoras'] == true;
    _presencaExoticas = d['presenca_exoticas'] == true;
    _especiesInvasorasController = TextEditingController(text: d['especies']?.toString() ?? '');

    final String? rawGrau = d['grau_infestacao']?.toString();
    const grausValidos = ['Baixo', 'Médio', 'Alto'];
    if (rawGrau != null && grausValidos.contains(rawGrau)) {
      _grauInfestacaoOption = rawGrau;
    } else if (rawGrau != null && rawGrau.startsWith('Baixo')) {
      _grauInfestacaoOption = 'Baixo';
    } else if (rawGrau != null && (rawGrau.startsWith('Médio') || rawGrau.startsWith('Medio'))) {
      _grauInfestacaoOption = 'Médio';
    } else if (rawGrau != null && rawGrau.startsWith('Alto')) {
      _grauInfestacaoOption = 'Alto';
    } else {
      _grauInfestacaoOption = 'Baixo';
    }
    
    _locApp = d['loc_app'] == true || d['loc_app']?.toString() == 'Sim';
    _locRl = d['loc_rl'] == true || d['loc_rl']?.toString() == 'Sim';
    _locUas = d['loc_uas'] == true || d['loc_uas']?.toString() == 'Sim';

    _pastosAbandonados = d['pastos_abandonados'] == true;
    _supressaoSolo = d['supressao_solo'] == true;
    _fogoApp = d['fogo_app'] == true;
    _fogoRl = d['fogo_rl'] == true;
    _fogoUas = d['fogo_uas'] == true;
    _fogoOutras = d['fogo_outras'] == true;
    _fotoGeoOk = d['foto_geo_ok'] == true;

    final infVal = d['infracao']?.toString() ?? '';
    _infracao = infVal.startsWith('Sim') || d['infracao_constatada'] == true;
    if (_infracao && infVal.contains(':')) {
      _infracaoDescController = TextEditingController(text: infVal.split(':').skip(1).join(':').trim());
    } else {
      _infracaoDescController = TextEditingController(text: '');
    }

    final sugeridas = d['medida_sugerida']?.toString() ?? '';
    _medidaNotificacao = sugeridas.contains('Notificação');
    _medidaEmbargo = sugeridas.contains('Embargo');
    _medidaAuto = sugeridas.contains('Auto de Infração');

    _supressaoObsController = TextEditingController(text: d['observacoes']?.toString() ?? '');
    _fatosRelevantesController = TextEditingController(text: d['fatos_relevantes']?.toString() ?? '');
    _complementacaoNecessariaController = TextEditingController(text: d['complementacao_necessaria']?.toString() ?? '');
  }

  @override
  void dispose() {
    _blocoAInfoAdicionaisController.dispose();
    _blocoBInfoAdicionaisController.dispose();
    _especiesInvasorasController.dispose();
    _infracaoDescController.dispose();
    _supressaoObsController.dispose();
    _fatosRelevantesController.dispose();
    _complementacaoNecessariaController.dispose();
    super.dispose();
  }

  void _updateBlocoAParameters(String estagio) {
    _blocoAEstagioSucessional = estagio;
    if (estagio == 'Inicial') {
      _blocoADapOption = 'Até 8 cm';
      _blocoAAlturaOption = 'Até 5 m';
      _blocoASerapilheiraOption = 'Inexistente ou rala';
      _blocoAEpifitasOption = 'Ausentes';
      _blocoASubbosqueOption = 'Ausente';
    } else if (estagio == 'Médio') {
      _blocoADapOption = '8 a 15 cm';
      _blocoAAlturaOption = '5 a 15 m';
      _blocoASerapilheiraOption = 'Camada contínua';
      _blocoAEpifitasOption = 'Presentes (Vasculares)';
      _blocoASubbosqueOption = 'Expressivo';
    } else if (estagio == 'Avançado') {
      _blocoADapOption = 'Superior a 15 cm';
      _blocoAAlturaOption = 'Superior a 15 m';
      _blocoASerapilheiraOption = 'Abundante / Decomposição';
      _blocoAEpifitasOption = 'Alta diversidade / Lenhosos';
      _blocoASubbosqueOption = 'Menos denso (dossel fechado)';
    }
    if (mounted) {
      setState(() {});
    }
    _notifyChanges();
  }

  void _notifyChanges() {
    final Map<String, dynamic> subPayload = {
      'tem_curso_dagua': _temCursoDagua,
      'app_preservada': _appPreservada,
      'indicios_uso_app': _indiciosUsoApp,
      'rl_isolada': _rlIsolada,
      'rl_nativa_compativel': _rlNativaCompativel,
      'bioma': _bioma,

      // Bloco A - Mata Atlântica
      'bloco_a_estagio_sucessional': _blocoAEstagioSucessional,
      'bloco_a_dap_opcao': _blocoADapOption,
      'bloco_a_dap': _blocoADapOption != 'Até 8 cm',
      'bloco_a_altura_opcao': _blocoAAlturaOption,
      'bloco_a_altura': _blocoAAlturaOption != 'Até 5 m',
      'bloco_a_serapilheira_opcao': _blocoASerapilheiraOption,
      'bloco_a_serapilheira': _blocoASerapilheiraOption != 'Inexistente ou rala',
      'bloco_a_epifitas_opcao': _blocoAEpifitasOption,
      'bloco_a_epifitas': _blocoAEpifitasOption != 'Ausentes',
      'bloco_a_subbosque_opcao': _blocoASubbosqueOption,
      'bloco_a_subbosque': _blocoASubbosqueOption != 'Ausente',
      'bloco_a_observacoes': _blocoAInfoAdicionaisController.text,

      // Bloco B - Caatinga
      'bloco_b_estrutura': _blocoBEstruturaOption,
      'bloco_b_observacoes': _blocoBInfoAdicionaisController.text,

      // Outros
      'presenca_invasoras': _presencaInvasoras,
      'presenca_exoticas': _presencaExoticas,
      'especies': _especiesInvasorasController.text,
      'grau_infestacao': _grauInfestacaoOption,
      'loc_app': _locApp ? 'Sim' : 'Não',
      'loc_rl': _locRl ? 'Sim' : 'Não',
      'loc_uas': _locUas ? 'Sim' : 'Não',

      'pastos_abandonados': _pastosAbandonados,
      'supressao_solo': _supressaoSolo,
      'fogo_app': _fogoApp,
      'fogo_rl': _fogoRl,
      'fogo_uas': _fogoUas,
      'fogo_outras': _fogoOutras,
      'foto_geo_ok': _fotoGeoOk,

      'infracao': _infracao ? 'Sim: ${_infracaoDescController.text.trim()}' : 'Não',
      'infracao_constatada': _infracao,
      'medida_sugerida': [
        if (_medidaNotificacao) 'Notificação',
        if (_medidaEmbargo) 'Embargo',
        if (_medidaAuto) 'Auto de Infração',
      ].join(', '),

      'observacoes': _supressaoObsController.text,
      'fatos_relevantes': _fatosRelevantesController.text,
      'complementacao_necessaria': _complementacaoNecessariaController.text,
    };
    widget.onChanged(subPayload);
  }

  Widget _buildReadOnlyParamRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: forestGreen.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaatingaOptionTile({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _blocoBEstruturaOption == value;
    return InkWell(
      onTap: widget.readOnly
          ? null
          : () {
              setState(() => _blocoBEstruturaOption = value);
              _notifyChanges();
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? forestGreen.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? forestGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? forestGreen : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? forestGreen : darkSlate),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: isSelected ? forestGreen.withOpacity(0.8) : Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sanitização de segurança em tempo de execução para imunidade absoluta contra crashes de Dropdown
    const estagiosValidos = ['Inicial', 'Médio', 'Avançado'];
    if (_blocoAEstagioSucessional == null || !estagiosValidos.contains(_blocoAEstagioSucessional)) {
      if (_blocoAEstagioSucessional != null && _blocoAEstagioSucessional!.startsWith('Inicial')) {
        _blocoAEstagioSucessional = 'Inicial';
      } else if (_blocoAEstagioSucessional != null && (_blocoAEstagioSucessional!.startsWith('Médio') || _blocoAEstagioSucessional!.startsWith('Medio'))) {
        _blocoAEstagioSucessional = 'Médio';
      } else if (_blocoAEstagioSucessional != null && _blocoAEstagioSucessional!.startsWith('Avançado')) {
        _blocoAEstagioSucessional = 'Avançado';
      } else {
        _blocoAEstagioSucessional = 'Inicial';
      }
    }

    const grausValidos = ['Baixo', 'Médio', 'Alto'];
    if (_grauInfestacaoOption == null || !grausValidos.contains(_grauInfestacaoOption)) {
      if (_grauInfestacaoOption != null && _grauInfestacaoOption!.startsWith('Baixo')) {
        _grauInfestacaoOption = 'Baixo';
      } else if (_grauInfestacaoOption != null && (_grauInfestacaoOption!.startsWith('Médio') || _grauInfestacaoOption!.startsWith('Medio'))) {
        _grauInfestacaoOption = 'Médio';
      } else if (_grauInfestacaoOption != null && _grauInfestacaoOption!.startsWith('Alto')) {
        _grauInfestacaoOption = 'Alto';
      } else {
        _grauInfestacaoOption = 'Baixo';
      }
    }

    final bool isMa = _bioma == 'MA';

    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // HEADER
            // ==========================================
            Row(
              children: [
                const Icon(Icons.forest_outlined, color: forestGreen, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parâmetros Técnicos: Supressão Vegetal',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: forestGreen),
                      ),
                      Text(
                        'Ficha técnica de diagnóstico físico-florestal do imóvel',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // ==========================================
            // BLOCO 1: ÁREAS PROTEGIDAS
            // ==========================================
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: forestGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  '1. Áreas Protegidas e APP',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Existe curso d\'água / nascente / lago no imóvel?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _temCursoDagua,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _temCursoDagua = val);
                      _notifyChanges();
                    },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('A vegetação da APP está preservada?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _appPreservada,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _appPreservada = val);
                      _notifyChanges();
                    },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Há indícios de uso do solo ou supressão na APP?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _indiciosUsoApp,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _indiciosUsoApp = val);
                      _notifyChanges();
                    },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('A Reserva Legal está isolada de atividades produtivas?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _rlIsolada,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _rlIsolada = val);
                      _notifyChanges();
                    },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('A vegetação nativa da RL é compatível com o CAR?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _rlNativaCompativel,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _rlNativaCompativel = val);
                      _notifyChanges();
                    },
            ),
            const SizedBox(height: 16),

            // ==========================================
            // BLOCO 2: BIOMA & FICHA TÉCNICA
            // ==========================================
            const Row(
              children: [
                Icon(Icons.nature_outlined, color: forestGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  '2. Bioma Predominante',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Mata Atlântica', style: TextStyle(fontSize: 12))),
                    selected: isMa,
                    selectedColor: forestGreen.withOpacity(0.15),
                    checkmarkColor: forestGreen,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isMa ? forestGreen : darkSlate,
                      fontWeight: isMa ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _bioma = 'MA');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Caatinga', style: TextStyle(fontSize: 12))),
                    selected: !isMa,
                    selectedColor: forestGreen.withOpacity(0.15),
                    checkmarkColor: forestGreen,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: !isMa ? forestGreen : darkSlate,
                      fontWeight: !isMa ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _bioma = 'CAATINGA');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bloco A - Mata Atlântica Details
            if (isMa) ...[
              const Text(
                'Ficha de Caracterização da Mata Atlântica:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: forestGreen),
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Estágio Sucessional da Vegetação:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Inicial', style: TextStyle(fontSize: 12))),
                      selected: _blocoAEstagioSucessional == 'Inicial',
                      selectedColor: forestGreen.withOpacity(0.15),
                      checkmarkColor: forestGreen,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _blocoAEstagioSucessional == 'Inicial' ? forestGreen : darkSlate,
                        fontWeight: _blocoAEstagioSucessional == 'Inicial' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (selected) {
                              if (selected) {
                                _updateBlocoAParameters('Inicial');
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Médio', style: TextStyle(fontSize: 12))),
                      selected: _blocoAEstagioSucessional == 'Médio',
                      selectedColor: forestGreen.withOpacity(0.15),
                      checkmarkColor: forestGreen,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _blocoAEstagioSucessional == 'Médio' ? forestGreen : darkSlate,
                        fontWeight: _blocoAEstagioSucessional == 'Médio' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (selected) {
                              if (selected) {
                                _updateBlocoAParameters('Médio');
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Avançado', style: TextStyle(fontSize: 12))),
                      selected: _blocoAEstagioSucessional == 'Avançado',
                      selectedColor: forestGreen.withOpacity(0.15),
                      checkmarkColor: forestGreen,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _blocoAEstagioSucessional == 'Avançado' ? forestGreen : darkSlate,
                        fontWeight: _blocoAEstagioSucessional == 'Avançado' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (selected) {
                              if (selected) {
                                _updateBlocoAParameters('Avançado');
                              }
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Parâmetros Observados e Medições:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildReadOnlyParamRow('DAP Médio estimado', _blocoADapOption!, Icons.straighten_outlined),
              _buildReadOnlyParamRow('Altura do dossel superior', _blocoAAlturaOption!, Icons.height_outlined),
              _buildReadOnlyParamRow('Camada de Serapilheira', _blocoASerapilheiraOption!, Icons.layers_outlined),
              _buildReadOnlyParamRow('Epífitas / Trepadeiras', _blocoAEpifitasOption!, Icons.eco_outlined),
              _buildReadOnlyParamRow('Sub-bosque florestal', _blocoASubbosqueOption!, Icons.park_outlined),
              const SizedBox(height: 8),

              TextFormField(
                controller: _blocoAInfoAdicionaisController,
                enabled: !widget.readOnly,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Informações Adicionais (Mata Atlântica)',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ] else ...[
              // Bloco B - Caatinga Details
              const Text(
                'Estrutura Fitofisionômica da Caatinga:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: forestGreen),
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  _buildCaatingaOptionTile(
                    title: 'Herbáceo-Arbustiva',
                    subtitle: 'Estrato predominantemente baixo, rasteiro e com arbustos esparsos decíduos.',
                    value: 'Herbáceo-Arbustiva',
                  ),
                  const SizedBox(height: 8),
                  _buildCaatingaOptionTile(
                    title: 'Arbustivo-Arbórea',
                    subtitle: 'Mistura densa de arbustos espinhosos com árvores de pequeno e médio porte.',
                    value: 'Arbustivo-Arbórea',
                  ),
                  const SizedBox(height: 8),
                  _buildCaatingaOptionTile(
                    title: 'Arbórea Dominante',
                    subtitle: 'Dossel mais fechado com árvores de maior porte (Juazeiro, Umbuzeiro, etc.).',
                    value: 'Arbórea dominante',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _blocoBInfoAdicionaisController,
                enabled: !widget.readOnly,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Informações Adicionais (Caatinga)',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ],
            const SizedBox(height: 24),

            // ==========================================
            // BLOCO 3: DIAGNÓSTICO VEGETAL E FÍSICO
            // ==========================================
            const Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: forestGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  '3. Diagnóstico Físico-Ambiental',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Presença de espécies exóticas?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _presencaExoticas,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _presencaExoticas = val);
                      _notifyChanges();
                    },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Presença de espécies exóticas invasoras?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _presencaInvasoras,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _presencaInvasoras = val);
                      _notifyChanges();
                    },
            ),
            if (_presencaInvasoras || _presencaExoticas) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _especiesInvasorasController,
                enabled: !widget.readOnly,
                decoration: const InputDecoration(
                  labelText: 'Descrever Espécies (Nome popular/científico)',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Grau de Infestação:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Baixo', style: TextStyle(fontSize: 12))),
                      selected: _grauInfestacaoOption == 'Baixo',
                      selectedColor: forestGreen.withOpacity(0.15),
                      checkmarkColor: forestGreen,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _grauInfestacaoOption == 'Baixo' ? forestGreen : darkSlate,
                        fontWeight: _grauInfestacaoOption == 'Baixo' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() => _grauInfestacaoOption = 'Baixo');
                                _notifyChanges();
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Médio', style: TextStyle(fontSize: 12))),
                      selected: _grauInfestacaoOption == 'Médio',
                      selectedColor: forestGreen.withOpacity(0.15),
                      checkmarkColor: forestGreen,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _grauInfestacaoOption == 'Médio' ? forestGreen : darkSlate,
                        fontWeight: _grauInfestacaoOption == 'Médio' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() => _grauInfestacaoOption = 'Médio');
                                _notifyChanges();
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Alto', style: TextStyle(fontSize: 12))),
                      selected: _grauInfestacaoOption == 'Alto',
                      selectedColor: forestGreen.withOpacity(0.15),
                      checkmarkColor: forestGreen,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _grauInfestacaoOption == 'Alto' ? forestGreen : darkSlate,
                        fontWeight: _grauInfestacaoOption == 'Alto' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: widget.readOnly
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() => _grauInfestacaoOption = 'Alto');
                                _notifyChanges();
                              }
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Localização da ocorrência das invasoras/exóticas:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
              ),
              const SizedBox(height: 6),
              CheckboxListTile(
                title: const Text('Área de Preservação Permanente (APP)', style: TextStyle(fontSize: 12)),
                value: _locApp,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _locApp = val!);
                        _notifyChanges();
                      },
              ),
              CheckboxListTile(
                title: const Text('Reserva Legal (RL)', style: TextStyle(fontSize: 12)),
                value: _locRl,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _locRl = val!);
                        _notifyChanges();
                      },
              ),
              CheckboxListTile(
                title: const Text('Uso Alternativo do Solo (UAS)', style: TextStyle(fontSize: 12)),
                value: _locUas,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _locUas = val!);
                        _notifyChanges();
                      },
              ),
            ],
            const SizedBox(height: 12),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Existência de pastos ou roçados abandonados há mais de 5 anos?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _pastosAbandonados,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _pastosAbandonados = val);
                      _notifyChanges();
                    },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Houve supressão vegetal recente ou movimentação de solo?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _supressaoSolo,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _supressaoSolo = val);
                      _notifyChanges();
                    },
            ),
            const SizedBox(height: 16),

            // ==========================================
            // BLOCO 4: USO DO FOGO
            // ==========================================
            const Row(
              children: [
                Icon(Icons.local_fire_department_outlined, color: forestGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  '4. Registro de Ocorrência de Fogo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const Text(
              'Assinale onde foram constatados indícios de uso do fogo:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 6),
            CheckboxListTile(
              title: const Text('Em Área de Preservação Permanente (APP)', style: TextStyle(fontSize: 12)),
              value: _fogoApp,
              dense: true,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _fogoApp = val!);
                      _notifyChanges();
                    },
            ),
            CheckboxListTile(
              title: const Text('Em Reserva Legal (RL)', style: TextStyle(fontSize: 12)),
              value: _fogoRl,
              dense: true,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _fogoRl = val!);
                      _notifyChanges();
                    },
            ),
            CheckboxListTile(
              title: const Text('Na área de Uso Alternativo do Solo (UAS)', style: TextStyle(fontSize: 12)),
              value: _fogoUas,
              dense: true,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _fogoUas = val!);
                      _notifyChanges();
                    },
            ),
            CheckboxListTile(
              title: const Text('Em outras áreas do imóvel rural', style: TextStyle(fontSize: 12)),
              value: _fogoOutras,
              dense: true,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _fogoOutras = val!);
                      _notifyChanges();
                    },
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Registro Fotográfico Georreferenciado realizado conforme rito?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _fotoGeoOk,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _fotoGeoOk = val);
                      _notifyChanges();
                    },
            ),
            const SizedBox(height: 24),

            // ==========================================
            // BLOCO 5: FISCALIZAÇÃO & INFRAÇÃO
            // ==========================================
            const Row(
              children: [
                Icon(Icons.gavel_outlined, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  '5. Constatação de Infração',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Houve constatação de infração ambiental no local?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _infracao,
              activeColor: Colors.red,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _infracao = val);
                      _notifyChanges();
                    },
            ),
            if (_infracao) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _infracaoDescController,
                enabled: !widget.readOnly,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrever a infração ambiental constatada',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sugestão de medidas a serem adotadas pela DIFI:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
              ),
              const SizedBox(height: 6),
              CheckboxListTile(
                title: const Text('Notificação', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                value: _medidaNotificacao,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _medidaNotificacao = val!);
                        _notifyChanges();
                      },
              ),
              CheckboxListTile(
                title: const Text('Embargo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                value: _medidaEmbargo,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _medidaEmbargo = val!);
                        _notifyChanges();
                      },
              ),
              CheckboxListTile(
                title: const Text('Auto de Infração', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                value: _medidaAuto,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _medidaAuto = val!);
                        _notifyChanges();
                      },
              ),
            ],
            const SizedBox(height: 24),

            // ==========================================
            // BLOCO 6: PARECER TÉCNICO
            // ==========================================
            const Row(
              children: [
                Icon(Icons.rate_review_outlined, color: forestGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  '6. Parecer Técnico & Observações',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            TextFormField(
              controller: _supressaoObsController,
              enabled: !widget.readOnly,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observações Técnicas / Parecer Geral (Obrigatório)',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fatosRelevantesController,
              enabled: !widget.readOnly,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Fatos Relevantes Constatados',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _complementacaoNecessariaController,
              enabled: !widget.readOnly,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Complementações Necessárias',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _notifyChanges(),
            ),
          ],
        ),
      ),
    );
  }
}
