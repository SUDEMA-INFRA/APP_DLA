import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/database_helper.dart';
import '../services/vistoria_service.dart';
import '../utils/municipios.dart';
import 'forms/supressao_form.dart';
import 'forms/avicultura_form.dart';
import 'forms/suinocultura_form.dart';
import 'forms/bovinocultura_form.dart';
import 'forms/aquicultura_form.dart';
import 'forms/atividades_agroindustriais_form.dart';
import 'forms/agricultura_form.dart';

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
  bool _supressaoIndiciosUsoApp = false;
  bool _supressaoRlIsolada = false;
  bool _supressaoRlNativaCompativel = false;
  String _supressaoBioma = 'MA'; // 'MA' or 'CAATINGA'
  
  // Bloco A - Mata Atlântica
  String _blocoAEstagioSucessional = 'Inicial';
  String _blocoADapOption = 'Até 8 cm';
  String _blocoAAlturaOption = 'Até 5 m';
  String _blocoASerapilheiraOption = 'Inexistente ou rala';
  String _blocoAEpifitasOption = 'Ausentes';
  String _blocoASubbosqueOption = 'Ausente';
  final _blocoAInfoAdicionaisController = TextEditingController();
  
  // Bloco B - Caatinga
  String _blocoBEstruturaOption = 'Herbáceo-Arbustiva (Fase inicial / Rala)';
  final _blocoBInfoAdicionaisController = TextEditingController();
  
  // Outros campos de Supressão
  bool _presencaInvasoras = false;
  bool _presencaExoticas = false;
  final _especiesInvasorasController = TextEditingController();
  String _grauInfestacaoOption = 'Baixo — Indivíduos isolados';
  bool _locApp = false;
  bool _locRl = false;
  bool _locUas = false;
  bool _pastosAbandonados = false;
  bool _supressaoSolo = false;
  bool _fogoApp = false;
  bool _fogoRl = false;
  bool _fogoUas = false;
  bool _fogoOutras = false;
  bool _fotoGeoOk = false;
  bool _infracao = false;
  final _infracaoDescController = TextEditingController();
  bool _medidaNotificacao = false;
  bool _medidaEmbargo = false;
  bool _medidaAuto = false;
  final _fatosRelevantesController = TextEditingController();
  final _complementacaoNecessariaController = TextEditingController();
  final _supressaoObsController = TextEditingController(); // Parecer Técnico

  // Avicultura Controllers
  String _aviculturaModelo = 'CORTE'; // CORTE or POSTURA
  
  // Corte Specific
  String _corteSistemaCriacao = 'Intensivo (Confinado)';
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
  final _corteInfoAdicionalController = TextEditingController();
  final _corteComprimentoController = TextEditingController();
  final _corteLarguraController = TextEditingController();
  final _corteAreaController = TextEditingController();
  String _corteDensidade = 'Convencional (12 a 15 aves/m²)';
  final _corteQtdEstimadaController = TextEditingController();
  String _corteCamaDestinacao = 'Compostagem';
  final _corteCamaOutrosController = TextEditingController();
  
  // Postura Specific
  String _posturaSistemaCriacao = 'Soltas'; // Soltas or Confinadas
  String _posturaTipoConfinamento = 'Gaiolas'; // Gaiolas or Andares or Outro tipo
  final _posturaInfoAdicionalController = TextEditingController();
  final _posturaFileirasController = TextEditingController();
  final _posturaAndaresController = TextEditingController();
  final _posturaGaiolasModuloController = TextEditingController();
  final _posturaAvesGaiolaController = TextEditingController();
  final _posturaQtdEstimadaController = TextEditingController();
  
  // Shared
  bool _aviculturaGeraResiduos = false;
  final _aviculturaResiduosDetalhesController = TextEditingController();
  bool _aviculturaMortosIncinerados = true;
  final _aviculturaMortosDestinacaoAltController = TextEditingController();
  bool _aviculturaFotoGeoOk = false;
  bool _aviculturaInfracao = false;
  bool _aviculturaMedidaNotificacao = false;
  bool _aviculturaMedidaEmbargo = false;
  bool _aviculturaMedidaAuto = false;
  final _aviculturaObservacoesController = TextEditingController();



  // Suinocultura Controllers
  String _suinoculturaModelo = 'CAIPIRA';
  final _suinoculturaQtdGalpoesController = TextEditingController();
  final _suinoculturaQtdMedioPorGalpaoController = TextEditingController();

  bool _suinoculturaFaseTerminacao = false;
  final _suinoculturaFaseTerminacaoQtdController = TextEditingController();
  bool _suinoculturaFaseMatrizes = false;
  final _suinoculturaFaseMatrizesQtdController = TextEditingController();
  bool _suinoculturaFaseReprodutores = false;
  final _suinoculturaFaseReprodutoresQtdController = TextEditingController();
  bool _suinoculturaFaseAdulto = false;
  final _suinoculturaFaseAdultoQtdController = TextEditingController();

  bool _suinoculturaAcumuloResiduos = false;
  bool _suinoculturaVazamentoDejetos = false;
  bool _suinoculturaOdorExtremo = false;
  bool _suinoculturaDejetosTransbordando = false;
  bool _suinoculturaImpermeabilizacaoContencao = false;
  bool _suinoculturaDestinacaoAdequada = true;

  bool _suinoculturaIndiciosPorteMaior = false;
  final _suinoculturaIndiciosPorteMaiorDetalheController = TextEditingController();

  bool _suinoculturaMortosIncinerados = true;
  final _suinoculturaMortosDestinoController = TextEditingController();

  bool _suinoculturaFotoGeoOk = false;
  bool _suinoculturaInfracaoConstatada = false;
  bool _suinoculturaMedidaNotificacao = false;
  bool _suinoculturaMedidaEmbargo = false;
  bool _suinoculturaMedidaAuto = false;
  final _suinoculturaObservacoesController = TextEditingController();

  // Bovinocultura Controllers
  String _bovinoculturaModelo = 'EXTENSIVO';
  final _bovinoculturaAreaController = TextEditingController();
  final _bovinoculturaDessedentacaoController = TextEditingController();
  final _bovinoculturaQtdCochosController = TextEditingController();
  final _bovinoculturaTamanhoCochosController = TextEditingController();
  final _bovinoculturaQtdAnimaisController = TextEditingController();
  bool _bovinoculturaFotoGeoOk = false;
  bool _bovinoculturaInfracaoConstatada = false;
  bool _bovinoculturaMedidaNotificacao = false;
  bool _bovinoculturaMedidaEmbargo = false;
  bool _bovinoculturaMedidaAuto = false;
  final _bovinoculturaObservacoesController = TextEditingController();

  // Aquicultura Controllers
  final _aquiculturaQtdTanquesController = TextEditingController();
  final _aquiculturaAreaTanquesController = TextEditingController();
  
  bool _aquiculturaPossuiAeradores = false;
  final _aquiculturaQtdAeradoresController = TextEditingController();

  // Identified equipment
  bool _aquiculturaBombaIdentificada = false;
  final _aquiculturaBombaSituacaoController = TextEditingController();

  bool _aquiculturaTubulacaoIdentificada = false;
  final _aquiculturaTubulacaoSituacaoController = TextEditingController();

  bool _aquiculturaCaptacaoIdentificada = false;
  final _aquiculturaCaptacaoSituacaoController = TextEditingController();

  bool _aquiculturaHidrometro = false;
  final _aquiculturaHidrometroSituacaoController = TextEditingController();

  bool _aquiculturaOutrosItensIdentificados = false;
  final _aquiculturaOutrosItensSituacaoController = TextEditingController();

  // Outorga
  bool _aquiculturaOutorga = false;
  final _aquiculturaOutorgaIdentificacaoController = TextEditingController();

  // Descarte
  String _aquiculturaDescarteResiduos = 'COMPOSTEIRA';
  final _aquiculturaDescarteResiduosOutroController = TextEditingController();

  final _aquiculturaFonteAguaController = TextEditingController();

  // Ritos and DIFI
  bool _aquiculturaFotoGeoOk = false;
  bool _aquiculturaInfracaoConstatada = false;
  bool _aquiculturaMedidaNotificacao = false;
  bool _aquiculturaMedidaEmbargo = false;
  bool _aquiculturaMedidaAuto = false;
  final _aquiculturaObservacoesController = TextEditingController();

  // Atividades Agroindustriais Controllers
  final _atividadesAgroindustriaisResiduosController = TextEditingController();
  final _atividadesAgroindustriaisBagacoController = TextEditingController();
  bool _atividadesAgroindustriaisEquipamentosConformes = true;
  bool _atividadesAgroindustriaisArmazenamentoOk = true;

  // Agricultura Controllers
  final _agriculturaCultivoController = TextEditingController();
  final _agriculturaCursosHidricosController = TextEditingController();
  final _agriculturaAgrotoxicosController = TextEditingController();

  Map<String, dynamic> _atividadesAgroindustriaisData = {};
  Map<String, dynamic> _agriculturaData = {};

  bool _isGpsLoading = false;

  final List<String> _tipos = [
    'Supressão Vegetal',
    'Avicultura',
    'Suinocultura',
    'Bovinocultura',
    'Aquicultura',
    'Atividades Agroindustriais',
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
      _supressaoIndiciosUsoApp = s['indicios_uso_app'] == true;
      _supressaoRlIsolada = s['rl_isolada'] == true;
      _supressaoRlNativaCompativel = s['rl_nativa_compativel'] == true;
      
      final rawBioma = s['bioma']?.toString() ?? 'MA';
      _supressaoBioma = (rawBioma == 'Mata Atlântica' || rawBioma == 'MA') ? 'MA' : 'CAATINGA';
      
      // Bloco A - Mata Atlântica
       _blocoAEstagioSucessional = s['bloco_a_estagio_sucessional']?.toString() ?? 'Inicial';
       _updateBlocoAParameters(_blocoAEstagioSucessional);
       _blocoAInfoAdicionaisController.text = s['bloco_a_observacoes']?.toString() ?? '';
      
      // Bloco B - Caatinga
      _blocoBEstruturaOption = s['bloco_b_estrutura']?.toString() ?? 'Herbáceo-Arbustiva (Fase inicial / Rala)';
      _blocoBInfoAdicionaisController.text = s['bloco_b_observacoes']?.toString() ?? '';
      
      // Outros campos
      _presencaInvasoras = s['presenca_invasoras'] == true;
      _presencaExoticas = s['presenca_exoticas'] == true;
      _especiesInvasorasController.text = s['especies']?.toString() ?? '';
      _grauInfestacaoOption = s['grau_infestacao']?.toString() ?? 'Baixo — Indivíduos isolados';
      _locApp = s['loc_app']?.toString() == 'Sim';
      _locRl = s['loc_rl']?.toString() == 'Sim';
      _locUas = s['loc_uas']?.toString() == 'Sim';
      _pastosAbandonados = s['pastos_abandonados'] == true;
      _supressaoSolo = s['supressao_solo'] == true;
      _fogoApp = s['fogo_app'] == true;
      _fogoRl = s['fogo_rl'] == true;
      _fogoUas = s['fogo_uas'] == true;
      _fogoOutras = s['fogo_outras'] == true;
      _fotoGeoOk = s['foto_geo_ok'] == true;
      
      final rawInfracao = s['infracao']?.toString() ?? 'Não';
      if (rawInfracao.startsWith('Sim')) {
        _infracao = true;
        _infracaoDescController.text = rawInfracao.replaceFirst('Sim: ', '').trim();
      } else {
        _infracao = false;
        _infracaoDescController.text = '';
      }
      
      final rawMedidas = s['medida_sugerida']?.toString() ?? '';
      _medidaNotificacao = rawMedidas.contains('Notificação');
      _medidaEmbargo = rawMedidas.contains('Embargo');
      _medidaAuto = rawMedidas.contains('Auto de Infração');
      
      _supressaoObsController.text = s['observacoes']?.toString() ?? '';
      _fatosRelevantesController.text = s['fatos_relevantes']?.toString() ?? '';
      _complementacaoNecessariaController.text = s['complementacao_necessaria']?.toString() ?? '';
    } else if (_selectedTipo == 'Avicultura' || d.containsKey('avicultura')) {
      final a = d['avicultura'] ?? d;
      _aviculturaModelo = a['modelo']?.toString() ?? 'CORTE';
      
      // Corte fields
      final rawCorteSistema = a['corte_sistema_criacao']?.toString();
      if (rawCorteSistema == 'Soltas') {
        _corteSistemaCriacao = 'Extensivo / Caipira';
      } else if (rawCorteSistema == 'Confinadas') {
        _corteSistemaCriacao = 'Intensivo (Confinado)';
      } else {
        _corteSistemaCriacao = rawCorteSistema ?? 'Intensivo (Confinado)';
      }
      _corteAvesSoltasChao = a['corte_aves_soltas_chao'] == true;
      _corteCamaCascaArroz = a['corte_cama_casca_arroz'] == true;
      _corteGalpoesLongos = a['corte_galpoes_longos'] == true;
      _corteGalpoesCurtos = a['corte_galpoes_curtos'] == true;
      _corteBebedourosChao = a['corte_bebedouros_chao'] == true;
      _corteBebedourosSuspensos = a['corte_bebedouros_suspensos'] == true;
      _corteComedourosChao = a['corte_comedouros_chao'] == true;
      _corteComedourosSuspensos = a['corte_comedouros_suspensos'] == true;
      _cortePintos = a['corte_pintos'] == true;
      _corteFrangos = a['corte_frangos'] == true;
      _corteVentiladores = a['corte_ventiladores'] == true;
      _corteVentiladoresFunc = a['corte_ventiladores_func'] == true;
      _corteSemVentiladores = a['corte_sem_ventiladores'] == true;
      _corteInfoAdicionalController.text = a['corte_info_adicional']?.toString() ?? '';
      _corteComprimentoController.text = a['corte_comprimento']?.toString() ?? '';
      _corteLarguraController.text = a['corte_largura']?.toString() ?? '';
      _corteAreaController.text = a['corte_area']?.toString() ?? '';
      _corteDensidade = a['corte_densidade']?.toString() ?? 'Convencional (12 a 15 aves/m²)';
      _corteQtdEstimadaController.text = a['corte_qtd_estimada']?.toString() ?? '';
      _corteCamaDestinacao = a['corte_cama_destinacao']?.toString() ?? 'Compostagem';
      _corteCamaOutrosController.text = a['corte_cama_outros']?.toString() ?? '';
      
      // Postura fields
      _posturaSistemaCriacao = a['postura_sistema_criacao']?.toString() ?? 'Soltas';
      _posturaTipoConfinamento = a['postura_tipo_confinamento']?.toString() ?? 'Gaiolas';
      _posturaInfoAdicionalController.text = a['postura_info_adicional']?.toString() ?? '';
      _posturaFileirasController.text = a['postura_fileiras']?.toString() ?? '';
      _posturaAndaresController.text = a['postura_andares']?.toString() ?? '';
      _posturaGaiolasModuloController.text = a['postura_gaiolas_modulo']?.toString() ?? '';
      _posturaAvesGaiolaController.text = a['postura_aves_gaiola']?.toString() ?? '';
      _posturaQtdEstimadaController.text = a['postura_qtd_estimada']?.toString() ?? '';
      
      // Shared fields
      _aviculturaGeraResiduos = a['gera_residuos'] == true;
      _aviculturaResiduosDetalhesController.text = a['residuos_detalhes']?.toString() ?? '';
      _aviculturaMortosIncinerados = a['mortos_incinerados'] != false;
      _aviculturaMortosDestinacaoAltController.text = a['mortos_destinacao_alt']?.toString() ?? '';
      _aviculturaFotoGeoOk = a['foto_geo_ok'] == true;
      _aviculturaInfracao = a['infracao_constatada'] == true;
      
      final rawMedidas = a['medida_sugerida']?.toString() ?? '';
      _aviculturaMedidaNotificacao = rawMedidas.contains('Notificação');
      _aviculturaMedidaEmbargo = rawMedidas.contains('Embargo');
      _aviculturaMedidaAuto = rawMedidas.contains('Auto de Infração');
      
      _aviculturaObservacoesController.text = a['observacoes']?.toString() ?? '';
    } else if (_selectedTipo == 'Suinocultura' || d.containsKey('suinocultura')) {
      final s = d['suinocultura'] ?? d;
      _suinoculturaModelo = s['modelo']?.toString() ?? 'CAIPIRA';
      _suinoculturaQtdGalpoesController.text = s['qtd_galpoes']?.toString() ?? '';
      _suinoculturaQtdMedioPorGalpaoController.text = s['qtd_medio_por_galpao']?.toString() ?? '';
      
      _suinoculturaFaseTerminacao = s['fase_terminacao'] == true;
      _suinoculturaFaseTerminacaoQtdController.text = s['fase_terminacao_qtd']?.toString() ?? '';
      _suinoculturaFaseMatrizes = s['fase_matrizes'] == true;
      _suinoculturaFaseMatrizesQtdController.text = s['fase_matrizes_qtd']?.toString() ?? '';
      _suinoculturaFaseReprodutores = s['fase_reprodutores'] == true;
      _suinoculturaFaseReprodutoresQtdController.text = s['fase_reprodutores_qtd']?.toString() ?? '';
      _suinoculturaFaseAdulto = s['fase_adulto'] == true;
      _suinoculturaFaseAdultoQtdController.text = s['fase_adulto_qtd']?.toString() ?? '';
      
      _suinoculturaAcumuloResiduos = s['acumulo_residuos'] == true;
      _suinoculturaVazamentoDejetos = s['vazamento_dejetos'] == true;
      _suinoculturaOdorExtremo = s['odor_extremo'] == true;
      _suinoculturaDejetosTransbordando = s['dejetos_transbordando'] == true;
      _suinoculturaImpermeabilizacaoContencao = s['impermeabilizacao_contencao'] == true;
      _suinoculturaDestinacaoAdequada = s['destinacao_adequada'] != false;
      
      _suinoculturaIndiciosPorteMaior = s['indicios_porte_maior'] == true;
      _suinoculturaIndiciosPorteMaiorDetalheController.text = s['indicios_porte_maior_detalhe']?.toString() ?? '';
      
      _suinoculturaMortosIncinerados = s['mortos_incinerados'] != false;
      _suinoculturaMortosDestinoController.text = s['mortos_destino']?.toString() ?? '';
      
      _suinoculturaFotoGeoOk = s['foto_geo_ok'] == true;
      _suinoculturaInfracaoConstatada = s['infracao_constatada'] == true;
      
      final sugeridas = s['medida_sugerida']?.toString() ?? '';
      _suinoculturaMedidaNotificacao = sugeridas.contains('Notificação');
      _suinoculturaMedidaEmbargo = sugeridas.contains('Embargo');
      _suinoculturaMedidaAuto = sugeridas.contains('Auto de Infração');
      
      _suinoculturaObservacoesController.text = s['observacoes']?.toString() ?? '';
    } else if (_selectedTipo == 'Bovinocultura' || d.containsKey('bovinocultura')) {
      final b = d['bovinocultura'] ?? d;
      _bovinoculturaModelo = b['modelo']?.toString()?.toUpperCase() ?? 'EXTENSIVO';
      if (_bovinoculturaModelo != 'EXTENSIVO' && _bovinoculturaModelo != 'INTENSIVO') {
        _bovinoculturaModelo = 'EXTENSIVO';
      }
      _bovinoculturaAreaController.text = b['area_ha']?.toString() ?? '';
      _bovinoculturaDessedentacaoController.text = b['dessedentacao']?.toString() ?? '';
      _bovinoculturaQtdCochosController.text = b['qtd_cochos']?.toString() ?? '';
      _bovinoculturaTamanhoCochosController.text = b['tamanho_cochos']?.toString() ?? '';
      _bovinoculturaQtdAnimaisController.text = b['qtd_animais']?.toString() ?? '';
      _bovinoculturaFotoGeoOk = b['foto_geo_ok'] == true;
      _bovinoculturaInfracaoConstatada = b['infracao_constatada'] == true;
      
      final sugeridas = b['medida_sugerida']?.toString() ?? '';
      _bovinoculturaMedidaNotificacao = sugeridas.contains('Notificação');
      _bovinoculturaMedidaEmbargo = sugeridas.contains('Embargo');
      _bovinoculturaMedidaAuto = sugeridas.contains('Auto de Infração');
      
      _bovinoculturaObservacoesController.text = b['observacoes']?.toString() ?? '';
    } else if (_selectedTipo == 'Aquicultura' || d.containsKey('aquicultura')) {
      final aq = d['aquicultura'] ?? d;
      _aquiculturaQtdTanquesController.text = aq['qtd_tanques']?.toString() ?? '';
      _aquiculturaAreaTanquesController.text = aq['area_tanques']?.toString() ?? '';
      
      _aquiculturaPossuiAeradores = aq['possui_aeradores'] == true;
      _aquiculturaQtdAeradoresController.text = aq['qtd_aeradores']?.toString() ?? '';
      
      _aquiculturaBombaIdentificada = aq['bomba_identificada'] == true;
      _aquiculturaBombaSituacaoController.text = aq['bomba_situacao']?.toString() ?? '';
      
      _aquiculturaTubulacaoIdentificada = aq['tubulacao_identificada'] == true;
      _aquiculturaTubulacaoSituacaoController.text = aq['tubulacao_situacao']?.toString() ?? '';
      
      _aquiculturaCaptacaoIdentificada = aq['captacao_identificada'] == true;
      _aquiculturaCaptacaoSituacaoController.text = aq['captacao_situacao']?.toString() ?? '';
      
      _aquiculturaHidrometro = aq['hidrometro'] == true;
      _aquiculturaHidrometroSituacaoController.text = aq['hidrometro_situacao']?.toString() ?? '';
      
      _aquiculturaOutrosItensIdentificados = aq['outros_itens_identificados'] == true;
      _aquiculturaOutrosItensSituacaoController.text = aq['outros_itens_situacao']?.toString() ?? '';
      
      _aquiculturaOutorga = aq['outorga'] == true;
      _aquiculturaOutorgaIdentificacaoController.text = aq['outorga_identificacao']?.toString() ?? '';
      
      _aquiculturaDescarteResiduos = aq['descarte_residuos']?.toString()?.toUpperCase() ?? 'COMPOSTEIRA';
      if (_aquiculturaDescarteResiduos != 'COMPOSTEIRA' && _aquiculturaDescarteResiduos != 'OUTRO') {
        _aquiculturaDescarteResiduos = 'COMPOSTEIRA';
      }
      _aquiculturaDescarteResiduosOutroController.text = aq['descarte_residuos_outro']?.toString() ?? '';
      
      _aquiculturaFonteAguaController.text = aq['fonte_agua']?.toString() ?? '';
      
      _aquiculturaFotoGeoOk = aq['foto_geo_ok'] == true;
      _aquiculturaInfracaoConstatada = aq['infracao_constatada'] == true;
      
      final sugeridas = aq['medida_sugerida']?.toString() ?? '';
      _aquiculturaMedidaNotificacao = sugeridas.contains('Notificação');
      _aquiculturaMedidaEmbargo = sugeridas.contains('Embargo');
      _aquiculturaMedidaAuto = sugeridas.contains('Auto de Infração');
      
      _aquiculturaObservacoesController.text = aq['observacoes']?.toString() ?? '';
    } else if (_selectedTipo == 'Atividades Agroindustriais' || d.containsKey('agroindustrial') || d.containsKey('sucroalcooleiro')) {
      final su = d['agroindustrial'] ?? d['sucroalcooleiro'] ?? d;
      _atividadesAgroindustriaisData = Map<String, dynamic>.from(su);
      _atividadesAgroindustriaisResiduosController.text = su['residuos_solidos']?.toString() ?? '';
      _atividadesAgroindustriaisBagacoController.text = su['bagaco']?.toString() ?? '';
      _atividadesAgroindustriaisEquipamentosConformes = su['equipamentos_conformes'] != false;
      _atividadesAgroindustriaisArmazenamentoOk = su['armazenamento_ok'] != false;
    } else if (_selectedTipo == 'Agricultura' || d.containsKey('agricultura')) {
      final ag = d['agricultura'] ?? d;
      _agriculturaData = Map<String, dynamic>.from(ag);
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
        'indicios_uso_app': _supressaoIndiciosUsoApp,
        'rl_isolada': _supressaoRlIsolada,
        'rl_nativa_compativel': _supressaoRlNativaCompativel,
        'bioma': _supressaoBioma,
        
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
        'bloco_a_observacoes': _blocoAInfoAdicionaisController.text.trim(),
        
        // Bloco B - Caatinga
        'bloco_b_estrutura': _blocoBEstruturaOption,
        'bloco_b_observacoes': _blocoBInfoAdicionaisController.text.trim(),
        
        // Outros campos
        'presenca_invasoras': _presencaInvasoras,
        'presenca_exoticas': _presencaExoticas,
        'especies': _especiesInvasorasController.text.trim(),
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
        
        'medida_sugerida': [
          if (_medidaNotificacao) 'Notificação',
          if (_medidaEmbargo) 'Embargo',
          if (_medidaAuto) 'Auto de Infração',
        ].join(', '),
        
        'observacoes': _supressaoObsController.text.trim(),
        'fatos_relevantes': _fatosRelevantesController.text.trim(),
        'complementacao_necessaria': _complementacaoNecessariaController.text.trim(),
      };
    } else if (_selectedTipo == 'Avicultura') {
      payload['avicultura'] = {
        'modelo': _aviculturaModelo,
        
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
        'corte_info_adicional': _corteInfoAdicionalController.text.trim(),
        'corte_comprimento': double.tryParse(_corteComprimentoController.text),
        'corte_largura': double.tryParse(_corteLarguraController.text),
        'corte_area': double.tryParse(_corteAreaController.text),
        'corte_densidade': _corteDensidade,
        'corte_qtd_estimada': int.tryParse(_corteQtdEstimadaController.text),
        'corte_cama_destinacao': _corteCamaDestinacao,
        'corte_cama_outros': _corteCamaOutrosController.text.trim(),
        
        // Postura fields
        'postura_sistema_criacao': _posturaSistemaCriacao,
        'postura_tipo_confinamento': _posturaTipoConfinamento,
        'postura_info_adicional': _posturaInfoAdicionalController.text.trim(),
        'postura_fileiras': int.tryParse(_posturaFileirasController.text),
        'postura_andares': int.tryParse(_posturaAndaresController.text),
        'postura_gaiolas_modulo': int.tryParse(_posturaGaiolasModuloController.text),
        'postura_aves_gaiola': int.tryParse(_posturaAvesGaiolaController.text),
        'postura_qtd_estimada': int.tryParse(_posturaQtdEstimadaController.text),
        
        // Shared fields
        'gera_residuos': _aviculturaGeraResiduos,
        'residuos_detalhes': _aviculturaResiduosDetalhesController.text.trim(),
        'mortos_incinerados': _aviculturaMortosIncinerados,
        'mortos_destinacao_alt': _aviculturaMortosDestinacaoAltController.text.trim(),
        'foto_geo_ok': _aviculturaFotoGeoOk,
        'infracao_constatada': _aviculturaInfracao,
        'medida_sugerida': [
          if (_aviculturaMedidaNotificacao) 'Notificação',
          if (_aviculturaMedidaEmbargo) 'Embargo',
          if (_aviculturaMedidaAuto) 'Auto de Infração',
        ].join(', '),
        'observacoes': _aviculturaObservacoesController.text.trim(),
      };
    } else if (_selectedTipo == 'Suinocultura') {
      final int g = int.tryParse(_suinoculturaQtdGalpoesController.text) ?? 0;
      final int m = int.tryParse(_suinoculturaQtdMedioPorGalpaoController.text) ?? 0;
      final int calculatedQtd = g * m;

      final List<String> fasesSelected = [];
      if (_suinoculturaFaseTerminacao) fasesSelected.add('Terminação');
      if (_suinoculturaFaseMatrizes) fasesSelected.add('Matrizes Gestantes');
      if (_suinoculturaFaseReprodutores) fasesSelected.add('Reprodutores');
      if (_suinoculturaFaseAdulto) fasesSelected.add('Suíno Adulto');

      payload['suinocultura'] = {
        'modelo': _suinoculturaModelo,
        'qtd_galpoes': g,
        'qtd_medio_por_galpao': m,
        
        'fase_terminacao': _suinoculturaFaseTerminacao,
        'fase_terminacao_qtd': _suinoculturaFaseTerminacaoQtdController.text.trim(),
        'fase_matrizes': _suinoculturaFaseMatrizes,
        'fase_matrizes_qtd': _suinoculturaFaseMatrizesQtdController.text.trim(),
        'fase_reprodutores': _suinoculturaFaseReprodutores,
        'fase_reprodutores_qtd': _suinoculturaFaseReprodutoresQtdController.text.trim(),
        'fase_adulto': _suinoculturaFaseAdulto,
        'fase_adulto_qtd': _suinoculturaFaseAdultoQtdController.text.trim(),
        
        'acumulo_residuos': _suinoculturaAcumuloResiduos,
        'vazamento_dejetos': _suinoculturaVazamentoDejetos,
        'odor_extremo': _suinoculturaOdorExtremo,
        'dejetos_transbordando': _suinoculturaDejetosTransbordando,
        'impermeabilizacao_contencao': _suinoculturaImpermeabilizacaoContencao,
        'destinacao_adequada': _suinoculturaDestinacaoAdequada,
        
        'indicios_porte_maior': _suinoculturaIndiciosPorteMaior,
        'indicios_porte_maior_detalhe': _suinoculturaIndiciosPorteMaiorDetalheController.text.trim(),
        
        'mortos_incinerados': _suinoculturaMortosIncinerados,
        'mortos_destino': _suinoculturaMortosDestinoController.text.trim(),
        
        'foto_geo_ok': _suinoculturaFotoGeoOk,
        'infracao_constatada': _suinoculturaInfracaoConstatada,
        'medida_sugerida': [
          if (_suinoculturaMedidaNotificacao) 'Notificação',
          if (_suinoculturaMedidaEmbargo) 'Embargo',
          if (_suinoculturaMedidaAuto) 'Auto de Infração',
        ].join(', '),
        'observacoes': _suinoculturaObservacoesController.text.trim(),

        // Legacy compatibility
        'qtd_animais': calculatedQtd,
        'fase_producao': fasesSelected.join(', '),
        'dejetos_destinacao': _suinoculturaDestinacaoAdequada ? 'Destinação Adequada/Tratamento' : 'Inadequada',
        'conformidade': !_suinoculturaInfracaoConstatada,
      };
    } else if (_selectedTipo == 'Bovinocultura') {
      payload['bovinocultura'] = {
        'modelo': _bovinoculturaModelo,
        'area_ha': double.tryParse(_bovinoculturaAreaController.text),
        'dessedentacao': _bovinoculturaDessedentacaoController.text.trim(),
        'qtd_cochos': int.tryParse(_bovinoculturaQtdCochosController.text),
        'tamanho_cochos': double.tryParse(_bovinoculturaTamanhoCochosController.text),
        'qtd_animais': int.tryParse(_bovinoculturaQtdAnimaisController.text),
        'foto_geo_ok': _bovinoculturaFotoGeoOk,
        'infracao_constatada': _bovinoculturaInfracaoConstatada,
        'medida_sugerida': [
          if (_bovinoculturaMedidaNotificacao) 'Notificação',
          if (_bovinoculturaMedidaEmbargo) 'Embargo',
          if (_bovinoculturaMedidaAuto) 'Auto de Infração',
        ].join(', '),
        'observacoes': _bovinoculturaObservacoesController.text.trim(),
      };
    } else if (_selectedTipo == 'Aquicultura') {
      final List<String> medidas = [];
      if (_aquiculturaMedidaNotificacao) medidas.add('Notificação');
      if (_aquiculturaMedidaEmbargo) medidas.add('Embargo');
      if (_aquiculturaMedidaAuto) medidas.add('Auto de Infração');

      payload['aquicultura'] = {
        'qtd_tanques': int.tryParse(_aquiculturaQtdTanquesController.text),
        'area_tanques': double.tryParse(_aquiculturaAreaTanquesController.text),
        'possui_aeradores': _aquiculturaPossuiAeradores,
        'qtd_aeradores': int.tryParse(_aquiculturaQtdAeradoresController.text),
        
        'bomba_identificada': _aquiculturaBombaIdentificada,
        'bomba_situacao': _aquiculturaBombaSituacaoController.text.trim(),
        
        'tubulacao_identificada': _aquiculturaTubulacaoIdentificada,
        'tubulacao_situacao': _aquiculturaTubulacaoSituacaoController.text.trim(),
        
        'captacao_identificada': _aquiculturaCaptacaoIdentificada,
        'captacao_situacao': _aquiculturaCaptacaoSituacaoController.text.trim(),
        
        'hidrometro': _aquiculturaHidrometro,
        'hidrometro_situacao': _aquiculturaHidrometroSituacaoController.text.trim(),
        
        'outros_itens_identificados': _aquiculturaOutrosItensIdentificados,
        'outros_itens_situacao': _aquiculturaOutrosItensSituacaoController.text.trim(),
        
        'outorga': _aquiculturaOutorga,
        'outorga_identificacao': _aquiculturaOutorgaIdentificacaoController.text.trim(),
        
        'descarte_residuos': _aquiculturaDescarteResiduos,
        'descarte_residuos_outro': _aquiculturaDescarteResiduosOutroController.text.trim(),
        
        'fonte_agua': _aquiculturaFonteAguaController.text.trim(),
        
        'foto_geo_ok': _aquiculturaFotoGeoOk,
        'infracao_constatada': _aquiculturaInfracaoConstatada,
        'medida_sugerida': medidas.join(', '),
        'observacoes': _aquiculturaObservacoesController.text.trim(),
      };
    } else if (_selectedTipo == 'Atividades Agroindustriais') {
      final dataMap = {
        ..._atividadesAgroindustriaisData,
        'residuos_solidos': _atividadesAgroindustriaisResiduosController.text.trim(),
        'bagaco': _atividadesAgroindustriaisBagacoController.text.trim(),
        'equipamentos_conformes': _atividadesAgroindustriaisEquipamentosConformes,
        'armazenamento_ok': _atividadesAgroindustriaisArmazenamentoOk,
      };
      payload['agroindustrial'] = dataMap;
      payload['sucroalcooleiro'] = dataMap;
    } else if (_selectedTipo == 'Agricultura') {
      payload['agricultura'] = {
        ..._agriculturaData,
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
      if (_supressaoBioma.isEmpty) {
        _showWarning('Bioma é obrigatório.');
        return false;
      }
      if (_supressaoObsController.text.trim().isEmpty) {
        _showWarning('Parecer técnico/Observações são obrigatórios.');
        return false;
      }
    } else if (_selectedTipo == 'Avicultura') {
      if (_aviculturaModelo == 'CORTE') {
        if (double.tryParse(_corteComprimentoController.text) == null || double.tryParse(_corteComprimentoController.text)! <= 0) {
          _showWarning('O comprimento do galpão de corte deve ser maior que zero.');
          return false;
        }
        if (double.tryParse(_corteLarguraController.text) == null || double.tryParse(_corteLarguraController.text)! <= 0) {
          _showWarning('A largura do galpão de corte deve ser maior que zero.');
          return false;
        }
      } else {
        if (int.tryParse(_posturaFileirasController.text) == null || int.tryParse(_posturaFileirasController.text)! <= 0) {
          _showWarning('O número de fileiras de postura deve ser maior que zero.');
          return false;
        }
        if (int.tryParse(_posturaAndaresController.text) == null || int.tryParse(_posturaAndaresController.text)! <= 0) {
          _showWarning('O número de andares de postura deve ser maior que zero.');
          return false;
        }
        if (int.tryParse(_posturaGaiolasModuloController.text) == null || int.tryParse(_posturaGaiolasModuloController.text)! <= 0) {
          _showWarning('O número de gaiolas por módulo de postura deve ser maior que zero.');
          return false;
        }
        if (int.tryParse(_posturaAvesGaiolaController.text) == null || int.tryParse(_posturaAvesGaiolaController.text)! <= 0) {
          _showWarning('O número de aves por gaiola de postura deve ser maior que zero.');
          return false;
        }
      }
      if (_aviculturaObservacoesController.text.trim().isEmpty) {
        _showWarning('O parecer técnico da avicultura é obrigatório.');
        return false;
      }
    } else if (_selectedTipo == 'Suinocultura') {
      if (int.tryParse(_suinoculturaQtdGalpoesController.text) == null || int.tryParse(_suinoculturaQtdGalpoesController.text)! <= 0) {
        _showWarning('Quantidade de galpões de suinocultura deve ser maior que zero.');
        return false;
      }
      if (int.tryParse(_suinoculturaQtdMedioPorGalpaoController.text) == null || int.tryParse(_suinoculturaQtdMedioPorGalpaoController.text)! <= 0) {
        _showWarning('A quantidade média de animais por galpão deve ser maior que zero.');
        return false;
      }
      if (_suinoculturaObservacoesController.text.trim().isEmpty) {
        _showWarning('O parecer técnico/observações da suinocultura é obrigatório.');
        return false;
      }
    } else if (_selectedTipo == 'Bovinocultura') {
      if (double.tryParse(_bovinoculturaAreaController.text) == null || double.tryParse(_bovinoculturaAreaController.text)! <= 0) {
        _showWarning('Área em hectares deve ser maior que zero.');
        return false;
      }
      if (_bovinoculturaInfracaoConstatada &&
          !_bovinoculturaMedidaNotificacao &&
          !_bovinoculturaMedidaEmbargo &&
          !_bovinoculturaMedidaAuto) {
        _showWarning('Selecione pelo menos uma medida sugerida pela DIFI.');
        return false;
      }
    } else if (_selectedTipo == 'Aquicultura') {
      if (int.tryParse(_aquiculturaQtdTanquesController.text) == null || int.tryParse(_aquiculturaQtdTanquesController.text)! <= 0) {
        _showWarning('Quantidade de tanques deve ser maior que zero.');
        return false;
      }
      if (_aquiculturaInfracaoConstatada &&
          !_aquiculturaMedidaNotificacao &&
          !_aquiculturaMedidaEmbargo &&
          !_aquiculturaMedidaAuto) {
        _showWarning('Selecione pelo menos uma medida sugerida pela DIFI.');
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
          backgroundColor: Color(0xFF70B324),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF70B324);
    const darkBlue = Color(0xFF00509D);

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
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00509D)),
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (_selectedTipo == 'Supressão Vegetal') {
      final Map<String, dynamic> data = {
        'tem_curso_dagua': _supressaoCursoDagua,
        'app_preservada': _supressaoAppPreservada,
        'indicios_uso_app': _supressaoIndiciosUsoApp,
        'rl_isolada': _supressaoRlIsolada,
        'rl_nativa_compativel': _supressaoRlNativaCompativel,
        'bioma': _supressaoBioma,
        'bloco_a_estagio_sucessional': _blocoAEstagioSucessional,
        'bloco_a_dap_opcao': _blocoADapOption,
        'bloco_a_altura_opcao': _blocoAAlturaOption,
        'bloco_a_serapilheira_opcao': _blocoASerapilheiraOption,
        'bloco_a_epifitas_opcao': _blocoAEpifitasOption,
        'bloco_a_subbosque_opcao': _blocoASubbosqueOption,
        'bloco_a_observacoes': _blocoAInfoAdicionaisController.text,
        'bloco_b_estrutura': _blocoBEstruturaOption,
        'bloco_b_observacoes': _blocoBInfoAdicionaisController.text,
        'presenca_invasoras': _presencaInvasoras,
        'presenca_exoticas': _presencaExoticas,
        'especies': _especiesInvasorasController.text,
        'grau_infestacao': _grauInfestacaoOption,
        'loc_app': _locApp,
        'loc_rl': _locRl,
        'loc_uas': _locUas,
        'pastos_abandonados': _pastosAbandonados,
        'supressao_solo': _supressaoSolo,
        'fogo_app': _fogoApp,
        'fogo_rl': _fogoRl,
        'fogo_uas': _fogoUas,
        'fogo_outras': _fogoOutras,
        'foto_geo_ok': _fotoGeoOk,
        'infracao_constatada': _infracao,
        'infracao': _infracao ? 'Sim: ${_infracaoDescController.text}' : 'Não',
        'medida_sugerida': [
          if (_medidaNotificacao) 'Notificação',
          if (_medidaEmbargo) 'Embargo',
          if (_medidaAuto) 'Auto de Infração',
        ].join(', '),
        'observacoes': _supressaoObsController.text,
        'fatos_relevantes': _fatosRelevantesController.text,
        'complementacao_necessaria': _complementacaoNecessariaController.text,
      };

      return SupressaoForm(
        data: data,
        readOnly: false,
        onChanged: (map) {
          setState(() {
            _supressaoCursoDagua = map['tem_curso_dagua'] == true;
            _supressaoAppPreservada = map['app_preservada'] != false;
            _supressaoIndiciosUsoApp = map['indicios_uso_app'] == true;
            _supressaoRlIsolada = map['rl_isolada'] != false;
            _supressaoRlNativaCompativel = map['rl_nativa_compativel'] != false;
            _supressaoBioma = map['bioma']?.toString() ?? 'MA';
            
            _blocoAEstagioSucessional = map['bloco_a_estagio_sucessional']?.toString() ?? 'Inicial';
            _blocoADapOption = map['bloco_a_dap_opcao']?.toString() ?? 'Até 8 cm';
            _blocoAAlturaOption = map['bloco_a_altura_opcao']?.toString() ?? 'Até 5 m';
            _blocoASerapilheiraOption = map['bloco_a_serapilheira_opcao']?.toString() ?? 'Inexistente ou rala';
            _blocoAEpifitasOption = map['bloco_a_epifitas_opcao']?.toString() ?? 'Ausentes';
            _blocoASubbosqueOption = map['bloco_a_subbosque_opcao']?.toString() ?? 'Ausente';
            _blocoAInfoAdicionaisController.text = map['bloco_a_observacoes']?.toString() ?? '';

            _blocoBEstruturaOption = map['bloco_b_estrutura']?.toString() ?? 'Herbáceo-Arbustiva';
            _blocoBInfoAdicionaisController.text = map['bloco_b_observacoes']?.toString() ?? '';

            _presencaInvasoras = map['presenca_invasoras'] == true;
            _presencaExoticas = map['presenca_exoticas'] == true;
            _especiesInvasorasController.text = map['especies']?.toString() ?? '';
            _grauInfestacaoOption = map['grau_infestacao']?.toString() ?? 'Baixo';
            _locApp = map['loc_app'] == true || map['loc_app']?.toString() == 'Sim';
            _locRl = map['loc_rl'] == true || map['loc_rl']?.toString() == 'Sim';
            _locUas = map['loc_uas'] == true || map['loc_uas']?.toString() == 'Sim';

            _pastosAbandonados = map['pastos_abandonados'] == true;
            _supressaoSolo = map['supressao_solo'] == true;
            _fogoApp = map['fogo_app'] == true;
            _fogoRl = map['fogo_rl'] == true;
            _fogoUas = map['fogo_uas'] == true;
            _fogoOutras = map['fogo_outras'] == true;
            _fotoGeoOk = map['foto_geo_ok'] == true;

            final infVal = map['infracao']?.toString() ?? '';
            _infracao = map['infracao_constatada'] == true;
            if (_infracao && infVal.contains(':')) {
              _infracaoDescController.text = infVal.split(':').skip(1).join(':').trim();
            } else {
              _infracaoDescController.text = '';
            }

            final sugeridas = map['medida_sugerida']?.toString() ?? '';
            _medidaNotificacao = sugeridas.contains('Notificação');
            _medidaEmbargo = sugeridas.contains('Embargo');
            _medidaAuto = sugeridas.contains('Auto de Infração');

            _supressaoObsController.text = map['observacoes']?.toString() ?? '';
            _fatosRelevantesController.text = map['fatos_relevantes']?.toString() ?? '';
            _complementacaoNecessariaController.text = map['complementacao_necessaria']?.toString() ?? '';
          });
        },
      );
    } else if (_selectedTipo == 'Avicultura') {
      final Map<String, dynamic> data = {
        'modelo': _aviculturaModelo,
        'foto_geo_ok': _aviculturaFotoGeoOk,
        
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
        'corte_comprimento': _corteComprimentoController.text,
        'corte_largura': _corteLarguraController.text,
        'corte_area': _corteAreaController.text,
        'corte_densidade': _corteDensidade,
        'corte_qtd_estimada': _corteQtdEstimadaController.text,
        'corte_cama_destinacao': _corteCamaDestinacao,
        'corte_cama_outros': _corteCamaOutrosController.text,

        'postura_sistema_criacao': _posturaSistemaCriacao,
        'postura_tipo_confinamento': _posturaTipoConfinamento,
        'postura_info_adicional': _posturaInfoAdicionalController.text,
        'postura_fileiras': _posturaFileirasController.text,
        'postura_andares': _posturaAndaresController.text,
        'postura_gaiolas_modulo': _posturaGaiolasModuloController.text,
        'postura_aves_gaiola': _posturaAvesGaiolaController.text,
        'postura_qtd_estimada': _posturaQtdEstimadaController.text,

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

      return AviculturaForm(
        data: data,
        readOnly: false,
        onChanged: (map) {
          setState(() {
            _aviculturaModelo = map['modelo']?.toString() ?? 'CORTE';
            _aviculturaFotoGeoOk = map['foto_geo_ok'] == true;

            final rawCorteSistema = map['corte_sistema_criacao']?.toString();
            if (rawCorteSistema == 'Soltas') {
              _corteSistemaCriacao = 'Extensivo / Caipira';
            } else if (rawCorteSistema == 'Confinadas') {
              _corteSistemaCriacao = 'Intensivo (Confinado)';
            } else {
              _corteSistemaCriacao = rawCorteSistema ?? 'Intensivo (Confinado)';
            }
            _corteAvesSoltasChao = map['corte_aves_soltas_chao'] == true;
            _corteCamaCascaArroz = map['corte_cama_casca_arroz'] == true;
            _corteGalpoesLongos = map['corte_galpoes_longos'] == true;
            _corteGalpoesCurtos = map['corte_galpoes_curtos'] == true;
            _corteBebedourosChao = map['corte_bebedouros_chao'] == true;
            _corteBebedourosSuspensos = map['corte_bebedouros_suspensos'] == true;
            _corteComedourosChao = map['corte_comedouros_chao'] == true;
            _corteComedourosSuspensos = map['corte_comedouros_suspensos'] == true;
            _cortePintos = map['corte_pintos'] == true;
            _corteFrangos = map['corte_frangos'] == true;
            _corteVentiladores = map['corte_ventiladores'] == true;
            _corteVentiladoresFunc = map['corte_ventiladores_func'] == true;
            _corteSemVentiladores = map['corte_sem_ventiladores'] == true;
            _corteInfoAdicionalController.text = map['corte_info_adicional']?.toString() ?? '';
            _corteComprimentoController.text = map['corte_comprimento']?.toString() ?? '';
            _corteLarguraController.text = map['corte_largura']?.toString() ?? '';
            _corteAreaController.text = map['corte_area']?.toString() ?? '';
            _corteDensidade = map['corte_densidade']?.toString() ?? 'Convencional (12 a 15 aves/m²)';
            _corteQtdEstimadaController.text = map['corte_qtd_estimada']?.toString() ?? '';
            _corteCamaDestinacao = map['corte_cama_destinacao']?.toString() ?? 'Compostagem';
            _corteCamaOutrosController.text = map['corte_cama_outros']?.toString() ?? '';

            _posturaSistemaCriacao = map['postura_sistema_criacao']?.toString() ?? 'Confinadas';
            _posturaTipoConfinamento = map['postura_tipo_confinamento']?.toString() ?? 'Gaiolas';
            _posturaInfoAdicionalController.text = map['postura_info_adicional']?.toString() ?? '';
            _posturaFileirasController.text = map['postura_fileiras']?.toString() ?? '';
            _posturaAndaresController.text = map['postura_andares']?.toString() ?? '';
            _posturaGaiolasModuloController.text = map['postura_gaiolas_modulo']?.toString() ?? '';
            _posturaAvesGaiolaController.text = map['postura_aves_gaiola']?.toString() ?? '';
            _posturaQtdEstimadaController.text = map['postura_qtd_estimada']?.toString() ?? '';

            _aviculturaGeraResiduos = map['gera_residuos'] == true;
            _aviculturaResiduosDetalhesController.text = map['residuos_detalhes']?.toString() ?? '';
            _aviculturaMortosIncinerados = map['mortos_incinerados'] != false;
            _aviculturaMortosDestinacaoAltController.text = map['mortos_destinacao_alt']?.toString() ?? '';
            _aviculturaInfracao = map['infracao_constatada'] == true;

            final sugeridas = map['medida_sugerida']?.toString() ?? '';
            _aviculturaMedidaNotificacao = sugeridas.contains('Notificação');
            _aviculturaMedidaEmbargo = sugeridas.contains('Embargo');
            _aviculturaMedidaAuto = sugeridas.contains('Auto de Infração');

            _aviculturaObservacoesController.text = map['observacoes']?.toString() ?? '';
          });
        },
      );
    } else if (_selectedTipo == 'Suinocultura') {
      final Map<String, dynamic> data = {
        'modelo': _suinoculturaModelo,
        'qtd_galpoes': _suinoculturaQtdGalpoesController.text,
        'qtd_medio_por_galpao': _suinoculturaQtdMedioPorGalpaoController.text,
        
        'fase_terminacao': _suinoculturaFaseTerminacao,
        'fase_terminacao_qtd': _suinoculturaFaseTerminacaoQtdController.text,
        'fase_matrizes': _suinoculturaFaseMatrizes,
        'fase_matrizes_qtd': _suinoculturaFaseMatrizesQtdController.text,
        'fase_reprodutores': _suinoculturaFaseReprodutores,
        'fase_reprodutores_qtd': _suinoculturaFaseReprodutoresQtdController.text,
        'fase_adulto': _suinoculturaFaseAdulto,
        'fase_adulto_qtd': _suinoculturaFaseAdultoQtdController.text,
        
        'acumulo_residuos': _suinoculturaAcumuloResiduos,
        'vazamento_dejetos': _suinoculturaVazamentoDejetos,
        'odor_extremo': _suinoculturaOdorExtremo,
        'dejetos_transbordando': _suinoculturaDejetosTransbordando,
        'impermeabilizacao_contencao': _suinoculturaImpermeabilizacaoContencao,
        'destinacao_adequada': _suinoculturaDestinacaoAdequada,
        
        'indicios_porte_maior': _suinoculturaIndiciosPorteMaior,
        'indicios_porte_maior_detalhe': _suinoculturaIndiciosPorteMaiorDetalheController.text,
        
        'mortos_incinerados': _suinoculturaMortosIncinerados,
        'mortos_destino': _suinoculturaMortosDestinoController.text,
        
        'foto_geo_ok': _suinoculturaFotoGeoOk,
        'infracao_constatada': _suinoculturaInfracaoConstatada,
        'medida_sugerida': [
          if (_suinoculturaMedidaNotificacao) 'Notificação',
          if (_suinoculturaMedidaEmbargo) 'Embargo',
          if (_suinoculturaMedidaAuto) 'Auto de Infração',
        ].join(', '),
        'observacoes': _suinoculturaObservacoesController.text,
      };

      return SuinoculturaForm(
        data: data,
        readOnly: false,
        onChanged: (map) {
          setState(() {
            _suinoculturaModelo = map['modelo']?.toString() ?? 'CAIPIRA';
            _suinoculturaQtdGalpoesController.text = map['qtd_galpoes']?.toString() ?? '';
            _suinoculturaQtdMedioPorGalpaoController.text = map['qtd_medio_por_galpao']?.toString() ?? '';
            
            _suinoculturaFaseTerminacao = map['fase_terminacao'] == true;
            _suinoculturaFaseTerminacaoQtdController.text = map['fase_terminacao_qtd']?.toString() ?? '';
            _suinoculturaFaseMatrizes = map['fase_matrizes'] == true;
            _suinoculturaFaseMatrizesQtdController.text = map['fase_matrizes_qtd']?.toString() ?? '';
            _suinoculturaFaseReprodutores = map['fase_reprodutores'] == true;
            _suinoculturaFaseReprodutoresQtdController.text = map['fase_reprodutores_qtd']?.toString() ?? '';
            _suinoculturaFaseAdulto = map['fase_adulto'] == true;
            _suinoculturaFaseAdultoQtdController.text = map['fase_adulto_qtd']?.toString() ?? '';
            
            _suinoculturaAcumuloResiduos = map['acumulo_residuos'] == true;
            _suinoculturaVazamentoDejetos = map['vazamento_dejetos'] == true;
            _suinoculturaOdorExtremo = map['odor_extremo'] == true;
            _suinoculturaDejetosTransbordando = map['dejetos_transbordando'] == true;
            _suinoculturaImpermeabilizacaoContencao = map['impermeabilizacao_contencao'] == true;
            _suinoculturaDestinacaoAdequada = map['destinacao_adequada'] != false;
            
            _suinoculturaIndiciosPorteMaior = map['indicios_porte_maior'] == true;
            _suinoculturaIndiciosPorteMaiorDetalheController.text = map['indicios_porte_maior_detalhe']?.toString() ?? '';
            
            _suinoculturaMortosIncinerados = map['mortos_incinerados'] != false;
            _suinoculturaMortosDestinoController.text = map['mortos_destino']?.toString() ?? '';
            
            _suinoculturaFotoGeoOk = map['foto_geo_ok'] == true;
            _suinoculturaInfracaoConstatada = map['infracao_constatada'] == true;
            
            final sugeridas = map['medida_sugerida']?.toString() ?? '';
            _suinoculturaMedidaNotificacao = sugeridas.contains('Notificação');
            _suinoculturaMedidaEmbargo = sugeridas.contains('Embargo');
            _suinoculturaMedidaAuto = sugeridas.contains('Auto de Infração');
            
            _suinoculturaObservacoesController.text = map['observacoes']?.toString() ?? '';
          });
        },
      );
    } else if (_selectedTipo == 'Bovinocultura') {
      final Map<String, dynamic> data = {
        'modelo': _bovinoculturaModelo,
        'area_ha': _bovinoculturaAreaController.text,
        'dessedentacao': _bovinoculturaDessedentacaoController.text,
        'qtd_cochos': _bovinoculturaQtdCochosController.text,
        'tamanho_cochos': _bovinoculturaTamanhoCochosController.text,
        'qtd_animais': _bovinoculturaQtdAnimaisController.text,
        'foto_geo_ok': _bovinoculturaFotoGeoOk,
        'infracao_constatada': _bovinoculturaInfracaoConstatada,
        'medida_sugerida': [
          if (_bovinoculturaMedidaNotificacao) 'Notificação',
          if (_bovinoculturaMedidaEmbargo) 'Embargo',
          if (_bovinoculturaMedidaAuto) 'Auto de Infração',
        ].join(', '),
        'observacoes': _bovinoculturaObservacoesController.text,
      };

      return BovinoculturaForm(
        data: data,
        readOnly: false,
        onChanged: (map) {
          setState(() {
            _bovinoculturaModelo = map['modelo']?.toString() ?? 'EXTENSIVO';
            _bovinoculturaAreaController.text = map['area_ha']?.toString() ?? '';
            _bovinoculturaDessedentacaoController.text = map['dessedentacao']?.toString() ?? '';
            _bovinoculturaQtdCochosController.text = map['qtd_cochos']?.toString() ?? '';
            _bovinoculturaTamanhoCochosController.text = map['tamanho_cochos']?.toString() ?? '';
            _bovinoculturaQtdAnimaisController.text = map['qtd_animais']?.toString() ?? '';
            _bovinoculturaFotoGeoOk = map['foto_geo_ok'] == true;
            _bovinoculturaInfracaoConstatada = map['infracao_constatada'] == true;
            
            final sugeridas = map['medida_sugerida']?.toString() ?? '';
            _bovinoculturaMedidaNotificacao = sugeridas.contains('Notificação');
            _bovinoculturaMedidaEmbargo = sugeridas.contains('Embargo');
            _bovinoculturaMedidaAuto = sugeridas.contains('Auto de Infração');
            
            _bovinoculturaObservacoesController.text = map['observacoes']?.toString() ?? '';
          });
        },
      );
    } else if (_selectedTipo == 'Aquicultura') {
      final List<String> medidas = [];
      if (_aquiculturaMedidaNotificacao) medidas.add('Notificação');
      if (_aquiculturaMedidaEmbargo) medidas.add('Embargo');
      if (_aquiculturaMedidaAuto) medidas.add('Auto de Infração');

      final Map<String, dynamic> data = {
        'qtd_tanques': _aquiculturaQtdTanquesController.text,
        'area_tanques': _aquiculturaAreaTanquesController.text,
        'possui_aeradores': _aquiculturaPossuiAeradores,
        'qtd_aeradores': _aquiculturaQtdAeradoresController.text,
        
        'bomba_identificada': _aquiculturaBombaIdentificada,
        'bomba_situacao': _aquiculturaBombaSituacaoController.text,
        
        'tubulacao_identificada': _aquiculturaTubulacaoIdentificada,
        'tubulacao_situacao': _aquiculturaTubulacaoSituacaoController.text,
        
        'captacao_identificada': _aquiculturaCaptacaoIdentificada,
        'captacao_situacao': _aquiculturaCaptacaoSituacaoController.text,
        
        'hidrometro': _aquiculturaHidrometro,
        'hidrometro_situacao': _aquiculturaHidrometroSituacaoController.text,
        
        'outros_itens_identificados': _aquiculturaOutrosItensIdentificados,
        'outros_itens_situacao': _aquiculturaOutrosItensSituacaoController.text,
        
        'outorga': _aquiculturaOutorga,
        'outorga_identificacao': _aquiculturaOutorgaIdentificacaoController.text,
        
        'descarte_residuos': _aquiculturaDescarteResiduos,
        'descarte_residuos_outro': _aquiculturaDescarteResiduosOutroController.text,
        
        'fonte_agua': _aquiculturaFonteAguaController.text,
        
        'foto_geo_ok': _aquiculturaFotoGeoOk,
        'infracao_constatada': _aquiculturaInfracaoConstatada,
        'medida_sugerida': medidas.join(', '),
        'observacoes': _aquiculturaObservacoesController.text,
      };

      return AquiculturaForm(
        data: data,
        readOnly: false,
        onChanged: (map) {
          setState(() {
            _aquiculturaQtdTanquesController.text = map['qtd_tanques']?.toString() ?? '';
            _aquiculturaAreaTanquesController.text = map['area_tanques']?.toString() ?? '';
            _aquiculturaPossuiAeradores = map['possui_aeradores'] == true;
            _aquiculturaQtdAeradoresController.text = map['qtd_aeradores']?.toString() ?? '';
            
            _aquiculturaBombaIdentificada = map['bomba_identificada'] == true;
            _aquiculturaBombaSituacaoController.text = map['bomba_situacao']?.toString() ?? '';
            
            _aquiculturaTubulacaoIdentificada = map['tubulacao_identificada'] == true;
            _aquiculturaTubulacaoSituacaoController.text = map['tubulacao_situacao']?.toString() ?? '';
            
            _aquiculturaCaptacaoIdentificada = map['captacao_identificada'] == true;
            _aquiculturaCaptacaoSituacaoController.text = map['captacao_situacao']?.toString() ?? '';
            
            _aquiculturaHidrometro = map['hidrometro'] == true;
            _aquiculturaHidrometroSituacaoController.text = map['hidrometro_situacao']?.toString() ?? '';
            
            _aquiculturaOutrosItensIdentificados = map['outros_itens_identificados'] == true;
            _aquiculturaOutrosItensSituacaoController.text = map['outros_itens_situacao']?.toString() ?? '';
            
            _aquiculturaOutorga = map['outorga'] == true;
            _aquiculturaOutorgaIdentificacaoController.text = map['outorga_identificacao']?.toString() ?? '';
            
            _aquiculturaDescarteResiduos = map['descarte_residuos']?.toString()?.toUpperCase() ?? 'COMPOSTEIRA';
            _aquiculturaDescarteResiduosOutroController.text = map['descarte_residuos_outro']?.toString() ?? '';
            
            _aquiculturaFonteAguaController.text = map['fonte_agua']?.toString() ?? '';
            
            _aquiculturaFotoGeoOk = map['foto_geo_ok'] == true;
            _aquiculturaInfracaoConstatada = map['infracao_constatada'] == true;
            
            final sugeridas = map['medida_sugerida']?.toString() ?? '';
            _aquiculturaMedidaNotificacao = sugeridas.contains('Notificação');
            _aquiculturaMedidaEmbargo = sugeridas.contains('Embargo');
            _aquiculturaMedidaAuto = sugeridas.contains('Auto de Infração');
            
            _aquiculturaObservacoesController.text = map['observacoes']?.toString() ?? '';
          });
        },
      );
    } else if (_selectedTipo == 'Atividades Agroindustriais') {
      final Map<String, dynamic> data = {
        ..._atividadesAgroindustriaisData,
        'residuos_solidos': _atividadesAgroindustriaisResiduosController.text,
        'bagaco': _atividadesAgroindustriaisBagacoController.text,
        'equipamentos_conformes': _atividadesAgroindustriaisEquipamentosConformes,
        'armazenamento_ok': _atividadesAgroindustriaisArmazenamentoOk,
      };

      return AtividadesAgroindustriaisForm(
        data: data,
        readOnly: false,
        onChanged: (map) {
          setState(() {
            _atividadesAgroindustriaisData = map;
            _atividadesAgroindustriaisResiduosController.text = map['residuos_solidos']?.toString() ?? '';
            _atividadesAgroindustriaisBagacoController.text = map['bagaco']?.toString() ?? '';
            _atividadesAgroindustriaisEquipamentosConformes = map['equipamentos_conformes'] == true;
            _atividadesAgroindustriaisArmazenamentoOk = map['armazenamento_ok'] == true;
          });
        },
      );
    } else if (_selectedTipo == 'Agricultura') {
      final Map<String, dynamic> data = {
        ..._agriculturaData,
        'cultivo': _agriculturaCultivoController.text,
        'cursos_hidricos_entorno': _agriculturaCursosHidricosController.text,
        'agrotoxicos': _agriculturaAgrotoxicosController.text,
      };

      return AgriculturaForm(
        data: data,
        readOnly: false,
        onChanged: (map) {
          setState(() {
            _agriculturaData = map;
            _agriculturaCultivoController.text = map['cultivo']?.toString() ?? '';
            _agriculturaCursosHidricosController.text = map['cursos_hidricos_entorno']?.toString() ?? '';
            _agriculturaAgrotoxicosController.text = map['agrotoxicos']?.toString() ?? '';
          });
        },
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
  }

  @override
  void dispose() {
    _processoController.dispose();
    _requerenteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _blocoAInfoAdicionaisController.dispose();
    _blocoBInfoAdicionaisController.dispose();
    _especiesInvasorasController.dispose();
    _infracaoDescController.dispose();
    _fatosRelevantesController.dispose();
    _complementacaoNecessariaController.dispose();
    _supressaoObsController.dispose();
    _corteInfoAdicionalController.dispose();
    _corteComprimentoController.dispose();
    _corteLarguraController.dispose();
    _corteAreaController.dispose();
    _corteQtdEstimadaController.dispose();
    _corteCamaOutrosController.dispose();
    _posturaInfoAdicionalController.dispose();
    _posturaFileirasController.dispose();
    _posturaAndaresController.dispose();
    _posturaGaiolasModuloController.dispose();
    _posturaAvesGaiolaController.dispose();
    _posturaQtdEstimadaController.dispose();
    _aviculturaResiduosDetalhesController.dispose();
    _aviculturaMortosDestinacaoAltController.dispose();
    _aviculturaObservacoesController.dispose();
    _suinoculturaQtdGalpoesController.dispose();
    _suinoculturaQtdMedioPorGalpaoController.dispose();
    _suinoculturaFaseTerminacaoQtdController.dispose();
    _suinoculturaFaseMatrizesQtdController.dispose();
    _suinoculturaFaseReprodutoresQtdController.dispose();
    _suinoculturaFaseAdultoQtdController.dispose();
    _suinoculturaIndiciosPorteMaiorDetalheController.dispose();
    _suinoculturaMortosDestinoController.dispose();
    _suinoculturaObservacoesController.dispose();
    _bovinoculturaAreaController.dispose();
    _bovinoculturaDessedentacaoController.dispose();
    _aquiculturaQtdTanquesController.dispose();
    _aquiculturaAreaTanquesController.dispose();
    _aquiculturaQtdAeradoresController.dispose();
    _aquiculturaBombaSituacaoController.dispose();
    _aquiculturaTubulacaoSituacaoController.dispose();
    _aquiculturaCaptacaoSituacaoController.dispose();
    _aquiculturaHidrometroSituacaoController.dispose();
    _aquiculturaOutrosItensSituacaoController.dispose();
    _aquiculturaOutorgaIdentificacaoController.dispose();
    _aquiculturaDescarteResiduosOutroController.dispose();
    _aquiculturaFonteAguaController.dispose();
    _aquiculturaObservacoesController.dispose();
    _atividadesAgroindustriaisResiduosController.dispose();
    _atividadesAgroindustriaisBagacoController.dispose();
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
