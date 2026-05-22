import 'package:flutter/material.dart';

class AviculturaForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool readOnly;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const AviculturaForm({
    super.key,
    required this.data,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  State<AviculturaForm> createState() => _AviculturaFormState();
}

class _AviculturaFormState extends State<AviculturaForm> {
  // Styles & Colors
  static const Color forestGreen = Color(0xFF006b33);
  static const Color darkSlate = Color(0xFF1e293b);
  static const Color amberDark = Color(0xFFb45309);

  // Controllers & State
  String? _modelo; // 'CORTE' or 'POSTURA'
  bool _fotoGeoOk = false;

  // Corte specific
  String? _corteSistemaCriacao;
  bool _corteAvesSoltasChao = false;
  bool _corteCamaCascaArroz = false;
  bool _corteGalpoesLongos = false;
  bool _corteGalpoesCurtos = false;
  bool _corteBebedourosChao = false;
  bool _corteBebedourosSuspensos = false;
  bool _corteComedourosChao = false;
  bool _corteComedourosSuspensos = false;
  bool _cortePintos = false;
  bool _corteFrangos = false;
  bool _corteVentiladores = false;
  bool _corteVentiladoresFunc = false;
  bool _corteSemVentiladores = false;
  late TextEditingController _corteComprimentoController;
  late TextEditingController _corteLarguraController;
  late TextEditingController _corteAreaController;
  String? _corteDensidade;
  late TextEditingController _corteQtdEstimadaController;
  String? _corteCamaDestinacao;
  late TextEditingController _corteCamaOutrosController;
  late TextEditingController _corteInfoAdicionalController;

  // Postura specific
  String? _posturaSistemaCriacao;
  String? _posturaTipoConfinamento;
  late TextEditingController _posturaFileirasController;
  late TextEditingController _posturaAndaresController;
  late TextEditingController _posturaGaiolasModuloController;
  late TextEditingController _posturaAvesGaiolaController;
  late TextEditingController _posturaQtdEstimadaController;
  late TextEditingController _posturaInfoAdicionalController;

  // Shared / Environmental / DIFI
  bool _aviculturaGeraResiduos = false;
  late TextEditingController _aviculturaResiduosDetalhesController;
  bool _aviculturaMortosIncinerados = true;
  late TextEditingController _aviculturaMortosDestinacaoAltController;
  bool _aviculturaInfracao = false;
  bool _aviculturaMedidaNotificacao = false;
  bool _aviculturaMedidaEmbargo = false;
  bool _aviculturaMedidaAuto = false;
  late TextEditingController _aviculturaObservacoesController;

  @override
  void initState() {
    super.initState();
    final d = widget.data;

    _modelo = d['modelo']?.toString()?.toUpperCase();
    if (_modelo != 'CORTE' && _modelo != 'POSTURA') {
      _modelo = 'CORTE';
    }
    _fotoGeoOk = d['foto_geo_ok'] == true;

    // Initialize Corte fields
    final String? rawCorteSistema = d['corte_sistema_criacao']?.toString();
    if (rawCorteSistema == 'Soltas') {
      _corteSistemaCriacao = 'Extensivo / Caipira';
    } else if (rawCorteSistema == 'Confinadas') {
      _corteSistemaCriacao = 'Intensivo (Confinado)';
    } else if (rawCorteSistema != null &&
        ['Intensivo (Confinado)', 'Semi-intensivo', 'Extensivo / Caipira'].contains(rawCorteSistema)) {
      _corteSistemaCriacao = rawCorteSistema;
    } else {
      _corteSistemaCriacao = 'Intensivo (Confinado)';
    }
    _corteAvesSoltasChao = d['corte_aves_soltas_chao'] == true;
    _corteCamaCascaArroz = d['corte_cama_casca_arroz'] == true;
    _corteGalpoesLongos = d['corte_galpoes_longos'] == true;
    _corteGalpoesCurtos = d['corte_galpoes_curtos'] == true;
    _corteBebedourosChao = d['corte_bebedouros_chao'] == true;
    _corteBebedourosSuspensos = d['corte_bebedouros_suspensos'] == true;
    _corteComedourosChao = d['corte_comedouros_chao'] == true;
    _corteComedourosSuspensos = d['corte_comedouros_suspensos'] == true;
    _cortePintos = d['corte_pintos'] == true;
    _corteFrangos = d['corte_frangos'] == true;
    _corteVentiladores = d['corte_ventiladores'] == true;
    _corteVentiladoresFunc = d['corte_ventiladores_func'] == true;
    _corteSemVentiladores = d['corte_sem_ventiladores'] == true;

    _corteComprimentoController = TextEditingController(text: d['corte_comprimento']?.toString() ?? '');
    _corteLarguraController = TextEditingController(text: d['corte_largura']?.toString() ?? '');
    _corteAreaController = TextEditingController(text: d['corte_area']?.toString() ?? '');
    _corteDensidade = d['corte_densidade']?.toString() ?? 'Convencional (12 a 15 aves/m²)';
    _corteQtdEstimadaController = TextEditingController(text: d['corte_qtd_estimada']?.toString() ?? '');
    _corteCamaDestinacao = d['corte_cama_destinacao']?.toString() ?? 'Compostagem';
    _corteCamaOutrosController = TextEditingController(text: d['corte_cama_outros']?.toString() ?? '');
    _corteInfoAdicionalController = TextEditingController(text: d['corte_info_adicional']?.toString() ?? '');

    // Initialize Postura fields
    _posturaSistemaCriacao = d['postura_sistema_criacao']?.toString() ?? 'Confinadas';
    _posturaTipoConfinamento = d['postura_tipo_confinamento']?.toString() ?? 'Gaiolas';
    _posturaFileirasController = TextEditingController(text: d['postura_fileiras']?.toString() ?? '');
    _posturaAndaresController = TextEditingController(text: d['postura_andares']?.toString() ?? '');
    _posturaGaiolasModuloController = TextEditingController(text: d['postura_gaiolas_modulo']?.toString() ?? '');
    _posturaAvesGaiolaController = TextEditingController(text: d['postura_aves_gaiola']?.toString() ?? '');
    _posturaQtdEstimadaController = TextEditingController(text: d['postura_qtd_estimada']?.toString() ?? '');
    _posturaInfoAdicionalController = TextEditingController(text: d['postura_info_adicional']?.toString() ?? '');

    // Initialize Environmental / Shared
    _aviculturaGeraResiduos = d['gera_residuos'] == true;
    _aviculturaResiduosDetalhesController = TextEditingController(text: d['residuos_detalhes']?.toString() ?? '');
    _aviculturaMortosIncinerados = d['mortos_incinerados'] != false;
    _aviculturaMortosDestinacaoAltController = TextEditingController(text: d['mortos_destinacao_alt']?.toString() ?? '');
    _aviculturaInfracao = d['infracao_constatada'] == true;

    final sugeridas = d['medida_sugerida']?.toString() ?? '';
    _aviculturaMedidaNotificacao = sugeridas.contains('Notificação');
    _aviculturaMedidaEmbargo = sugeridas.contains('Embargo');
    _aviculturaMedidaAuto = sugeridas.contains('Auto de Infração');

    _aviculturaObservacoesController = TextEditingController(text: d['observacoes']?.toString() ?? '');
  }

  @override
  void dispose() {
    _corteComprimentoController.dispose();
    _corteLarguraController.dispose();
    _corteAreaController.dispose();
    _corteQtdEstimadaController.dispose();
    _corteCamaOutrosController.dispose();
    _corteInfoAdicionalController.dispose();

    _posturaFileirasController.dispose();
    _posturaAndaresController.dispose();
    _posturaGaiolasModuloController.dispose();
    _posturaAvesGaiolaController.dispose();
    _posturaQtdEstimadaController.dispose();
    _posturaInfoAdicionalController.dispose();

    _aviculturaResiduosDetalhesController.dispose();
    _aviculturaMortosDestinacaoAltController.dispose();
    _aviculturaObservacoesController.dispose();
    super.dispose();
  }

  void _calculateCorteQtd() {
    final double? comprimento = double.tryParse(_corteComprimentoController.text);
    final double? largura = double.tryParse(_corteLarguraController.text);

    if (comprimento != null && largura != null) {
      final double area = comprimento * largura;
      _corteAreaController.text = area.toStringAsFixed(2);

      double densidadeFator = 12.0;
      if (_corteDensidade != null) {
        final dStr = _corteDensidade!.toLowerCase();
        if (dStr.contains('climatizado')) {
          densidadeFator = 18.0;
        } else if (dStr.contains('fechado')) {
          densidadeFator = 14.0;
        } else if (dStr.contains('exaustores')) {
          densidadeFator = 13.0;
        } else {
          densidadeFator = 12.0;
        }
      }

      final int totalAves = (area * densidadeFator).round();
      _corteQtdEstimadaController.text = totalAves.toString();
    } else {
      _corteAreaController.text = '';
      _corteQtdEstimadaController.text = '';
    }
    _notifyChanges();
  }

  void _calculatePosturaQtd() {
    final int? fileiras = int.tryParse(_posturaFileirasController.text);
    final int? andares = int.tryParse(_posturaAndaresController.text);
    final int? gaiolas = int.tryParse(_posturaGaiolasModuloController.text);
    final int? aves = int.tryParse(_posturaAvesGaiolaController.text);

    if (fileiras != null && andares != null && gaiolas != null && aves != null) {
      final int total = fileiras * andares * gaiolas * aves;
      _posturaQtdEstimadaController.text = total.toString();
    } else {
      _posturaQtdEstimadaController.text = '';
    }
    _notifyChanges();
  }

  void _notifyChanges() {
    final Map<String, dynamic> subPayload = {
      'modelo': _modelo,
      'foto_geo_ok': _fotoGeoOk,

      // Corte fields
      'corte_sistema_criacao': _corteSistemaCriacao,
      'corte_aves_soltas_chao': _corteAvesSoltasChao,
      'corte_cama_casca_arroz': _corteCamaCascaArroz,
      'corte_galpoes_longos': _corteGalpoesLongos,
      'corte_galpoes_curtos': _corteGalpoesCurtos,
      'corte_bebedouros_chao': _corteBebedourosChao,
      'corte_bebedouros_suspensos': _corteBebedourosSuspensos,
      'corte_comedouros_chao': _corteComedourosChao,
      'corte_comedouros_suspensos': _corteComedourosSuspensos,
      'corte_pintos': _cortePintos,
      'corte_frangos': _corteFrangos,
      'corte_ventiladores': _corteVentiladores,
      'corte_ventiladores_func': _corteVentiladoresFunc,
      'corte_sem_ventiladores': _corteSemVentiladores,
      'corte_info_adicional': _corteInfoAdicionalController.text,
      'corte_comprimento': double.tryParse(_corteComprimentoController.text),
      'corte_largura': double.tryParse(_corteLarguraController.text),
      'corte_area': double.tryParse(_corteAreaController.text),
      'corte_densidade': _corteDensidade,
      'corte_qtd_estimada': int.tryParse(_corteQtdEstimadaController.text),
      'corte_cama_destinacao': _corteCamaDestinacao,
      'corte_cama_outros': _corteCamaOutrosController.text,

      // Postura fields
      'postura_sistema_criacao': _posturaSistemaCriacao,
      'postura_tipo_confinamento': _posturaTipoConfinamento,
      'postura_info_adicional': _posturaInfoAdicionalController.text,
      'postura_fileiras': int.tryParse(_posturaFileirasController.text),
      'postura_andares': int.tryParse(_posturaAndaresController.text),
      'postura_gaiolas_modulo': int.tryParse(_posturaGaiolasModuloController.text),
      'postura_aves_gaiola': int.tryParse(_posturaAvesGaiolaController.text),
      'postura_qtd_estimada': int.tryParse(_posturaQtdEstimadaController.text),

      // Shared
      'gera_residuos': _aviculturaGeraResiduos,
      'residuos_detalhes': _aviculturaResiduosDetalhesController.text,
      'mortos_incinerados': _aviculturaMortosIncinerados,
      'mortos_destinacao_alt': _aviculturaMortosDestinacaoAltController.text,
      'infracao_constatada': _aviculturaInfracao,
      'medida_sugerida': [
        if (_aviculturaMedidaNotificacao) 'Notificação',
        if (_aviculturaMedidaEmbargo) 'Embargo',
        if (_aviculturaMedidaAuto) 'Auto de Infração',
      ].join(', '),
      'observacoes': _aviculturaObservacoesController.text,
    };
    widget.onChanged(subPayload);
  }

  @override
  Widget build(BuildContext context) {
    if (_corteSistemaCriacao == 'Soltas') {
      _corteSistemaCriacao = 'Extensivo / Caipira';
    } else if (_corteSistemaCriacao == 'Confinadas') {
      _corteSistemaCriacao = 'Intensivo (Confinado)';
    } else if (_corteSistemaCriacao == null ||
        !['Intensivo (Confinado)', 'Semi-intensivo', 'Extensivo / Caipira'].contains(_corteSistemaCriacao)) {
      _corteSistemaCriacao = 'Intensivo (Confinado)';
    }

    return Card(
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // HEADER & SELEÇÃO DO MODELO
            // ==========================================
            Row(
              children: [
                const Icon(Icons.egg_outlined, color: amberDark, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parâmetros Técnicos: Avicultura',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: amberDark),
                      ),
                      Text(
                        'Selecione o modelo de produção para detalhar',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Corte (Frangos)', style: TextStyle(fontSize: 12))),
                    selected: _modelo == 'CORTE',
                    selectedColor: forestGreen.withOpacity(0.15),
                    checkmarkColor: forestGreen,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _modelo == 'CORTE' ? forestGreen : darkSlate,
                      fontWeight: _modelo == 'CORTE' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _modelo = 'CORTE');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Postura (Ovos)', style: TextStyle(fontSize: 12))),
                    selected: _modelo == 'POSTURA',
                    selectedColor: forestGreen.withOpacity(0.15),
                    checkmarkColor: forestGreen,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _modelo == 'POSTURA' ? forestGreen : darkSlate,
                      fontWeight: _modelo == 'POSTURA' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: widget.readOnly
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() => _modelo = 'POSTURA');
                              _notifyChanges();
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ==========================================
            // MODELO: CORTE
            // ==========================================
            if (_modelo == 'CORTE') ...[
              const Row(
                children: [
                  Icon(Icons.settings_outlined, color: amberDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '1. Avicultura de Corte',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              DropdownButtonFormField<String>(
                value: _corteSistemaCriacao,
                decoration: const InputDecoration(
                  labelText: 'Sistema de Criação',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: ['Intensivo (Confinado)', 'Semi-intensivo', 'Extensivo / Caipira']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _corteSistemaCriacao = val);
                        _notifyChanges();
                      },
              ),
              const SizedBox(height: 16),

              const Text(
                'Características do Galpão (Selecione todos aplicáveis):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
              ),
              const SizedBox(height: 8),

              // Switch layout 1
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aves soltas no chão', style: TextStyle(fontSize: 13)),
                value: _corteAvesSoltasChao,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _corteAvesSoltasChao = val);
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Criação sobre cama (ex. casca de arroz/maravalha)', style: TextStyle(fontSize: 13)),
                value: _corteCamaCascaArroz,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _corteCamaCascaArroz = val);
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dimensões: Galpões Longos (> 50m)', style: TextStyle(fontSize: 13)),
                value: _corteGalpoesLongos,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() {
                          _corteGalpoesLongos = val;
                          if (val) _corteGalpoesCurtos = false;
                        });
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dimensões: Galpões Curtos (< 50m)', style: TextStyle(fontSize: 13)),
                value: _corteGalpoesCurtos,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() {
                          _corteGalpoesCurtos = val;
                          if (val) _corteGalpoesLongos = false;
                        });
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bebedouros no chão', style: TextStyle(fontSize: 13)),
                value: _corteBebedourosChao,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() {
                          _corteBebedourosChao = val;
                          if (val) _corteBebedourosSuspensos = false;
                        });
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bebedouros suspensos / automáticos (Nipple)', style: TextStyle(fontSize: 13)),
                value: _corteBebedourosSuspensos,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() {
                          _corteBebedourosSuspensos = val;
                          if (val) _corteBebedourosChao = false;
                        });
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Comedouros no chão', style: TextStyle(fontSize: 13)),
                value: _corteComedourosChao,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() {
                          _corteComedourosChao = val;
                          if (val) _corteComedourosSuspensos = false;
                        });
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Comedouros suspensos', style: TextStyle(fontSize: 13)),
                value: _corteComedourosSuspensos,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() {
                          _corteComedourosSuspensos = val;
                          if (val) _corteComedourosChao = false;
                        });
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fase Pintos (Alojamento Inicial)', style: TextStyle(fontSize: 13)),
                value: _cortePintos,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _cortePintos = val);
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fase Frangos (Crescimento / Engorda)', style: TextStyle(fontSize: 13)),
                value: _corteFrangos,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _corteFrangos = val);
                        _notifyChanges();
                      },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Possui ventiladores / exaustores internos', style: TextStyle(fontSize: 13)),
                value: _corteVentiladores,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() {
                          _corteVentiladores = val;
                          if (val) _corteSemVentiladores = false;
                        });
                        _notifyChanges();
                      },
              ),
              if (_corteVentiladores)
                SwitchListTile(
                  contentPadding: const EdgeInsets.only(left: 20),
                  title: const Text('Equipamentos em pleno funcionamento', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _corteVentiladoresFunc,
                  activeColor: forestGreen,
                  onChanged: widget.readOnly
                      ? null
                      : (val) {
                          setState(() => _corteVentiladoresFunc = val);
                          _notifyChanges();
                        },
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Não possui ventiladores ou climatizadores', style: TextStyle(fontSize: 13)),
                value: _corteSemVentiladores,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() {
                          _corteSemVentiladores = val;
                          if (val) {
                            _corteVentiladores = false;
                            _corteVentiladoresFunc = false;
                          }
                        });
                        _notifyChanges();
                      },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _corteInfoAdicionalController,
                enabled: !widget.readOnly,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Informações Adicionais (Corte)',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
              const SizedBox(height: 24),

              const Row(
                children: [
                  Icon(Icons.analytics_outlined, color: amberDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '3. Estimativa de Animais (Corte)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _corteComprimentoController,
                      enabled: !widget.readOnly,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _calculateCorteQtd(),
                      decoration: const InputDecoration(
                        labelText: 'Comprimento (m)',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _corteLarguraController,
                      enabled: !widget.readOnly,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _calculateCorteQtd(),
                      decoration: const InputDecoration(
                        labelText: 'Largura (m)',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _corteAreaController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Área do Galpão (m²) - Automático',
                  border: OutlineInputBorder(),
                  fillColor: Color(0xFFf1f5f9),
                  filled: true,
                  prefixIcon: Icon(Icons.square_foot),
                ),
              ),
              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Densidade Recomendada:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Convencional (12-15)', style: TextStyle(fontSize: 10))),
                                selected: _corteDensidade == 'Convencional (12 a 15 aves/m²)',
                                selectedColor: forestGreen.withOpacity(0.15),
                                checkmarkColor: forestGreen,
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  color: _corteDensidade == 'Convencional (12 a 15 aves/m²)' ? forestGreen : darkSlate,
                                  fontWeight: _corteDensidade == 'Convencional (12 a 15 aves/m²)' ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: widget.readOnly
                                    ? null
                                    : (selected) {
                                        if (selected) {
                                          setState(() => _corteDensidade = 'Convencional (12 a 15 aves/m²)');
                                          _calculateCorteQtd();
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Climatizado (18-22)', style: TextStyle(fontSize: 10))),
                                selected: _corteDensidade == 'Climatizado / Pressão Negativa (18 a 22 aves/m²)',
                                selectedColor: forestGreen.withOpacity(0.15),
                                checkmarkColor: forestGreen,
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  color: _corteDensidade == 'Climatizado / Pressão Negativa (18 a 22 aves/m²)' ? forestGreen : darkSlate,
                                  fontWeight: _corteDensidade == 'Climatizado / Pressão Negativa (18 a 22 aves/m²)' ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: widget.readOnly
                                    ? null
                                    : (selected) {
                                        if (selected) {
                                          setState(() => _corteDensidade = 'Climatizado / Pressão Negativa (18 a 22 aves/m²)');
                                          _calculateCorteQtd();
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Galpão Fechado', style: TextStyle(fontSize: 10))),
                                selected: _corteDensidade == 'Galpão fechado / vedado',
                                selectedColor: forestGreen.withOpacity(0.15),
                                checkmarkColor: forestGreen,
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  color: _corteDensidade == 'Galpão fechado / vedado' ? forestGreen : darkSlate,
                                  fontWeight: _corteDensidade == 'Galpão fechado / vedado' ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: widget.readOnly
                                    ? null
                                    : (selected) {
                                        if (selected) {
                                          setState(() => _corteDensidade = 'Galpão fechado / vedado');
                                          _calculateCorteQtd();
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Exaustores G.', style: TextStyle(fontSize: 10))),
                                selected: _corteDensidade == 'Presença de exaustores grandes',
                                selectedColor: forestGreen.withOpacity(0.15),
                                checkmarkColor: forestGreen,
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  color: _corteDensidade == 'Presença de exaustores grandes' ? forestGreen : darkSlate,
                                  fontWeight: _corteDensidade == 'Presença de exaustores grandes' ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: widget.readOnly
                                    ? null
                                    : (selected) {
                                        if (selected) {
                                          setState(() => _corteDensidade = 'Presença de exaustores grandes');
                                          _calculateCorteQtd();
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _corteQtdEstimadaController,
                enabled: !widget.readOnly,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade Estimada de Aves',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.show_chart),
                ),
                onChanged: (_) => _notifyChanges(),
              ),
              const SizedBox(height: 24),

              const Row(
                children: [
                  Icon(Icons.recycling, color: amberDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '4. Destinação da Cama de Frango',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Destinação da Cama de Frango:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Compostagem', style: TextStyle(fontSize: 11))),
                                selected: _corteCamaDestinacao == 'Compostagem',
                                selectedColor: forestGreen.withOpacity(0.15),
                                checkmarkColor: forestGreen,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: _corteCamaDestinacao == 'Compostagem' ? forestGreen : darkSlate,
                                  fontWeight: _corteCamaDestinacao == 'Compostagem' ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: widget.readOnly
                                    ? null
                                    : (selected) {
                                        if (selected) {
                                          setState(() => _corteCamaDestinacao = 'Compostagem');
                                          _notifyChanges();
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Alimentação Animal', style: TextStyle(fontSize: 11))),
                                selected: _corteCamaDestinacao == 'Alimentação animal',
                                selectedColor: forestGreen.withOpacity(0.15),
                                checkmarkColor: forestGreen,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: _corteCamaDestinacao == 'Alimentação animal' ? forestGreen : darkSlate,
                                  fontWeight: _corteCamaDestinacao == 'Alimentação animal' ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: widget.readOnly
                                    ? null
                                    : (selected) {
                                        if (selected) {
                                          setState(() => _corteCamaDestinacao = 'Alimentação animal');
                                          _notifyChanges();
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Adubos', style: TextStyle(fontSize: 11))),
                                selected: _corteCamaDestinacao == 'Adubos',
                                selectedColor: forestGreen.withOpacity(0.15),
                                checkmarkColor: forestGreen,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: _corteCamaDestinacao == 'Adubos' ? forestGreen : darkSlate,
                                  fontWeight: _corteCamaDestinacao == 'Adubos' ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: widget.readOnly
                                    ? null
                                    : (selected) {
                                        if (selected) {
                                          setState(() => _corteCamaDestinacao = 'Adubos');
                                          _notifyChanges();
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Outros', style: TextStyle(fontSize: 11))),
                                selected: _corteCamaDestinacao == 'Outros',
                                selectedColor: forestGreen.withOpacity(0.15),
                                checkmarkColor: forestGreen,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: _corteCamaDestinacao == 'Outros' ? forestGreen : darkSlate,
                                  fontWeight: _corteCamaDestinacao == 'Outros' ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: widget.readOnly
                                    ? null
                                    : (selected) {
                                        if (selected) {
                                          setState(() => _corteCamaDestinacao = 'Outros');
                                          _notifyChanges();
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_corteCamaDestinacao == 'Outros') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _corteCamaOutrosController,
                  enabled: !widget.readOnly,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Detalhar outro destino da cama',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (_) => _notifyChanges(),
                ),
              ],
            ] else ...[
              // ==========================================
              // MODELO: POSTURA
              // ==========================================
              const Row(
                children: [
                  Icon(Icons.widgets_outlined, color: amberDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '2. Avicultura de Postura',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sistema de Criação:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade100),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Soltas', style: TextStyle(fontSize: 11))),
                            selected: _posturaSistemaCriacao == 'Soltas',
                            selectedColor: forestGreen.withOpacity(0.15),
                            checkmarkColor: forestGreen,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: _posturaSistemaCriacao == 'Soltas' ? forestGreen : darkSlate,
                              fontWeight: _posturaSistemaCriacao == 'Soltas' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: widget.readOnly
                                ? null
                                : (selected) {
                                    if (selected) {
                                      setState(() => _posturaSistemaCriacao = 'Soltas');
                                      _notifyChanges();
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Confinadas', style: TextStyle(fontSize: 11))),
                            selected: _posturaSistemaCriacao == 'Confinadas',
                            selectedColor: forestGreen.withOpacity(0.15),
                            checkmarkColor: forestGreen,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: _posturaSistemaCriacao == 'Confinadas' ? forestGreen : darkSlate,
                              fontWeight: _posturaSistemaCriacao == 'Confinadas' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: widget.readOnly
                                ? null
                                : (selected) {
                                    if (selected) {
                                      setState(() => _posturaSistemaCriacao = 'Confinadas');
                                      _notifyChanges();
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de Confinamento:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade100),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Gaiolas', style: TextStyle(fontSize: 11))),
                            selected: _posturaTipoConfinamento == 'Gaiolas',
                            selectedColor: forestGreen.withOpacity(0.15),
                            checkmarkColor: forestGreen,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: _posturaTipoConfinamento == 'Gaiolas' ? forestGreen : darkSlate,
                              fontWeight: _posturaTipoConfinamento == 'Gaiolas' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: widget.readOnly
                                ? null
                                : (selected) {
                                    if (selected) {
                                      setState(() => _posturaTipoConfinamento = 'Gaiolas');
                                      _notifyChanges();
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Andares', style: TextStyle(fontSize: 11))),
                            selected: _posturaTipoConfinamento == 'Andares',
                            selectedColor: forestGreen.withOpacity(0.15),
                            checkmarkColor: forestGreen,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: _posturaTipoConfinamento == 'Andares' ? forestGreen : darkSlate,
                              fontWeight: _posturaTipoConfinamento == 'Andares' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: widget.readOnly
                                ? null
                                : (selected) {
                                    if (selected) {
                                      setState(() => _posturaTipoConfinamento = 'Andares');
                                      _notifyChanges();
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Outro Tipo', style: TextStyle(fontSize: 11))),
                            selected: _posturaTipoConfinamento == 'Outro tipo',
                            selectedColor: forestGreen.withOpacity(0.15),
                            checkmarkColor: forestGreen,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: _posturaTipoConfinamento == 'Outro tipo' ? forestGreen : darkSlate,
                              fontWeight: _posturaTipoConfinamento == 'Outro tipo' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: widget.readOnly
                                ? null
                                : (selected) {
                                    if (selected) {
                                      setState(() => _posturaTipoConfinamento = 'Outro tipo');
                                      _notifyChanges();
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _posturaInfoAdicionalController,
                enabled: !widget.readOnly,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Informações Adicionais (Postura)',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
              const SizedBox(height: 24),

              const Row(
                children: [
                  Icon(Icons.calculate_outlined, color: amberDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '3. Estimativa de Animais (Postura)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _posturaFileirasController,
                      enabled: !widget.readOnly,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculatePosturaQtd(),
                      decoration: const InputDecoration(
                        labelText: 'Nº Fileiras',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _posturaAndaresController,
                      enabled: !widget.readOnly,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculatePosturaQtd(),
                      decoration: const InputDecoration(
                        labelText: 'Nº Andares',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _posturaGaiolasModuloController,
                      enabled: !widget.readOnly,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculatePosturaQtd(),
                      decoration: const InputDecoration(
                        labelText: 'Gaiolas p/ Módulo',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _posturaAvesGaiolaController,
                      enabled: !widget.readOnly,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculatePosturaQtd(),
                      decoration: const InputDecoration(
                        labelText: 'Aves p/ Gaiola',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _posturaQtdEstimadaController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Quantidade Estimada de Aves (Automático)',
                  border: OutlineInputBorder(),
                  fillColor: Color(0xFFf1f5f9),
                  filled: true,
                  prefixIcon: Icon(Icons.egg),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ==========================================
            // AMBIENTAL / RESÍDUOS
            // ==========================================
            const Row(
              children: [
                Icon(Icons.eco_outlined, color: amberDark, size: 20),
                SizedBox(width: 8),
                Text(
                  '5. Resíduos & Meio Ambiente',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Geração de resíduos no local?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Sim / Não', style: TextStyle(fontSize: 11)),
              value: _aviculturaGeraResiduos,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _aviculturaGeraResiduos = val);
                      _notifyChanges();
                    },
            ),
            if (_aviculturaGeraResiduos) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _aviculturaResiduosDetalhesController,
                enabled: !widget.readOnly,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrever Tipo, Local e Quantidade',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ],

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Animais mortos incinerados?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Destinação de animais que vieram a óbito por causas eventuais', style: TextStyle(fontSize: 11)),
              value: _aviculturaMortosIncinerados,
              activeColor: forestGreen,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _aviculturaMortosIncinerados = val);
                      _notifyChanges();
                    },
            ),
            if (!_aviculturaMortosIncinerados) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _aviculturaMortosDestinacaoAltController,
                enabled: !widget.readOnly,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrever destinação alternativa dos animais mortos',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ],

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
            const SizedBox(height: 16),

            // ==========================================
            // FISCALIZAÇÃO / INFRAÇÃO
            // ==========================================
            const Row(
              children: [
                Icon(Icons.gavel_outlined, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  '6. Constatação de Infração',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Houve constatação de infração?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              value: _aviculturaInfracao,
              activeColor: Colors.red,
              onChanged: widget.readOnly
                  ? null
                  : (val) {
                      setState(() => _aviculturaInfracao = val);
                      _notifyChanges();
                    },
            ),
            if (_aviculturaInfracao) ...[
              const SizedBox(height: 8),
              const Text(
                'Sugestão de medidas a serem adotadas pela DIFI:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
              ),
              const SizedBox(height: 6),
              CheckboxListTile(
                title: const Text('Notificação', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                value: _aviculturaMedidaNotificacao,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _aviculturaMedidaNotificacao = val!);
                        _notifyChanges();
                      },
              ),
              CheckboxListTile(
                title: const Text('Embargo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                value: _aviculturaMedidaEmbargo,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _aviculturaMedidaEmbargo = val!);
                        _notifyChanges();
                      },
              ),
              CheckboxListTile(
                title: const Text('Auto de Infração', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                value: _aviculturaMedidaAuto,
                dense: true,
                activeColor: forestGreen,
                onChanged: widget.readOnly
                    ? null
                    : (val) {
                        setState(() => _aviculturaMedidaAuto = val!);
                        _notifyChanges();
                      },
              ),
            ],
            const SizedBox(height: 24),

            // ==========================================
            // PARECER / OBSERVAÇÕES
            // ==========================================
            const Row(
              children: [
                Icon(Icons.rate_review_outlined, color: forestGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  '7. Parecer Técnico / Informações Complementares',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            TextFormField(
              controller: _aviculturaObservacoesController,
              enabled: !widget.readOnly,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descrever observações técnicas, fatos relevantes ou justificativas (Obrigatório)',
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
