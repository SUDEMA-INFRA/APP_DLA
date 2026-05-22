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
  List<ReceiptLine> buildReceiptLines(Vistoria vistoria) {
    final List<ReceiptLine> lines = [];
    const int cols = 42;
    final String separator = '-' * cols;
    final String doubleSeparator = '=' * cols;

    void addLine(String text, {PosAlign align = PosAlign.left, bool bold = false, bool doubleSize = false}) {
      final int limit = doubleSize ? 21 : 42;
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
    addLine('Tipo: ${data['tipo'] ?? 'N/A'}');
    addLine('Data: $dateStr');
    addLine('Lat: ${data['latitude'] ?? 'N/A'}');
    addLine('Long: ${data['longitude'] ?? 'N/A'}');
    addLine(separator, align: PosAlign.center);

    // Dados Específicos dependendo do tipo de vistoria
    final tipo = (data['tipo']?.toString() ?? '').toLowerCase();

    if (tipo.contains('supress') || tipo.contains('ambiental') || data.containsKey('supressao')) {
      final s = data['supressao'] ?? data;
      addLine('DADOS DE SUPRESSAO VEGETAL', bold: true, align: PosAlign.center);
      addLine('Curso d\'agua: ${s['tem_curso_dagua'] == true ? 'Sim' : 'Nao'}');
      addLine('APP Preservada: ${s['app_preservada'] == true ? 'Sim' : 'Nao'}');
      addLine('Bioma: ${s['bioma'] ?? 'N/A'}');
      addLine('Obs: ${s['observacoes'] ?? 'Nao informado'}');

    } else if (tipo.contains('avicultura') || data.containsKey('avicultura')) {
      final a = data['avicultura'] ?? data;
      addLine('DADOS DE AVICULTURA', bold: true, align: PosAlign.center);
      addLine('Modelo: ${a['modelo'] ?? 'N/A'}');
      addLine('Criacao: ${a['tipo_criacao'] ?? 'N/A'}');
      addLine('Galpoes: ${a['qtd_galpoes'] ?? 'N/A'}');
      addLine('Animais: ${a['qtd_animais'] ?? 'N/A'}');

    } else if (tipo.contains('suinocultura') || data.containsKey('suinocultura')) {
      final s = data['suinocultura'] ?? data;
      addLine('DADOS DE SUINOCULTURA', bold: true, align: PosAlign.center);
      addLine('Galpoes: ${s['qtd_galpoes'] ?? 'N/A'}');
      addLine('Animais: ${s['qtd_animais'] ?? 'N/A'}');
      addLine('Fase Prod.: ${s['fase_producao'] ?? 'N/A'}');

    } else if (tipo.contains('bovinocultura') || data.containsKey('bovinocultura')) {
      final b = data['bovinocultura'] ?? data;
      addLine('DADOS DE BOVINOCULTURA', bold: true, align: PosAlign.center);
      addLine('Modelo: ${b['modelo'] ?? 'N/A'}');
      addLine('Area (Ha): ${b['area_ha'] ?? 'N/A'}');
      addLine('Dessedentacao: ${b['dessedentacao'] ?? 'N/A'}');

    } else if (tipo.contains('aquicultura') || data.containsKey('aquicultura')) {
      final aq = data['aquicultura'] ?? data;
      addLine('DADOS DE AQUICULTURA', bold: true, align: PosAlign.center);
      addLine('Tanques: ${aq['qtd_tanques'] ?? 'N/A'}');
      addLine('Hidrometro: ${aq['hidrometro'] == true ? 'Sim' : 'Nao'}');
      addLine('Outorga: ${aq['outorga'] == true ? 'Sim' : 'Nao'}');
      addLine('Fonte de Agua: ${aq['fonte_agua'] ?? 'N/A'}');

    } else if (tipo.contains('sucroalcooleiro') || data.containsKey('sucroalcooleiro')) {
      final su = data['sucroalcooleiro'] ?? data;
      addLine('DADOS DE SUCROALCOOLEIRO', bold: true, align: PosAlign.center);
      addLine('Residuos Solidos: ${su['residuos_solidos'] ?? 'N/A'}');
      addLine('Destinacao Bagaco: ${su['bagaco'] ?? 'N/A'}');
      addLine('Equip. Conformes: ${su['equipamentos_conformes'] != false ? 'Sim' : 'Nao'}');
      addLine('Armazenamento OK: ${su['armazenamento_ok'] != false ? 'Sim' : 'Nao'}');

    } else if (tipo.contains('agricultura') || data.containsKey('agricultura')) {
      final ag = data['agricultura'] ?? data;
      addLine('DADOS DE AGRICULTURA', bold: true, align: PosAlign.center);
      addLine('Cultivo: ${ag['cultivo'] ?? 'N/A'}');
      addLine('Cursos Hidricos: ${ag['cursos_hidricos_entorno'] ?? 'N/A'}');
      addLine('Agrotoxicos: ${ag['agrotoxicos'] ?? 'N/A'}');
    }

    addLine(doubleSeparator, align: PosAlign.center);

    // Rodapé
    addLine('ID Local: ${vistoria.localId}', align: PosAlign.center);
    addLine('Impresso em:', align: PosAlign.center);
    addLine(dateFormat.format(DateTime.now()), align: PosAlign.center);

    return lines;
  }

  // Gera os bytes ESC/POS brutos a partir das ReceiptLine
  List<int> buildReceiptBytes(Vistoria vistoria) {
    List<int> bytes = [];

    // Inicialização da impressora (Zera configurações anteriores)
    bytes += [27, 64]; // ESC @
    // Configura a impressora para usar a Fonte B (Fonte compacta/tamanho menor 9x17)
    bytes += [27, 77, 1]; // ESC M 1

    final lines = buildReceiptLines(vistoria);

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
  Future<bool> printVistoria(Vistoria vistoria) async {
    try {
      // Garante que está conectado
      bool connected = await autoConnect();
      if (!connected) {
        debugPrint("Não foi possível conectar à impressora.");
        return false;
      }

      final bytes = buildReceiptBytes(vistoria);

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
