import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite/sqflite.dart';
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

  Future<http.Response> _sendVistoria(Vistoria v, String token) {
    return http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'local_id': v.localId,
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
