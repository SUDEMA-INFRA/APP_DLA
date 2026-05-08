import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class AuthService {
  final String apiUrl = '${dotenv.env['API_URL']}';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Atualiza apenas as informações básicas (chamado em todo login online de sucesso)
  Future<void> updateLocalUser(Map<String, dynamic> userData) async {
    final db = await _dbHelper.database;
    final user = userData['user'];
    
    final firstName = user['first_name'] ?? '';
    final lastName = user['last_name'] ?? '';
    final fullName = "$firstName $lastName".trim();

    await db.insert(
      'users_local',
      {
        'id': user['id'],
        'cpf': user['cpf'],
        'nome': fullName.isEmpty ? 'Usuário' : fullName,
        'email': user['email'],
        'last_login': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Realiza login online e retorna os dados se sucesso
  Future<Map<String, dynamic>?> loginOnline(String cpf, String password) async {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cpf': cleanCpf,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Salva tokens vinculados ao CPF
        await _storage.write(key: 'jwt_token_$cleanCpf', value: data['access']);
        await _storage.write(key: 'refresh_token_$cleanCpf', value: data['refresh']);
        
        // Também salva como "global" para o usuário atual
        await _storage.write(key: 'current_cpf', value: cleanCpf);
        
        return data;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Tenta renovar o token de um usuário
  Future<String?> refreshToken(String cpf) async {
    final refreshToken = await _storage.read(key: 'refresh_token_$cpf');
    if (refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse('${apiUrl}auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token_$cpf', value: data['access']);
        return data['access'];
      }
    } catch (e) {
      print('Erro ao renovar token: $e');
    }
    return null;
  }

  Future<String?> getToken(String cpf) async {
    return await _storage.read(key: 'jwt_token_$cpf');
  }

  Future<void> logout() async {
    final cpf = await _storage.read(key: 'current_cpf');
    if (cpf != null) {
      await _storage.delete(key: 'jwt_token_$cpf');
      await _storage.delete(key: 'refresh_token_$cpf');
    }
    await _storage.delete(key: 'current_cpf');
  }

  // Salva o usuário e o hash do PIN localmente
  Future<void> saveUserLocally(Map<String, dynamic> userData, String pin) async {
    final db = await _dbHelper.database;
    final cpf = userData['user']['cpf'];
    
    final user = userData['user'];
    final firstName = user['first_name'] ?? '';
    final lastName = user['last_name'] ?? '';
    final fullName = "$firstName $lastName".trim();

    await db.insert(
      'users_local',
      {
        'id': user['id'],
        'cpf': cpf,
        'nome': fullName.isEmpty ? 'Usuário' : fullName,
        'email': user['email'],
        'last_login': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final pinHash = sha256.convert(utf8.encode(pin)).toString();
    await _storage.write(key: 'pin_hash_$cpf', value: pinHash);
    await _storage.write(key: 'pin_attempts_$cpf', value: '0');
  }

  Future<bool> hasPin(String cpf) async {
    final hash = await _storage.read(key: 'pin_hash_$cpf');
    return hash != null;
  }

  Future<bool> verifyPinOffline(String cpf, String pin) async {
    final storedHash = await _storage.read(key: 'pin_hash_$cpf');
    if (storedHash == null) return false;

    final attemptsStr = await _storage.read(key: 'pin_attempts_$cpf') ?? '0';
    int attempts = int.parse(attemptsStr);
    
    if (attempts >= 5) {
      throw Exception('Limite de tentativas excedido. Faça login online.');
    }

    final inputHash = sha256.convert(utf8.encode(pin)).toString();
    
    if (storedHash == inputHash) {
      await _storage.write(key: 'pin_attempts_$cpf', value: '0');
      // Salva como usuário atual para sincronização posterior
      await _storage.write(key: 'current_cpf', value: cpf);
      return true;
    } else {
      attempts++;
      await _storage.write(key: 'pin_attempts_$cpf', value: attempts.toString());
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLocalUsers() async {
    final db = await _dbHelper.database;
    return await db.query('users_local', orderBy: 'last_login DESC');
  }
}