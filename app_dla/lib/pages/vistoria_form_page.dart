import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/database_helper.dart';
import '../services/vistoria_service.dart';

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

  final List<Map<String, dynamic>> _municipios = [
    {'id': '1', 'nome': 'João Pessoa'},
    {'id': '2', 'nome': 'Campina Grande'},
    {'id': '3', 'nome': 'Cabedelo'},
    {'id': '4', 'nome': 'Santa Rita'},
    {'id': '5', 'nome': 'Patos'},
    {'id': '6', 'nome': 'Sousa'},
    {'id': '7', 'nome': 'Cajazeiras'},
  ];

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
              decoration: const InputDecoration(
                labelText: 'Número do Processo',
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
            DropdownButtonFormField<String>(
              value: _selectedMunicipio,
              hint: const Text('Selecione o Município'),
              decoration: const InputDecoration(
                labelText: 'Município',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: _municipios.map((m) {
                return DropdownMenuItem<String>(
                  value: m['id'].toString(),
                  child: Text(m['nome']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedMunicipio = val),
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
    super.dispose();
  }
}
