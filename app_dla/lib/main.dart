import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importação do cofre
import 'package:app_dla/pages/login.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega as variáveis do .env
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

  @override
  void initState() {
    super.initState();
    _verificarToken();
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // Correção de sintaxe: Adicionado "MainAxisAlignment" antes de ".center"
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}