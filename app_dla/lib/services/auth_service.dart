import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String apiUrl = '${dotenv.env['API_URL']}'; 
  
  // Instância do cofre seguro
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Função para fazer o Login na API
  Future<bool> login(String cpf, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cpf': cpf,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['access'] ?? data['token']; 
        await _storage.write(key: 'jwt_token', value: token);
        return true; 
      } else {
        return false; 
      }
    } catch (e) {
      return false; 
    }
  }

  // Função para ler o token salvo (usada para saber se o usuário já está logado)
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Função de Logout (apaga o token do cofre e o banco local, se desejar)
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    // Dica: Aqui você também chamaria um método para limpar o banco Sqflite (LocalDatabase)
    // para que outro usuário não veja os dados offline do usuário anterior.
  }
}