import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/database_helper.dart';
import '../services/vistoria_service.dart';
import '../utils/municipios.dart';

class ProcessoInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 10) text = text.substring(0, 10);
    
    var newString = '';
    if (text.length > 4) {
      newString = '${text.substring(0, 4)}-${text.substring(4)}';
    } else {
      newString = text;
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class VistoriaFormPage extends StatefulWidget {
  final int userId;
  final String cpf;
  final Vistoria? existingVistoria; // If provided, we are editing a draft!

  const VistoriaFormPage({
    super.key,
    required this.userId,
    required this.cpf,
    this.existingVistoria,
  });

  @override
  State<VistoriaFormPage> createState() => _VistoriaFormPageState();
}

class _VistoriaFormPageState extends State<VistoriaFormPage> {
  final _vistoriaService = VistoriaService();
  final _formKey = GlobalKey<FormState>();

  // General controllers
  final _processoController = TextEditingController();
  final _requerenteController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  String _selectedTipo = 'Supressão Vegetal';
  String? _selectedMunicipio;

  // Supressão Controllers
  bool _supressaoCursoDagua = false;
  bool _supressaoAppPreservada = true;
  final _supressaoBiomaController = TextEditingController(text: 'Mata Atlântica');
  final _supressaoObsController = TextEditingController();

  // Avicultura Controllers
  String _aviculturaModelo = 'Convencional';
  String _aviculturaTipoCriacao = 'Corte';
  final _aviculturaQtdAnimaisController = TextEditingController();
  final _aviculturaQtdGalpoesController = TextEditingController();

  // Suinocultura Controllers
  final _suinoculturaQtdGalpoesController = TextEditingController();
  final _suinoculturaQtdAnimaisController = TextEditingController();
  String _suinoculturaFaseProducao = 'Terminação';

  // Bovinocultura Controllers
  String _bovinoculturaModelo = 'Extensivo';
  final _bovinoculturaAreaController = TextEditingController();
  final _bovinoculturaDessedentacaoController = TextEditingController();

  // Aquicultura Controllers
  final _aquiculturaQtdTanquesController = TextEditingController();
  bool _aquiculturaHidrometro = false;
  bool _aquiculturaOutorga = false;
  final _aquiculturaFonteAguaController = TextEditingController();

  // Sucroalcooleiro Controllers
  final _sucroalcooleiroResiduosController = TextEditingController();
  final _sucroalcooleiroBagacoController = TextEditingController();
  bool _sucroalcooleiroEquipamentosConformes = true;
  bool _sucroalcooleiroArmazenamentoOk = true;

  // Agricultura Controllers
  final _agriculturaCultivoController = TextEditingController();
  final _agriculturaCursosHidricosController = TextEditingController();
  final _agriculturaAgrotoxicosController = TextEditingController();

  bool _isGpsLoading = false;

  final List<String> _tipos = [
    'Supressão Vegetal',
    'Avicultura',
    'Suinocultura',
    'Bovinocultura',
    'Aquicultura',
    'Sucroalcooleiro',
    'Agricultura',
  ];

  final List<Map<String, dynamic>> _municipios = List<Map<String, dynamic>>.from(Municipios.list);

  @override
  void initState() {
    super.initState();
    if (widget.existingVistoria != null) {
      _loadExistingData(widget.existingVistoria!);
    }
  }

  void _loadExistingData(Vistoria v) {
    final d = v.data;
    _processoController.text = d['processo_n']?.toString() ?? '';
    _requerenteController.text = d['requerente']?.toString() ?? '';
    _latitudeController.text = d['latitude']?.toString() ?? '';
    _longitudeController.text = d['longitude']?.toString() ?? '';
    _selectedTipo = d['tipo']?.toString() ?? 'Supressão Vegetal';
    _selectedMunicipio = d['municipio']?.toString();

    if (_selectedTipo == 'Supressão Vegetal' || d.containsKey('supressao')) {
      final s = d['supressao'] ?? d;
      _supressaoCursoDagua = s['tem_curso_dagua'] == true;
      _supressaoAppPreservada = s['app_preservada'] == true;
      _supressaoBiomaController.text = s['bioma']?.toString() ?? 'Mata Atlântica';
      _supressaoObsController.text = s['observacoes']?.toString() ?? '';
    } else if (_selectedTipo == 'Avicultura' || d.containsKey('avicultura')) {
      final a = d['avicultura'] ?? d;
      _aviculturaModelo = a['modelo']?.toString() ?? 'Convencional';
      _aviculturaTipoCriacao = a['tipo_criacao']?.toString() ?? 'Corte';
      _aviculturaQtdAnimaisController.text = a['qtd_animais']?.toString() ?? '';
      _aviculturaQtdGalpoesController.text = a['qtd_galpoes']?.toString() ?? '';
    } else if (_selectedTipo == 'Suinocultura' || d.containsKey('suinocultura')) {
      final s = d['suinocultura'] ?? d;
      _suinoculturaQtdGalpoesController.text = s['qtd_galpoes']?.toString() ?? '';
      _suinoculturaQtdAnimaisController.text = s['qtd_animais']?.toString() ?? '';
      _suinoculturaFaseProducao = s['fase_producao']?.toString() ?? 'Terminação';
    } else if (_selectedTipo == 'Bovinocultura' || d.containsKey('bovinocultura')) {
      final b = d['bovinocultura'] ?? d;
      _bovinoculturaModelo = b['modelo']?.toString() ?? 'Extensivo';
      _bovinoculturaAreaController.text = b['area_ha']?.toString() ?? '';
      _bovinoculturaDessedentacaoController.text = b['dessedentacao']?.toString() ?? '';
    } else if (_selectedTipo == 'Aquicultura' || d.containsKey('aquicultura')) {
      final aq = d['aquicultura'] ?? d;
      _aquiculturaQtdTanquesController.text = aq['qtd_tanques']?.toString() ?? '';
      _aquiculturaHidrometro = aq['hidrometro'] == true;
      _aquiculturaOutorga = aq['outorga'] == true;
      _aquiculturaFonteAguaController.text = aq['fonte_agua']?.toString() ?? '';
    } else if (_selectedTipo == 'Sucroalcooleiro' || d.containsKey('sucroalcooleiro')) {
      final su = d['sucroalcooleiro'] ?? d;
      _sucroalcooleiroResiduosController.text = su['residuos_solidos']?.toString() ?? '';
      _sucroalcooleiroBagacoController.text = su['bagaco']?.toString() ?? '';
      _sucroalcooleiroEquipamentosConformes = su['equipamentos_conformes'] != false;
      _sucroalcooleiroArmazenamentoOk = su['armazenamento_ok'] != false;
    } else if (_selectedTipo == 'Agricultura' || d.containsKey('agricultura')) {
      final ag = d['agricultura'] ?? d;
      _agriculturaCultivoController.text = ag['cultivo']?.toString() ?? '';
      _agriculturaCursosHidricosController.text = ag['cursos_hidricos_entorno']?.toString() ?? '';
      _agriculturaAgrotoxicosController.text = ag['agrotoxicos']?.toString() ?? '';
    }
  }

  // Captura as coordenadas de forma realista simulada
  Future<void> _capturarGps() async {
    setState(() => _isGpsLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Coordenadas próximas à João Pessoa - PB
    setState(() {
      _latitudeController.text = (-7.1153 + (0.01 * (DateTime.now().second % 5))).toStringAsFixed(6);
      _longitudeController.text = (-34.8631 + (0.01 * (DateTime.now().second % 3))).toStringAsFixed(6);
      _isGpsLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS Capturado com sucesso! 📍'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Compila todo o dicionário de dados da vistoria
  Map<String, dynamic> _buildPayload(String status) {
    final Map<String, dynamic> payload = {
      'tipo': _selectedTipo,
      'processo_n': _processoController.text.trim().isEmpty ? null : _processoController.text.trim(),
      'requerente': _requerenteController.text.trim().isEmpty ? null : _requerenteController.text.trim(),
      'latitude': double.tryParse(_latitudeController.text),
      'longitude': double.tryParse(_longitudeController.text),
      'municipio': _selectedMunicipio != null ? int.tryParse(_selectedMunicipio!) : null,
      'status': status,
    };

    if (_selectedTipo == 'Supressão Vegetal') {
      payload['supressao'] = {
        'tem_curso_dagua': _supressaoCursoDagua,
        'app_preservada': _supressaoAppPreservada,
        'bioma': _supressaoBiomaController.text.trim(),
        'observacoes': _supressaoObsController.text.trim(),
      };
    } else if (_selectedTipo == 'Avicultura') {
      payload['avicultura'] = {
        'modelo': _aviculturaModelo,
        'tipo_criacao': _aviculturaTipoCriacao,
        'qtd_animais': int.tryParse(_aviculturaQtdAnimaisController.text),
        'qtd_galpoes': int.tryParse(_aviculturaQtdGalpoesController.text),
      };
    } else if (_selectedTipo == 'Suinocultura') {
      payload['suinocultura'] = {
        'qtd_galpoes': int.tryParse(_suinoculturaQtdGalpoesController.text),
        'qtd_animais': int.tryParse(_suinoculturaQtdAnimaisController.text),
        'fase_producao': _suinoculturaFaseProducao,
      };
    } else if (_selectedTipo == 'Bovinocultura') {
      payload['bovinocultura'] = {
        'modelo': _bovinoculturaModelo,
        'area_ha': double.tryParse(_bovinoculturaAreaController.text),
        'dessedentacao': _bovinoculturaDessedentacaoController.text.trim(),
      };
    } else if (_selectedTipo == 'Aquicultura') {
      payload['aquicultura'] = {
        'qtd_tanques': int.tryParse(_aquiculturaQtdTanquesController.text),
        'hidrometro': _aquiculturaHidrometro,
        'outorga': _aquiculturaOutorga,
        'fonte_agua': _aquiculturaFonteAguaController.text.trim(),
      };
    } else if (_selectedTipo == 'Sucroalcooleiro') {
      payload['sucroalcooleiro'] = {
        'residuos_solidos': _sucroalcooleiroResiduosController.text.trim(),
        'bagaco': _sucroalcooleiroBagacoController.text.trim(),
        'equipamentos_conformes': _sucroalcooleiroEquipamentosConformes,
        'armazenamento_ok': _sucroalcooleiroArmazenamentoOk,
      };
    } else if (_selectedTipo == 'Agricultura') {
      payload['agricultura'] = {
        'cultivo': _agriculturaCultivoController.text.trim(),
        'cursos_hidricos_entorno': _agriculturaCursosHidricosController.text.trim(),
        'agrotoxicos': _agriculturaAgrotoxicosController.text.trim(),
      };
    }

    return payload;
  }

  // Validador local de consistência
  bool _validateFormForSubmission() {
    if (_processoController.text.trim().isEmpty) {
      _showWarning('Número do Processo é obrigatório para envio.');
      return false;
    }
    if (_requerenteController.text.trim().isEmpty) {
      _showWarning('Nome do Requerente é obrigatório para envio.');
      return false;
    }
    if (_selectedMunicipio == null) {
      _showWarning('Município é obrigatório para envio.');
      return false;
    }
    if (double.tryParse(_latitudeController.text) == null || double.tryParse(_longitudeController.text) == null) {
      _showWarning('Coordenadas de GPS válidas são obrigatórias para envio.');
      return false;
    }

    if (_selectedTipo == 'Supressão Vegetal') {
      if (_supressaoBiomaController.text.trim().isEmpty) {
        _showWarning('Bioma é obrigatório.');
        return false;
      }
      if (_supressaoObsController.text.trim().isEmpty) {
        _showWarning('Parecer técnico/Observações são obrigatórios.');
        return false;
      }
    } else if (_selectedTipo == 'Avicultura') {
      if (int.tryParse(_aviculturaQtdAnimaisController.text) == null || int.tryParse(_aviculturaQtdAnimaisController.text)! <= 0) {
        _showWarning('Quantidade de aves deve ser maior que zero.');
        return false;
      }
      if (int.tryParse(_aviculturaQtdGalpoesController.text) == null || int.tryParse(_aviculturaQtdGalpoesController.text)! <= 0) {
        _showWarning('Quantidade de galpões deve ser maior que zero.');
        return false;
      }
    } else if (_selectedTipo == 'Suinocultura') {
      if (int.tryParse(_suinoculturaQtdAnimaisController.text) == null || int.tryParse(_suinoculturaQtdAnimaisController.text)! <= 0) {
        _showWarning('Quantidade de suínos deve ser maior que zero.');
        return false;
      }
      if (int.tryParse(_suinoculturaQtdGalpoesController.text) == null || int.tryParse(_suinoculturaQtdGalpoesController.text)! <= 0) {
        _showWarning('Quantidade de galpões deve ser maior que zero.');
        return false;
      }
    } else if (_selectedTipo == 'Bovinocultura') {
      if (double.tryParse(_bovinoculturaAreaController.text) == null || double.tryParse(_bovinoculturaAreaController.text)! <= 0) {
        _showWarning('Área em hectares deve ser maior que zero.');
        return false;
      }
    } else if (_selectedTipo == 'Aquicultura') {
      if (int.tryParse(_aquiculturaQtdTanquesController.text) == null || int.tryParse(_aquiculturaQtdTanquesController.text)! <= 0) {
        _showWarning('Quantidade de tanques deve ser maior que zero.');
        return false;
      }
    } else if (_selectedTipo == 'Agricultura') {
      if (_agriculturaCultivoController.text.trim().isEmpty) {
        _showWarning('O campo "Tipo de Cultivo" é obrigatório.');
        return false;
      }
    }

    return true;
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Salva no SQLite como Rascunho livre
  Future<void> _salvarRascunho() async {
    final payload = _buildPayload('rascunho');
    
    final db = await DatabaseHelper.instance.database;
    if (widget.existingVistoria != null) {
      // Atualiza existente
      await db.update(
        'vistorias_local',
        {
          'data': jsonEncode(payload),
          'synced': 0,
        },
        where: 'id = ?',
        whereArgs: [widget.existingVistoria!.id],
      );
    } else {
      // Cria nova
      await _vistoriaService.createVistoria(payload, widget.userId, widget.cpf);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rascunho salvo no celular! 📲'), backgroundColor: Colors.grey),
      );
      Navigator.pop(context, true);
    }
  }

  // Salva no SQLite com status "sincronizada" pronta para envio
  Future<void> _finalizarVistoria() async {
    if (!_validateFormForSubmission()) return;

    final payload = _buildPayload('sincronizada');
    
    final db = await DatabaseHelper.instance.database;
    if (widget.existingVistoria != null) {
      // Atualiza rascunho existente para sincronizada
      await db.update(
        'vistorias_local',
        {
          'data': jsonEncode(payload),
          'synced': 0, // Reinicia status de envio
        },
        where: 'id = ?',
        whereArgs: [widget.existingVistoria!.id],
      );
      // Tenta sincronizar imediatamente se houver internet
      _vistoriaService.syncVistorias(widget.cpf);
    } else {
      // Cria nova vistoria já finalizada
      await _vistoriaService.createVistoria(payload, widget.userId, widget.cpf);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vistoria finalizada! Sincronizando com SUDEMA... 🚀'),
          backgroundColor: Color(0xFF006b33),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF006b33);
    const darkBlue = Color(0xFF0d1b3e);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingVistoria != null ? 'Editar Rascunho' : 'Nova Vistoria'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SEÇÃO 1: Dados Gerais
            _buildSectionHeader('1. Identificação Geral'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _processoController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                ProcessoInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Número do Processo',
                hintText: '0000-000000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder_open),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _requerenteController,
              decoration: const InputDecoration(
                labelText: 'Nome do Requerente',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            FormField<String>(
              initialValue: _selectedMunicipio,
              validator: (value) {
                if (_selectedMunicipio == null) {
                  return 'Por favor, selecione um município';
                }
                return null;
              },
              builder: (state) {
                return InkWell(
                  onTap: () => _showMunicipioSelector(state),
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Município',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_city),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      errorText: state.errorText,
                    ),
                    child: Text(
                      _selectedMunicipio == null
                          ? 'Selecione o Município'
                          : List<Map<String, dynamic>>.from(_municipios).firstWhere(
                              (m) => m['id'].toString() == _selectedMunicipio,
                              orElse: () => <String, String>{'nome': 'Selecione o Município'},
                            )['nome']?.toString() ?? '',
                      style: TextStyle(
                        color: _selectedMunicipio == null ? Colors.grey[600] : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Coordenadas
            _buildSectionHeader('2. Coordenadas de Campo (GPS)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isGpsLoading ? null : _capturarGps,
                icon: _isGpsLoading 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.gps_fixed),
                label: Text(_isGpsLoading ? 'Buscando Satélite...' : 'Capturar Coordenadas GPS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SEÇÃO 2: Modalidade
            _buildSectionHeader('3. Atividade / Licenciamento'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Atividade',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _tipos.map((t) {
                return DropdownMenuItem<String>(value: t, child: Text(t));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTipo = val);
              },
            ),
            const SizedBox(height: 20),

            // SEÇÃO 3: Campos Dinâmicos
            _buildSectionHeader('4. Formulário Específico'),
            const SizedBox(height: 12),
            _buildDynamicFields(),
            const SizedBox(height: 32),

            // Botões de Ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _salvarRascunho,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: Colors.grey.shade800,
                    ),
                    child: const Text('Salvar Rascunho', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _finalizarVistoria,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Finalizar e Enviar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0d1b3e)),
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (_selectedTipo == 'Supressão Vegetal') {
      return Card(
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SwitchListTile(
              title: const Text('Há curso d\'água na área da vistoria?', style: TextStyle(fontSize: 14)),
              value: _supressaoCursoDagua,
              activeColor: const Color(0xFF006b33),
              onChanged: (val) => setState(() => _supressaoCursoDagua = val),
            ),
            SwitchListTile(
              title: const Text('A Área de Preservação Permanente (APP) está preservada?', style: TextStyle(fontSize: 14)),
              value: _supressaoAppPreservada,
              activeColor: const Color(0xFF006b33),
              onChanged: (val) => setState(() => _supressaoAppPreservada = val),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _supressaoBiomaController,
              decoration: const InputDecoration(
                labelText: 'Bioma Predominante',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _supressaoObsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Parecer Técnico / Observações',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
    } else if (_selectedTipo == 'Avicultura') {
      return Card(
        color: Colors.amber.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            DropdownButtonFormField<String>(
              value: _aviculturaModelo,
              decoration: const InputDecoration(labelText: 'Modelo do Galpão', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              items: ['Convencional', 'Climatizado', 'Dark House']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) => setState(() => _aviculturaModelo = val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _aviculturaTipoCriacao,
              decoration: const InputDecoration(labelText: 'Tipo de Criação', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              items: ['Corte', 'Postura', 'Recria']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => _aviculturaTipoCriacao = val!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _aviculturaQtdAnimaisController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade de Aves (Aproximada)', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _aviculturaQtdGalpoesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade de Galpões', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
            ),
          ],
        ),
      ),
    );
    } else if (_selectedTipo == 'Suinocultura') {
      return Card(
        color: Colors.pink.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            TextFormField(
              controller: _suinoculturaQtdGalpoesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade de Galpões', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _suinoculturaQtdAnimaisController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade de Animais (Suínos)', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _suinoculturaFaseProducao,
              decoration: const InputDecoration(labelText: 'Fase de Produção', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              items: ['Gestação', 'Maternidade', 'Creche', 'Terminação', 'Ciclo Completo']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) => setState(() => _suinoculturaFaseProducao = val!),
            ),
          ],
        ),
      ),
    );
    } else if (_selectedTipo == 'Bovinocultura') {
      return Card(
        color: Colors.brown.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _bovinoculturaModelo,
                decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                items: ['Extensivo', 'Intensivo']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => setState(() => _bovinoculturaModelo = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bovinoculturaAreaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Área (Hectares)', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bovinoculturaDessedentacaoController,
                decoration: const InputDecoration(labelText: 'Forma de Dessedentação', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
            ],
          ),
        ),
      );
    } else if (_selectedTipo == 'Aquicultura') {
      return Card(
        color: Colors.cyan.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _aquiculturaQtdTanquesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade de Tanques', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Possui Hidrômetro?', style: TextStyle(fontSize: 14)),
                value: _aquiculturaHidrometro,
                activeColor: const Color(0xFF006b33),
                onChanged: (val) => setState(() => _aquiculturaHidrometro = val),
              ),
              SwitchListTile(
                title: const Text('Possui Outorga?', style: TextStyle(fontSize: 14)),
                value: _aquiculturaOutorga,
                activeColor: const Color(0xFF006b33),
                onChanged: (val) => setState(() => _aquiculturaOutorga = val),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _aquiculturaFonteAguaController,
                decoration: const InputDecoration(labelText: 'Fonte de Captação de Água', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
            ],
          ),
        ),
      );
    } else if (_selectedTipo == 'Sucroalcooleiro') {
      return Card(
        color: Colors.purple.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _sucroalcooleiroResiduosController,
                decoration: const InputDecoration(labelText: 'Destinação de Resíduos Sólidos', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sucroalcooleiroBagacoController,
                decoration: const InputDecoration(labelText: 'Destinação do Bagaço', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Equipamentos estão conformes?', style: TextStyle(fontSize: 14)),
                value: _sucroalcooleiroEquipamentosConformes,
                activeColor: const Color(0xFF006b33),
                onChanged: (val) => setState(() => _sucroalcooleiroEquipamentosConformes = val),
              ),
              SwitchListTile(
                title: const Text('Armazenamento está OK?', style: TextStyle(fontSize: 14)),
                value: _sucroalcooleiroArmazenamentoOk,
                activeColor: const Color(0xFF006b33),
                onChanged: (val) => setState(() => _sucroalcooleiroArmazenamentoOk = val),
              ),
            ],
          ),
        ),
      );
    } else if (_selectedTipo == 'Agricultura') {
      return Card(
        color: Colors.lightGreen.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _agriculturaCultivoController,
                decoration: const InputDecoration(labelText: 'Tipo de Cultivo (Ex: Milho, Soja)', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _agriculturaCursosHidricosController,
                decoration: const InputDecoration(labelText: 'Cursos Hídricos no Entorno', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _agriculturaAgrotoxicosController,
                decoration: const InputDecoration(labelText: 'Uso de Agrotóxicos (Detalhar)', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
            ],
          ),
        ),
      );
    } else {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text(
        'Esta modalidade utiliza os campos padrão de identificação, geolocalização e fotos da vistoria de licenciamento da SUDEMA.',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      ),
    );
  }
  }

  @override
  void dispose() {
    _processoController.dispose();
    _requerenteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _supressaoBiomaController.dispose();
    _supressaoObsController.dispose();
    _aviculturaQtdAnimaisController.dispose();
    _aviculturaQtdGalpoesController.dispose();
    _suinoculturaQtdGalpoesController.dispose();
    _suinoculturaQtdAnimaisController.dispose();
    _bovinoculturaAreaController.dispose();
    _bovinoculturaDessedentacaoController.dispose();
    _aquiculturaQtdTanquesController.dispose();
    _aquiculturaFonteAguaController.dispose();
    _sucroalcooleiroResiduosController.dispose();
    _sucroalcooleiroBagacoController.dispose();
    _agriculturaCultivoController.dispose();
    _agriculturaCursosHidricosController.dispose();
    _agriculturaAgrotoxicosController.dispose();
    super.dispose();
  }

  void _showMunicipioSelector(FormFieldState<String> state) {
    String searchLocal = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _municipios.where((m) {
              final nome = (m['nome'] ?? '').toString().toLowerCase();
              return nome.contains(searchLocal.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selecione o Município',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      autofocus: true,
                      onChanged: (val) {
                        setModalState(() {
                          searchLocal = val;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Pesquisar município...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum município encontrado.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final m = filtered[index];
                                final isSelected = m['id'].toString() == _selectedMunicipio;
                                return ListTile(
                                  title: Text(
                                    m['nome']?.toString() ?? '',
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedMunicipio = m['id'].toString();
                                    });
                                    state.didChange(m['id'].toString());
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
