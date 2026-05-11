import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'auth_service.dart';

class Vistoria {
  final int? id;
  final String localId;
  final int userId;
  final Map<String, dynamic> data;
  final bool synced;
  final DateTime createdAt;

  Vistoria({
    this.id,
    required this.localId,
    required this.userId,
    required this.data,
    this.synced = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'local_id': localId,
      'user_id': userId,
      'data': jsonEncode(data),
      'synced': synced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Vistoria.fromMap(Map<String, dynamic> map) {
    return Vistoria(
      id: map['id'],
      localId: map['local_id'],
      userId: map['user_id'],
      data: jsonDecode(map['data']),
      synced: map['synced'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class VistoriaService {
  final _dbHelper = DatabaseHelper.instance;
  final _authService = AuthService();
  final String apiUrl = '${dotenv.env['API_URL']}vistorias/';

  // Cria uma nova vistoria localmente
  Future<void> createVistoria(Map<String, dynamic> data, int userId, String cpf) async {
    final db = await _dbHelper.database;
    final vistoria = Vistoria(
      localId: const Uuid().v4(),
      userId: userId,
      data: data,
      createdAt: DateTime.now(),
    );

    await db.insert('vistorias_local', vistoria.toMap());
    
    // Tenta sincronizar imediatamente se houver internet
    syncVistorias(cpf);
  }

  // Busca vistorias locais do usuário
  Future<List<Vistoria>> getLocalVistorias(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'vistorias_local',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Vistoria.fromMap(m)).toList();
  }

  // Exclui uma vistoria localmente
  Future<void> deleteLocalVistoria(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'vistorias_local',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sincroniza vistorias pendentes com o servidor
  Future<bool> syncVistorias(String cpf) async {
    final db = await _dbHelper.database;
    String? token = await _authService.getToken(cpf);
    if (token == null) return false;

    final pending = await db.query('vistorias_local', where: 'synced = 0');
    if (pending.isEmpty) return true;

    bool success = true;
    for (var map in pending) {
      final vistoria = Vistoria.fromMap(map);
      
      // 1. Pula vistorias em status de rascunho (rascunhos só existem localmente no celular)
      final status = (vistoria.data['status'] ?? 'rascunho').toString().toLowerCase();
      if (status == 'rascunho') {
        continue;
      }

      // 2. Segurança de integridade: Só sincroniza se todos os campos daquele tipo estiverem preenchidos!
      if (!_isVistoriaComplete(vistoria.data)) {
        continue;
      }

      try {
        var response = await _sendVistoria(vistoria, token!);
        
        // Se o token expirou (401), tenta renovar uma vez
        if (response.statusCode == 401) {
          token = await _authService.refreshToken(cpf);
          if (token != null) {
            response = await _sendVistoria(vistoria, token!);
          }
        }

        if (response.statusCode == 201 || response.statusCode == 200) {
          await db.update('vistorias_local', {'synced': 1}, where: 'id = ?', whereArgs: [vistoria.id]);
        } else {
          success = false;
        }
      } catch (e) {
        success = false;
      }
    }
    return success;
  }

  // Validador de integridade local para garantir dados de vistoria completos no servidor
  bool _isVistoriaComplete(Map<String, dynamic> data) {
    // 1. Campos obrigatórios básicos (comuns a qualquer vistoria)
    if (data['processo_n'] == null || data['processo_n'].toString().trim().isEmpty || data['processo_n'].toString() == 'string') {
      return false;
    }
    if (data['requerente'] == null || data['requerente'].toString().trim().isEmpty || data['requerente'].toString() == 'string') {
      return false;
    }
    if (data['latitude'] == null || data['latitude'] == 0 || data['latitude'] == 0.0) {
      return false;
    }
    if (data['longitude'] == null || data['longitude'] == 0 || data['longitude'] == 0.0) {
      return false;
    }

    // 2. Campos específicos de acordo com a modalidade (tipo) da vistoria
    final tipo = data['tipo']?.toString().toLowerCase() ?? '';
    
    if (tipo.contains('supressão') || tipo.contains('ambiental') || data.containsKey('supressao')) {
      final s = data['supressao'] ?? data;
      if (s['tem_curso_dagua'] == null) return false;
      if (s['app_preservada'] == null) return false;
      if (s['bioma'] == null || s['bioma'].toString().trim().isEmpty) return false;
      if (s['observacoes'] == null || s['observacoes'].toString().trim().isEmpty) return false;
    } else if (tipo.contains('avicultura') || data.containsKey('avicultura')) {
      final a = data['avicultura'] ?? data;
      if (a['modelo'] == null || a['modelo'].toString().trim().isEmpty) return false;
      if (a['tipo_criacao'] == null || a['tipo_criacao'].toString().trim().isEmpty) return false;
      if (a['qtd_animais'] == null || a['qtd_animais'] == 0) return false;
      if (a['qtd_galpoes'] == null || a['qtd_galpoes'] == 0) return false;
    } else if (tipo.contains('suinocultura') || data.containsKey('suinocultura')) {
      final s = data['suinocultura'] ?? data;
      if (s['qtd_galpoes'] == null || s['qtd_galpoes'] == 0) return false;
      if (s['qtd_animais'] == null || s['qtd_animais'] == 0) return false;
      if (s['fase_producao'] == null || s['fase_producao'].toString().trim().isEmpty) return false;
    }
    
    return true;
  }

  Future<http.Response> _sendVistoria(Vistoria v, String token) async {
    String deviceName = 'Desconhecido';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceName = windowsInfo.computerName;
      } else {
        deviceName = Platform.operatingSystem;
      }
    } catch (e) {
      deviceName = Platform.operatingSystem;
    }

    return http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'local_id': v.localId,
        'device': deviceName,
        'data': v.data,
        'created_at': v.createdAt.toIso8601String(),
      }),
    ).timeout(const Duration(seconds: 10));
  }

  // Sincronização de DOWNLOAD
  Future<bool> syncDownVistorias(String cpf) async {
    final db = await _dbHelper.database;
    String? token = await _authService.getToken(cpf);
    if (token == null) return false;

    try {
      var response = await http.get(Uri.parse(apiUrl), headers: {'Authorization': 'Bearer $token'});
      
      if (response.statusCode == 401) {
        token = await _authService.refreshToken(cpf);
        if (token != null) {
          response = await http.get(Uri.parse(apiUrl), headers: {'Authorization': 'Bearer $token'});
        }
      }

      if (response.statusCode == 200) {
        final List<dynamic> remoteData = jsonDecode(response.body);
        for (var item in remoteData) {
          await db.insert(
            'vistorias_local',
            {
              'local_id': item['local_id'],
              'user_id': item['user'],
              'data': jsonEncode(item['data']),
              'synced': 1,
              'created_at': item['created_at'],
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        return true;
      }
    } catch (e) {
      print('Erro no sync down: $e');
    }
    return false;
  }
}
