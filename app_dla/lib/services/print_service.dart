import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'vistoria_service.dart';

class ReceiptLine {
  final String text;
  final PosAlign align;
  final bool bold;
  final bool doubleSize;

  const ReceiptLine(
    this.text, {
    this.align = PosAlign.left,
    this.bold = false,
    this.doubleSize = false,
  });
}

class PrintService {
  static final PrintService instance = PrintService._init();

  PrintService._init();

  // Busca impressoras pareadas ou visíveis
  Future<List<BluetoothInfo>> getPrinters() async {
    try {
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      debugPrint("Erro ao buscar impressoras: $e");
      return [];
    }
  }

  // Tenta conexão automática à impressora da maquineta
  Future<bool> autoConnect() async {
    try {
      final bool alreadyConnected = await PrintBluetoothThermal.connectionStatus;
      if (alreadyConnected) return true;

      final List<BluetoothInfo> devices = await getPrinters();
      if (devices.isEmpty) return false;

      // Procura por nomes comuns de impressoras embutidas de maquinetas Tanca, Gertec, Sunmi, etc.
      BluetoothInfo? target;
      for (var device in devices) {
        final name = device.name.toLowerCase();
        if (name.contains("innerprinter") ||
            name.contains("printer") ||
            name.contains("tanca") ||
            name.contains("tsm") ||
            name.contains("pos") ||
            name.contains("thermal") ||
            name.contains("mobi")) {
          target = device;
          break;
        }
      }

      // Se não achou nenhum nome correspondente, tenta a primeira da lista
      target ??= devices.first;

      return await PrintBluetoothThermal.connect(macPrinterAddress: target.macAdress);
    } catch (e) {
      debugPrint("Erro na conexão automática da impressora: $e");
      return false;
    }
  }

  // Desconectar
  Future<bool> disconnect() async {
    return await PrintBluetoothThermal.disconnect;
  }

  // Quebra de texto simples mantendo palavras quando possível
  static List<String> wrapText(String text, int width) {
    if (text.isEmpty) return [''];
    if (text.length <= width) return [text];
    List<String> result = [];
    int start = 0;
    while (start < text.length) {
      int end = start + width;
      if (end >= text.length) {
        result.add(text.substring(start));
        break;
      }
      int space = text.lastIndexOf(' ', end);
      if (space > start) {
        result.add(text.substring(start, space));
        start = space + 1;
      } else {
        result.add(text.substring(start, end));
        start = end;
      }
    }
    return result;
  }

