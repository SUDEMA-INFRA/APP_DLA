import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importação do cofre
import 'package:app_dla/pages/login.page.dart';
import 'package:app_dla/pages/offline_selection.page.dart';
import 'package:app_dla/pages/pin_setup.page.dart';
import 'package:app_dla/services/database_helper.dart';
import 'package:app_dla/services/vistoria_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega as variáveis o .env
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP DLA',
      theme: ThemeData(
        // Correção de sintaxe: Adicionado "ColorScheme" antes de ".fromSeed"
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Aqui nós tiramos o LoginPage fixo e colocamos o nosso "Porteiro"
      home: const AuthCheck(),
      // Mapeamento das rotas para o Navigator.pushReplacementNamed funcionar
      routes: {
        '/login': (context) => const LoginPage(),
        '/offline-login': (context) => const OfflineSelectionPage(),
        '/home': (context) => const MyHomePage(title: 'Página Inicial'),
      },
    );
  }
}

// =========================================================================
// O "PORTEIRO" (AuthCheck): Decide se o usuário vai para o Login ou Home
// =========================================================================
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final _storage = const FlutterSecureStorage();
  final _vistoriaService = VistoriaService();

  @override
  void initState() {
    super.initState();
    _verificarToken();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      if (results.any((r) => r != ConnectivityResult.none)) {
        debugPrint("Internet detectada! Sincronizando...");
        
        final cpf = await _storage.read(key: 'current_cpf');
        if (cpf != null) {
          _vistoriaService.syncVistorias(cpf);
          _vistoriaService.syncDownVistorias(cpf);
        }
      }
    });
  }

  Future<void> _verificarToken() async {
    // Busca o token no cofre seguro
    String? token = await _storage.read(key: 'jwt_token');

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (token != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto ele verifica o token no initState, mostra um carregamento centralizado
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// =========================================================================
// TELA HOME (Seu código original do contador)
// =========================================================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _vistoriaService = VistoriaService();
  List<Vistoria> _vistorias = [];
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DatabaseHelper.instance.database;
    final users = await db.query('users_local', orderBy: 'last_login DESC', limit: 1);
    if (users.isNotEmpty) {
      setState(() => _currentUser = users.first);
      _refreshVistorias();
    }
  }

  Future<void> _refreshVistorias() async {
    if (_currentUser == null) return;
    final list = await _vistoriaService.getLocalVistorias(_currentUser!['id']);
    setState(() => _vistorias = list);
  }

  Future<void> _createVistoria() async {
    if (_currentUser == null) return;
    
    // Simula uma nova vistoria
    await _vistoriaService.createVistoria({
      'tipo': 'Ambiental',
      'latitude': -7.115,
      'longitude': -34.863,
      'observacao': 'Vistoria de rotina realizada.',
    }, _currentUser!['id'], _currentUser!['cpf']);
    
    _refreshVistorias();
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF006b33);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              if (_currentUser == null) return;
              final cpf = _currentUser!['cpf'];

              final connectivity = await Connectivity().checkConnectivity();
              if (connectivity.any((r) => r == ConnectivityResult.none)) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sem internet para sincronizar.'), backgroundColor: Colors.orange),
                  );
                }
                return;
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronizando dados...'), duration: Duration(seconds: 1)),
                );
              }
              
              final upSuccess = await _vistoriaService.syncVistorias(cpf);
              final downSuccess = await _vistoriaService.syncDownVistorias(cpf);
              await _refreshVistorias();
              
              if (mounted) {
                if (upSuccess && downSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronização concluída!'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro na sincronia. Pode ser necessário login online recente.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentUser != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  const Icon(Icons.person, color: primaryGreen),
                  const SizedBox(width: 8),
                  Text('Bem-vindo, ${_currentUser!['nome']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Suas Vistorias Recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: _vistorias.isEmpty
                ? const Center(child: Text('Nenhuma vistoria encontrada.'))
                : ListView.builder(
                    itemCount: _vistorias.length,
                    itemBuilder: (context, index) {
                      final v = _vistorias[index];
                      return ListTile(
                        leading: Icon(
                          v.synced ? Icons.cloud_done : Icons.cloud_off,
                          color: v.synced ? Colors.green : Colors.orange,
                        ),
                        title: Text('Vistoria ${v.localId.substring(0, 8)}'),
                        subtitle: Text(v.createdAt.toLocal().toString()),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createVistoria,
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}