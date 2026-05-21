import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'vistoria_service.dart';

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

  // Imprime uma vistoria formatada
  Future<bool> printVistoria(Vistoria vistoria) async {
    try {
      // Garante que está conectado
      bool connected = await autoConnect();
      if (!connected) {
        debugPrint("Não foi possível conectar à impressora.");
        return false;
      }

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Cabeçalho do Ticket
      bytes += generator.text('SUDEMA',
          styles: const PosStyles(align: PosAlign.center, bold: true, width: PosTextSize.size2, height: PosTextSize.size2));
      bytes += generator.text('Sup. de Administracao do Meio Ambiente',
          styles: const PosStyles(align: PosAlign.center, codeTable: 'CP1252'));
      bytes += generator.text('--------------------------------',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('COMPROVANTE DE VISTORIA',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      
      if (!vistoria.synced) {
        bytes += generator.text('* NAO SINCRONIZADO *',
            styles: const PosStyles(align: PosAlign.center, bold: true));
      }
      bytes += generator.text('--------------------------------',
          styles: const PosStyles(align: PosAlign.center));

      // Dados Gerais
      final Map<String, dynamic> data = vistoria.data;
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
      final dateStr = dateFormat.format(vistoria.createdAt);

      bytes += generator.text('Processo: ${data['processo_n'] ?? 'N/A'}',
          styles: const PosStyles(bold: true));
      bytes += generator.text('Requerente: ${data['requerente'] ?? 'N/A'}',
          styles: const PosStyles(codeTable: 'CP1252'));
      bytes += generator.text('Tipo: ${data['tipo'] ?? 'N/A'}',
          styles: const PosStyles(codeTable: 'CP1252'));
      bytes += generator.text('Data: $dateStr');
      bytes += generator.text('Lat: ${data['latitude'] ?? 'N/A'}');
      bytes += generator.text('Long: ${data['longitude'] ?? 'N/A'}');
      bytes += generator.text('--------------------------------',
          styles: const PosStyles(align: PosAlign.center));

      // Dados Específicos dependendo do tipo de vistoria
      final tipo = (data['tipo']?.toString() ?? '').toLowerCase();

      if (tipo.contains('supress') || tipo.contains('ambiental') || data.containsKey('supressao')) {
        final s = data['supressao'] ?? data;
        bytes += generator.text('DADOS DE SUPRESSAO VEGETAL',
            styles: const PosStyles(bold: true, align: PosAlign.center));
        bytes += generator.text('Curso d\'agua: ${s['tem_curso_dagua'] == true ? 'Sim' : 'Nao'}');
        bytes += generator.text('APP Preservada: ${s['app_preservada'] == true ? 'Sim' : 'Nao'}');
        bytes += generator.text('Bioma: ${s['bioma'] ?? 'N/A'}',
            styles: const PosStyles(codeTable: 'CP1252'));
        bytes += generator.text('Obs: ${s['observacoes'] ?? 'Nao informado'}',
            styles: const PosStyles(codeTable: 'CP1252'));

      } else if (tipo.contains('avicultura') || data.containsKey('avicultura')) {
        final a = data['avicultura'] ?? data;
        bytes += generator.text('DADOS DE AVICULTURA',
            styles: const PosStyles(bold: true, align: PosAlign.center));
        bytes += generator.text('Modelo: ${a['modelo'] ?? 'N/A'}',
            styles: const PosStyles(codeTable: 'CP1252'));
        bytes += generator.text('Criacao: ${a['tipo_criacao'] ?? 'N/A'}',
            styles: const PosStyles(codeTable: 'CP1252'));
        bytes += generator.text('Galpoes: ${a['qtd_galpoes'] ?? 'N/A'}');
        bytes += generator.text('Animais: ${a['qtd_animais'] ?? 'N/A'}');

      } else if (tipo.contains('suinocultura') || data.containsKey('suinocultura')) {
        final s = data['suinocultura'] ?? data;
        bytes += generator.text('DADOS DE SUINOCULTURA',
            styles: const PosStyles(bold: true, align: PosAlign.center));
        bytes += generator.text('Galpoes: ${s['qtd_galpoes'] ?? 'N/A'}');
        bytes += generator.text('Animais: ${s['qtd_animais'] ?? 'N/A'}');
        bytes += generator.text('Fase Prod.: ${s['fase_producao'] ?? 'N/A'}',
            styles: const PosStyles(codeTable: 'CP1252'));
      }

      bytes += generator.text('--------------------------------',
          styles: const PosStyles(align: PosAlign.center));

      // Rodapé
      bytes += generator.text('ID Local: ${vistoria.localId}',
          styles: const PosStyles(align: PosAlign.center, width: PosTextSize.size1, height: PosTextSize.size1));
      bytes += generator.text('Impresso em: ${dateFormat.format(DateTime.now())}',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(3);
      bytes += generator.cut();

      // Envia os bytes para a impressora
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