  // Monta a estrutura de linhas do recibo (usada tanto no app quanto na impressora)
  List<ReceiptLine> buildReceiptLines(Vistoria vistoria, {String? technicianName}) {
    final List<ReceiptLine> lines = [];
    const int cols = 32;
    final String separator = '-' * cols;
    final String doubleSeparator = '=' * cols;

    void addLine(String text, {PosAlign align = PosAlign.left, bool bold = false, bool doubleSize = false}) {
      final int limit = doubleSize ? 16 : 32;
      final wrapped = wrapText(text, limit);
      for (var chunk in wrapped) {
        lines.add(ReceiptLine(chunk, align: align, bold: bold, doubleSize: doubleSize));
      }
    }

    // Cabeçalho
    addLine('SUDEMA', align: PosAlign.center, bold: true);
    addLine('Sup. de Administracao do Meio Ambiente', align: PosAlign.center);
    addLine(doubleSeparator, align: PosAlign.center);
    addLine('COMPROVANTE DE VISTORIA', align: PosAlign.center, bold: true);
    
    if (!vistoria.synced) {
      addLine('* NAO SINCRONIZADO *', align: PosAlign.center, bold: true);
    }
    addLine(doubleSeparator, align: PosAlign.center);

    // Dados Gerais
    final Map<String, dynamic> data = vistoria.data;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final dateStr = dateFormat.format(vistoria.createdAt);

    addLine('Processo: ${data['processo_n'] ?? 'N/A'}', bold: true);
    addLine('Requerente: ${data['requerente'] ?? 'N/A'}');
    if (technicianName != null && technicianName.isNotEmpty) {
      addLine('Tecnico: $technicianName');
    }
    addLine('Tipo: ${data['tipo'] ?? 'N/A'}');
    addLine('Data: $dateStr');
    addLine('Lat: ${data['latitude'] ?? 'N/A'}');
    addLine('Long: ${data['longitude'] ?? 'N/A'}');

    // Dados Específicos dependendo do tipo de vistoria
    final tipo = (data['tipo']?.toString() ?? '').toLowerCase();

    if (tipo.contains('supress') || tipo.contains('ambiental') || data.containsKey('supressao')) {
      final s = data['supressao'] ?? data;
      final bool isMa = s['bioma'] == 'MA' || s['bioma']?.toString().toUpperCase() == 'MATA ATLÂNTICA';
      final String biomaName = isMa ? 'Mata Atlantica' : 'Caatinga';
      
      addLine(separator, align: PosAlign.center);
      addLine('DADOS DE SUPRESSAO VEGETAL', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Bioma Predominante: $biomaName');
      addLine('Curso d\'agua: ${s['tem_curso_dagua'] == true ? 'Sim' : 'Nao'}');
      addLine('APP Preservada: ${s['app_preservada'] == true ? 'Sim' : 'Nao'}');
      addLine('Indicios Uso APP: ${s['indicios_uso_app'] == true ? 'Sim' : 'Nao'}');
      addLine('RL Isolada: ${s['rl_isolada'] == true ? 'Sim' : 'Nao'}');
      addLine('RL Compativel CAR: ${s['rl_nativa_compativel'] == true ? 'Sim' : 'Nao'}');

      addLine(separator, align: PosAlign.center);
      addLine('FICHA TECNICA DO BIOMA', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      if (isMa) {
        addLine('Estagio Sucessional: ${s['bloco_a_estagio_sucessional'] ?? 'N/A'}');
        addLine('DAP Medio: ${s['bloco_a_dap_opcao'] ?? 'N/A'}');
        addLine('Altura (Dossel): ${s['bloco_a_altura_opcao'] ?? 'N/A'}');
        addLine('Serapilheira: ${s['bloco_a_serapilheira_opcao'] ?? 'N/A'}');
        addLine('Epifitas / Cipos: ${s['bloco_a_epifitas_opcao'] ?? 'N/A'}');
        addLine('Sub-bosque: ${s['bloco_a_subbosque_opcao'] ?? 'N/A'}');
        if (s['bloco_a_observacoes'] != null && s['bloco_a_observacoes'].toString().isNotEmpty) {
          addLine('Obs Bloco A: ${s['bloco_a_observacoes']}');
        }
      } else {
        addLine('Caatinga Estrutura: ${s['bloco_b_estrutura'] ?? 'N/A'}');
        if (s['bloco_b_observacoes'] != null && s['bloco_b_observacoes'].toString().isNotEmpty) {
          addLine('Obs Bloco B: ${s['bloco_b_observacoes']}');
        }
      }

      addLine(separator, align: PosAlign.center);
      addLine('DIAGNOSTICO FISICO-AMBIENTAL', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Especies Invasoras: ${s['presenca_invasoras'] == true ? 'Sim' : 'Nao'}');
      addLine('Especies Exoticas: ${s['presenca_exoticas'] == true ? 'Sim' : 'Nao'}');
      if (s['presenca_invasoras'] == true || s['presenca_exoticas'] == true) {
        addLine('Especies: ${s['especies'] ?? 'N/A'}');
        addLine('Grau de Infestacao: ${s['grau_infestacao'] ?? 'N/A'}');
        addLine('Loc: APP:${s['loc_app'] == true ? 'S' : 'N'} | RL:${s['loc_rl'] == true ? 'S' : 'N'} | UAS:${s['loc_uas'] == true ? 'S' : 'N'}');
      }
      addLine('Pastos Abandonados: ${s['pastos_abandonados'] == true ? 'Sim' : 'Nao'}');
      addLine('Supressao/Mov. Solo: ${s['supressao_solo'] == true ? 'Sim' : 'Nao'}');

      addLine(separator, align: PosAlign.center);
      addLine('REGISTRO DE FOGO', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Fogo APP: ${s['fogo_app'] == true ? 'Sim' : 'Nao'} | RL: ${s['fogo_rl'] == true ? 'Sim' : 'Nao'}');
      addLine('Fogo UAS: ${s['fogo_uas'] == true ? 'Sim' : 'Nao'} | Outras: ${s['fogo_outras'] == true ? 'Sim' : 'Nao'}');

      addLine(separator, align: PosAlign.center);
      addLine('FISCALIZACAO & DIFI', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      final bool infracaoConstatada = s['infracao']?.toString().startsWith('Sim') == true || s['infracao_constatada'] == true;
      addLine('Infracao Constatada: ${infracaoConstatada ? 'Sim' : 'Nao'}');
      if (s['infracao'] != null && s['infracao'].toString().isNotEmpty) {
        addLine('Det. Infracao: ${s['infracao']}');
      }
      addLine('Medida Sugerida DIFI: ${s['medida_sugerida'] ?? 'Nenhuma'}');
      addLine('Foto Geo OK: ${s['foto_geo_ok'] == true ? 'Sim' : 'Nao'}');
      addLine('Parecer: ${s['observacoes'] ?? 'Sem parecer'}');

    } else if (tipo.contains('aviculture') || tipo.contains('avicultura') || data.containsKey('avicultura')) {
      final a = data['avicultura'] ?? data;
      final String modelo = a['modelo']?.toString().toUpperCase() ?? 'CORTE';
      final bool isCorte = modelo == 'CORTE';

      addLine(separator, align: PosAlign.center);
      addLine('DADOS DE AVICULTURA', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Modelo: ${isCorte ? 'Corte (Frango)' : 'Postura (Ovos)'}');

      if (isCorte) {
        addLine(separator, align: PosAlign.center);
        addLine('PARAMETROS DE CORTE', bold: true, align: PosAlign.center);
        addLine(separator, align: PosAlign.center);
        addLine('Sistema Criacao: ${a['corte_sistema_criacao'] ?? 'N/A'}');
        addLine('Densidade Recomendada: ${a['corte_densidade'] ?? 'N/A'}');
        addLine('Aves Soltas Chao: ${a['corte_aves_soltas_chao'] == true ? 'Sim' : 'Nao'}');
        addLine('Cama (Casca Arroz): ${a['corte_cama_casca_arroz'] == true ? 'Sim' : 'Nao'}');
        addLine('Galpoes Longos: ${a['corte_galpoes_longos'] == true ? 'Sim' : 'Nao'}');
        addLine('Galpoes Curtos: ${a['corte_galpoes_curtos'] == true ? 'Sim' : 'Nao'}');
        addLine('Bebedouros Chao: ${a['corte_bebedouros_chao'] == true ? 'Sim' : 'Nao'}');
        addLine('Bebedouros Suspensos: ${a['corte_bebedouros_suspensos'] == true ? 'Sim' : 'Nao'}');
        addLine('Comedouros Chao: ${a['corte_comedouros_chao'] == true ? 'Sim' : 'Nao'}');
        addLine('Comedouros Suspensos: ${a['corte_comedouros_suspensos'] == true ? 'Sim' : 'Nao'}');
        addLine('Fase Pintos: ${a['corte_pintos'] == true ? 'Sim' : 'Nao'}');
        addLine('Fase Frangos: ${a['corte_frangos'] == true ? 'Sim' : 'Nao'}');
        addLine('Possui Ventiladores: ${a['corte_ventiladores'] == true ? 'Sim' : 'Nao'}');
        if (a['corte_ventiladores'] == true) {
          addLine('Ventiladores Func: ${a['corte_ventiladores_func'] == true ? 'Sim' : 'Nao'}');
        }
        addLine('Sem Ventiladores: ${a['corte_sem_ventiladores'] == true ? 'Sim' : 'Nao'}');
        addLine('Medidas: ${a['corte_comprimento'] ?? 'N/A'}m x ${a['corte_largura'] ?? 'N/A'}m');
        addLine('Area Calculada: ${a['corte_area'] ?? 'N/A'} m2');
        addLine('Estimativa Animais: ${a['corte_qtd_estimada'] ?? 'N/A'}');
        addLine('Destinacao Cama: ${a['corte_cama_destinacao'] ?? 'N/A'}');
        if (a['corte_cama_destinacao']?.toString() == 'Outros') {
          addLine('Detalhes Destino: ${a['corte_cama_outros'] ?? 'N/A'}');
        }
        if (a['corte_info_adicional'] != null && a['corte_info_adicional'].toString().trim().isNotEmpty) {
          addLine('Obs Especificas: ${a['corte_info_adicional']}');
        }
      } else {
        addLine(separator, align: PosAlign.center);
        addLine('PARAMETROS DE POSTURA', bold: true, align: PosAlign.center);
        addLine(separator, align: PosAlign.center);
        addLine('Sistema Criacao: ${a['postura_sistema_criacao'] ?? 'N/A'}');
        addLine('Confinamento: ${a['postura_tipo_confinamento'] ?? 'N/A'}');
        addLine('Fileiras: ${a['postura_fileiras'] ?? 'N/A'} | Andares: ${a['postura_andares'] ?? 'N/A'}');
        addLine('Gaiolas/Modulo: ${a['postura_gaiolas_modulo'] ?? 'N/A'}');
        addLine('Aves por Gaiola: ${a['postura_aves_gaiola'] ?? 'N/A'}');
        addLine('Estimativa Total Aves: ${a['postura_qtd_estimada'] ?? 'N/A'}');
        if (a['postura_info_adicional'] != null && a['postura_info_adicional'].toString().trim().isNotEmpty) {
          addLine('Obs Especificas: ${a['postura_info_adicional']}');
        }
      }

      addLine(separator, align: PosAlign.center);
      addLine('MEIO AMBIENTE & DIFI', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Gera Residuos: ${a['gera_residuos'] == true ? 'Sim' : 'Nao'}');
      if (a['gera_residuos'] == true && a['residuos_detalhes'] != null && a['residuos_detalhes'].toString().isNotEmpty) {
        addLine('Det Residuos: ${a['residuos_detalhes']}');
      }
      addLine('Mortos Incinerados: ${a['mortos_incinerados'] != false ? 'Sim' : 'Nao'}');
      if (a['mortos_incinerados'] == false && a['mortos_destinacao_alt'] != null && a['mortos_destinacao_alt'].toString().isNotEmpty) {
        addLine('Destino Alternativo: ${a['mortos_destinacao_alt']}');
      }
      addLine('Infracao Constatada: ${a['infracao_constatada'] == true ? 'Sim' : 'Nao'}');
      addLine('Medida Sugerida DIFI: ${a['medida_sugerida'] ?? 'Nenhuma'}');
      addLine('Foto Geo OK: ${a['foto_geo_ok'] == true ? 'Sim' : 'Nao'}');
      addLine('Parecer: ${a['observacoes'] ?? 'Sem parecer'}');

    } else if (tipo.contains('suinocultura') || data.containsKey('suinocultura')) {
      final s = data['suinocultura'] ?? data;
      final String modelo = s['modelo']?.toString().toUpperCase() ?? 'CAIPIRA';

      addLine(separator, align: PosAlign.center);
      addLine('DADOS DE SUINOCULTURA', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Modelo: ${modelo == 'INDUSTRIAL' ? 'Industrial' : 'Caipira'}');
      addLine('Qtd Galpoes: ${s['qtd_galpoes'] ?? 'N/A'}');
      addLine('Media por Galpao: ${s['qtd_medio_por_galpao'] ?? 'N/A'}');
      addLine('Total Animais: ${s['qtd_animais'] ?? 'N/A'}');

      addLine(separator, align: PosAlign.center);
      addLine('FASES DE PRODUCAO', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Terminacao: ${s['fase_terminacao'] == true ? 'Sim (${s['fase_terminacao_qtd'] ?? 0})' : 'Nao'}');
      addLine('Matrizes Gestantes: ${s['fase_matrizes'] == true ? 'Sim (${s['fase_matrizes_qtd'] ?? 0})' : 'Nao'}');
      addLine('Reprodutores: ${s['fase_reprodutores'] == true ? 'Sim (${s['fase_reprodutores_qtd'] ?? 0})' : 'Nao'}');
      addLine('Suino Adulto: ${s['fase_adulto'] == true ? 'Sim (${s['fase_adulto_qtd'] ?? 0})' : 'Nao'}');

      addLine(separator, align: PosAlign.center);
      addLine('DIAGNOSTICO SANITARIO', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Acumulo Residuos: ${s['acumulo_residuos'] == true ? 'Sim' : 'Nao'}');
      addLine('Vazamento Dejetos: ${s['vazamento_dejetos'] == true ? 'Sim' : 'Nao'}');
      addLine('Odor Extremo: ${s['odor_extremo'] == true ? 'Sim' : 'Nao'}');
      addLine('Dejetos Transbordando: ${s['dejetos_transbordando'] == true ? 'Sim' : 'Nao'}');
      addLine('Impermeabilizacao/Contencao: ${s['impermeabilizacao_contencao'] == true ? 'Sim' : 'Nao'}');
      addLine('Destinacao/Tratamento: ${s['destinacao_adequada'] == true ? 'Sim' : 'Nao'}');

      addLine('Indicios Porte Maior: ${s['indicios_porte_maior'] == true ? 'Sim' : 'Nao'}');
      if (s['indicios_porte_maior'] == true && s['indicios_porte_maior_detalhe'] != null && s['indicios_porte_maior_detalhe'].toString().isNotEmpty) {
        addLine('Det Porte: ${s['indicios_porte_maior_detalhe']}');
      }

      addLine('Mortos Incinerados: ${s['mortos_incinerados'] != false ? 'Sim' : 'Nao'}');
      if (s['mortos_incinerados'] == false && s['mortos_destino'] != null && s['mortos_destino'].toString().isNotEmpty) {
        addLine('Destino Mortos: ${s['mortos_destino']}');
      }

      addLine(separator, align: PosAlign.center);
      addLine('FISCALIZACAO & DIFI', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Infracao Constatada: ${s['infracao_constatada'] == true ? 'Sim' : 'Nao'}');
      addLine('Medida Sugerida DIFI: ${s['medida_sugerida'] ?? 'Nenhuma'}');
      addLine('Foto Geo OK: ${s['foto_geo_ok'] == true ? 'Sim' : 'Nao'}');
      addLine('Parecer: ${s['observacoes'] ?? 'Sem parecer'}');

    } else if (tipo.contains('bovinocultura') || data.containsKey('bovinocultura')) {
      final b = data['bovinocultura'] ?? data;
      final bool isIntensivo = b['modelo']?.toString().toUpperCase() == 'INTENSIVO';

      addLine(separator, align: PosAlign.center);
      addLine('DADOS DE BOVINOCULTURA', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Modelo: ${isIntensivo ? 'Intensivo (Confinamento)' : 'Extensivo (Pasto)'}');
      addLine('Area Destinada (ha): ${b['area_ha'] ?? 'N/A'}');
      addLine('Quantidade de Cochos: ${b['qtd_cochos'] ?? 'N/A'}');
      addLine('Tamanho Cochos (m): ${b['tamanho_cochos'] ?? 'N/A'}');
      addLine('Dessedentacao: ${b['dessedentacao'] ?? 'N/A'}');
      addLine('Total Animais: ${b['qtd_animais'] ?? 'N/A'}');

      addLine(separator, align: PosAlign.center);
      addLine('FISCALIZACAO & DIFI', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Infracao Constatada: ${b['infracao_constatada'] == true ? 'Sim' : 'Nao'}');
      addLine('Medida Sugerida DIFI: ${b['medida_sugerida'] ?? 'Nenhuma'}');
      addLine('Foto Geo OK: ${b['foto_geo_ok'] == true ? 'Sim' : 'Nao'}');
      addLine('Parecer: ${b['observacoes'] ?? 'Sem parecer'}');

    } else if (tipo.contains('aquicultura') || data.containsKey('aquicultura')) {
      final aq = data['aquicultura'] ?? data;
      final bool possessesAeradores = aq['possui_aeradores'] == true;
      final String descarte = aq['descarte_residuos']?.toString().toUpperCase() ?? 'COMPOSTEIRA';

      addLine(separator, align: PosAlign.center);
      addLine('DADOS DE AQUICULTURA', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Viveiros: ${aq['qtd_tanques'] ?? 0} tanques | ${aq['area_tanques'] ?? 0} ha');
      addLine('Tanques com Aeradores: ${possessesAeradores ? 'Sim' : 'Nao'}');
      if (possessesAeradores) {
        addLine('Qtd Aeradores/Tanque: ${aq['qtd_aeradores'] ?? 'N/A'}');
      }

      addLine(separator, align: PosAlign.center);
      addLine('EQUIPAMENTOS IDENTIFICADOS', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Bomba: ${aq['bomba_identificada'] == true ? 'Sim (${aq['bomba_situacao'] ?? "N/A"})' : 'Nao'}');
      addLine('Tubulacao: ${aq['tubulacao_identificada'] == true ? 'Sim (${aq['tubulacao_situacao'] ?? "N/A"})' : 'Nao'}');
      addLine('Ponto Captacao: ${aq['captacao_identificada'] == true ? 'Sim (${aq['captacao_situacao'] ?? "N/A"})' : 'Nao'}');
      addLine('Hidrometro: ${aq['hidrometro'] == true ? 'Sim (${aq['hidrometro_situacao'] ?? "N/A"})' : 'Nao'}');
      addLine('Outros Itens: ${aq['outros_itens_identificados'] == true ? 'Sim (${aq['outros_itens_situacao'] ?? "N/A"})' : 'Nao'}');

      addLine(separator, align: PosAlign.center);
      addLine('RECURSOS HIDRICOS & RESIDUOS', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Outorga de Agua: ${aq['outorga'] == true ? 'Sim (${aq['outorga_identificacao'] ?? "N/A"})' : 'Nao'}');
      addLine('Descarte Residuos: ${descarte == 'OUTRO' ? aq['descarte_residuos_outro'] ?? 'Outro' : 'Composteira'}');

      addLine(separator, align: PosAlign.center);
      addLine('FISCALIZACAO & DIFI', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Infracao Constatada: ${aq['infracao_constatada'] == true ? 'Sim' : 'Nao'}');
      addLine('Medida Sugerida DIFI: ${aq['medida_sugerida'] ?? 'Nenhuma'}');
      addLine('Foto Geo OK: ${aq['foto_geo_ok'] == true ? 'Sim' : 'Nao'}');
      addLine('Parecer: ${aq['observacoes'] ?? 'Sem parecer'}');

    } else if (tipo.contains('sucroalcooleiro') || tipo.contains('agroindustriais') || tipo.contains('agroindustrial') || data.containsKey('agroindustrial') || data.containsKey('sucroalcooleiro')) {
      final su = data['agroindustrial'] ?? data['sucroalcooleiro'] ?? data;
      
      addLine(separator, align: PosAlign.center);
      addLine('ATIVIDADES AGROINDUSTRIAIS', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);

      addLine('Materia-Prima local:');
      addLine('${su['local_materia_prima'] ?? 'N/A'}');

      addLine('Produz efluentes: ${su['produz_efluentes'] == true ? 'Sim' : 'Nao'}');
      if (su['produz_efluentes'] == true) {
        addLine('Efl. Coleta/Dest: ${su['efluentes_coleta_destinacao'] ?? 'N/A'}');
      }

      addLine('Produz res. solidos: ${su['produz_residuos'] == true ? 'Sim' : 'Nao'}');
      if (su['produz_residuos'] == true) {
        addLine('Res. Coleta/Dest: ${su['residuos_coleta_destinacao'] ?? 'N/A'}');
      }

      addLine('Gera/Utiliza bagaco: ${su['gera_utiliza_bagaco'] == true ? 'Sim' : 'Nao'}');
      if (su['gera_utiliza_bagaco'] == true) {
        addLine('Bagaco Arm/Dest: ${su['bagaco_armazenamento_destinacao'] ?? 'N/A'}');
      }

      addLine('Fontes termicas: ${su['fontes_termicas'] == true ? 'Sim' : 'Nao'}');
      if (su['fontes_termicas'] == true) {
        addLine('Qual fonte: ${su['fontes_termicas_quais'] ?? 'N/A'}');
      }

      addLine('Utiliza lenha: ${su['utiliza_lenha'] == true ? 'Sim' : 'Nao'}');
      if (su['utiliza_lenha'] == true) {
        addLine('Origem: ${su['lenha_nativa_exotica'] ?? 'N/A'}');
        addLine('Lenha Armaz: ${su['lenha_local_armazenamento'] ?? 'N/A'}');
      }

      addLine('Tanques adequados: ${su['tanques_adequados'] == true ? 'Sim' : 'Nao'}');
      addLine('Higienizacao e contr: ${su['higienizacao_controle_efluentes'] == true ? 'Sim' : 'Nao'}');
      addLine('Fossa septica: ${su['fossa_septica'] == true ? 'Sim' : 'Nao'}');
      addLine('Equipamentos conf: ${su['equipamentos_memorial'] == true || su['equipamentos_conformes'] == true ? 'Sim' : 'Nao'}');
      addLine('Controle chamine: ${su['chamines_controle_emissoes'] == true ? 'Sim' : 'Nao'}');
      
      addLine('Sistema vinhaca: ${su['sistema_vinhaca'] == true ? 'Sim' : 'Nao'}');
      if (su['sistema_vinhaca'] == true) {
        addLine('Condicoes: ${su['vinhaca_condicoes'] ?? 'N/A'}');
      }

      addLine('Tanques impermeab: ${su['tanques_lagoas_impermeabilizadas'] == true ? 'Sim' : 'Nao'}');
      addLine('Vazamentos/infilt: ${su['vazamentos_infiltracoes'] == true ? 'Sim' : 'Nao'}');
      addLine('Destinacao efluente: ${su['efluentes_destinados_corretamente'] == true ? 'Sim' : 'Nao'}');
      addLine('Gestao PGRS: ${su['gestao_residuos_pgrs'] == true ? 'Sim' : 'Nao'}');
      
      addLine('Area envase espec: ${su['area_especifica_envase'] == true ? 'Sim' : 'Nao'}');
      if (su['area_especifica_envase'] == true) {
        addLine('Condicoes envase: ${su['envase_condicoes'] ?? 'N/A'}');
      }

      addLine('Armazenamento OK: ${su['armazenamento_requisitos_ambientais'] == true || su['armazenamento_ok'] == true ? 'Sim' : 'Nao'}');
      
      addLine('Uso agrotoxicos: ${su['faz_uso_agrotoxicos'] == true ? 'Sim' : 'Nao'}');
      if (su['faz_uso_agrotoxicos'] == true) {
        addLine('Quais: ${su['agrotoxicos_quais'] ?? 'N/A'}');
        addLine('Receituario: ${su['agrotoxicos_receituario'] == true ? 'Sim' : 'Nao'}');
        addLine('Dest. Embalagens: ${su['agrotoxicos_embalagens_destinacao'] ?? 'N/A'}');
      }

      addLine(separator, align: PosAlign.center);
      addLine('FISCALIZACAO & DIFI', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Foto Geo OK: ${su['foto_geo_ok'] == true ? 'Sim' : 'Nao'}');
      addLine('Infracao Constatada: ${su['infracao_constatada'] == true ? 'Sim' : 'Nao'}');
      if (su['infracao_constatada'] == true) {
        addLine('Medidas DIFI: ${su['infracao_sugestao_medidas'] ?? su['medida_sugerida'] ?? 'Nenhuma'}');
      }
      addLine('Parecer: ${su['observacoes_complementares'] ?? su['observacoes'] ?? 'Sem parecer'}');

    } else if (tipo.contains('agricultura') || data.containsKey('agricultura')) {
      final ag = data['agricultura'] ?? data;
      
      addLine(separator, align: PosAlign.center);
      addLine('ATIVIDADES AGRICOLAS', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Cultivo: ${ag['atividade_agricola'] ?? ag['cultivo'] ?? 'N/A'}');
      addLine('Irrigada: ${ag['atividade_irrigada'] == true ? 'Sim' : 'Nao'}');
      if (ag['atividade_irrigada'] == true) {
        addLine('Outorga: ${ag['irrigada_outorga'] ?? 'N/A'}');
      }
      addLine('Uso agrotoxicos: ${ag['faz_uso_agrotoxicos'] == true ? 'Sim' : 'Nao'}');
      if (ag['faz_uso_agrotoxicos'] == true) {
        addLine('Quais: ${ag['agrotoxicos_quais'] ?? ag['agrotoxicos'] ?? 'N/A'}');
        addLine('Receituario: ${ag['agrotoxicos_receituario'] == true ? 'Sim' : 'Nao'}');
        addLine('Dest. Embalagens: ${ag['agrotoxicos_embalagens_destinacao'] ?? 'N/A'}');
      }
      addLine('Corpo Hidrico Entorno: ${ag['tem_cursos_hidricos'] == true || ag['cursos_hidricos_entorno']?.toString()?.toLowerCase() == 'sim' ? 'Sim' : 'Nao'}');
      
      addLine(separator, align: PosAlign.center);
      addLine('FISCALIZACAO & DIFI', bold: true, align: PosAlign.center);
      addLine(separator, align: PosAlign.center);
      addLine('Foto Geo OK: ${ag['foto_geo_ok'] == true ? 'Sim' : 'Nao'}');
      addLine('Infracao Constatada: ${ag['infracao_constatada'] == true ? 'Sim' : 'Nao'}');
      if (ag['infracao_constatada'] == true) {
        addLine('Medidas DIFI: ${ag['infracao_sugestao_medidas'] ?? ag['medida_sugerida'] ?? 'Nenhuma'}');
      }
      addLine('Parecer: ${ag['observacoes_complementares'] ?? ag['observacoes'] ?? 'Sem parecer'}');
    }

    addLine(doubleSeparator, align: PosAlign.center);

    // Rodapé
    addLine('ID Local: ${vistoria.localId}', align: PosAlign.center);
    addLine('Impresso em:', align: PosAlign.center);
    addLine(dateFormat.format(DateTime.now()), align: PosAlign.center);

    return lines;
  }

  // Gera os bytes ESC/POS brutos a partir das ReceiptLine
  List<int> buildReceiptBytes(Vistoria vistoria, {String? technicianName}) {
    List<int> bytes = [];

    // Inicialização da impressora (Zera configurações anteriores)
    bytes += [27, 64]; // ESC @
    // Configura a impressora para usar a Fonte A  (Fonte normal 11x17)
    bytes += [27, 77, 0]; // ESC M 1

    final lines = buildReceiptLines(vistoria, technicianName: technicianName);

    for (var line in lines) {
      // 1. Alinhamento
      switch (line.align) {
        case PosAlign.center:
          bytes += [27, 97, 1]; // ESC a 1
          break;
        case PosAlign.right:
          bytes += [27, 97, 2]; // ESC a 2
          break;
        default:
          bytes += [27, 97, 0]; // ESC a 0
          break;
      }

      // 2. Negrito
      if (line.bold) {
        bytes += [27, 69, 1]; // ESC E 1
      } else {
        bytes += [27, 69, 0]; // ESC E 0
      }

      // 3. Tamanho da Fonte (GS ! n)
      if (line.doubleSize) {
        bytes += [29, 33, 17]; // GS ! 17 (Double size, width + height)
      } else {
        bytes += [29, 33, 0];  // GS ! 0 (Tamanho Normal)
      }

      // 4. Texto em Latin1 (CP1252/ISO-8859-1 para compatibilidade de acentuação)
      bytes += latin1.encode(line.text);
      bytes += [10]; // LF (Line Feed)
    }

    // Reseta configurações para o padrão
    bytes += [27, 97, 0]; // ESC a 0 (Esquerda)
    bytes += [27, 69, 0]; // ESC E 0 (Negrito OFF)
    bytes += [27, 77, 0]; // ESC M 0 (Fonte A)
    bytes += [29, 33, 0];  // GS ! 0 (Tamanho Normal)

    // Avanço de papel (Feed 3 linhas)
    bytes += [27, 100, 3]; // ESC d 3

    return bytes;
  }

  // Imprime uma vistoria formatada
  Future<bool> printVistoria(Vistoria vistoria, {String? technicianName}) async {
    try {
      // Garante que está conectado
      bool connected = await autoConnect();
      if (!connected) {
        debugPrint("Não foi possível conectar à impressora.");
        return false;
      }

      final bytes = buildReceiptBytes(vistoria, technicianName: technicianName);

      // Envia os bytes brutos para a impressora
      final bool success = await PrintBluetoothThermal.writeBytes(bytes);
      return success;
    } catch (e) {
      debugPrint("Erro ao imprimir vistoria: $e");
      return false;
    }
  }

  // Imprime lista de vistorias
  Future<int> printMultipleVistorias(List<Vistoria> list) async {
    if (list.isEmpty) return 0;
    
    bool connected = await autoConnect();
    if (!connected) return 0;

    int printedCount = 0;
    for (var vistoria in list) {
      final success = await printVistoria(vistoria);
      if (success) {
        printedCount++;
      }
      // Pequeno delay entre impressões para não sobrecarregar o buffer
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return printedCount;
  }
}
