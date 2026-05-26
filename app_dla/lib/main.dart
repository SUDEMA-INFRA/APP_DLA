import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importação do cofre
import 'pages/login.page.dart';
import 'pages/offline_selection.page.dart';
import 'pages/vistoria_form_page.dart';
import 'pages/vistoria_detail_page.dart';
import 'services/database_helper.dart';
import 'services/vistoria_service.dart';
import 'services/print_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega as variáveis do .env com tratamento de erro para evitar tela branca
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Erro ao carregar .env: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FisCon',
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
    if (kIsWeb) return; // Na web o listener de conectividade falha
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
// TELA HOME (Navegação por Abas + Dashboard Técnico)
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
  
  int _currentTabIndex = 0;
  bool _isOnline = false;
  String _searchText = '';
  String _selectedFilterType = 'Todos';

  // Controller para pesquisa no histórico
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    if (kIsWeb) {
      setState(() => _isOnline = true); // Web é assumido online pois roda no navegador
      return;
    }
    
    try {
      final results = await Connectivity().checkConnectivity();
      setState(() {
        _isOnline = results.any((r) => r != ConnectivityResult.none);
      });

      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
        if (mounted) {
          setState(() {
            _isOnline = results.any((r) => r != ConnectivityResult.none);
          });
        }
      });
    } catch (e) {
      setState(() => _isOnline = true); // Fallback caso dê erro de plataforma
    }
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

  // Abre a nossa página de formulários dinâmicos reais!
  Future<void> _createVistoria() async {
    if (_currentUser == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VistoriaFormPage(
          userId: _currentUser!['id'],
          cpf: _currentUser!['cpf'],
        ),
      ),
    );
    
    if (result == true) {
      _refreshVistorias();
    }
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  // Realiza a sincronização geral
  Future<void> _syncData() async {
    if (_currentUser == null) return;
    final cpf = _currentUser!['cpf'];

    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexão de rede ativa.'), backgroundColor: Colors.orange),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronizando dados...'), duration: Duration(seconds: 1)),
    );
    
    final upSuccess = await _vistoriaService.syncVistorias(cpf);
    final downSuccess = await _vistoriaService.syncDownVistorias(cpf);
    await _refreshVistorias();
    
    if (mounted) {
      if (upSuccess && downSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronização concluída com a SUDEMA! 🚀'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Houve falha na sincronia parcial.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printUnsynced(List<Vistoria> list) async {
    if (list.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.print_outlined, color: Color(0xFF70B324)),
              SizedBox(width: 8),
              Text('Imprimir Lote'),
            ],
          ),
          content: Text('Você tem ${list.length} vistorias pendentes locais. Deseja imprimi-las agora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF70B324), foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conectando à impressora térmica...'), duration: Duration(seconds: 1)),
      );

      final printService = PrintService.instance;
      final int printed = await printService.printMultipleVistorias(list);

      if (mounted) {
        if (printed > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$printed vistorias impressas com sucesso! 🖨️'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao imprimir. Verifique se a impressora está ativa.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF70B324);
    const darkBlue = Color(0xFF00509D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
            onPressed: _syncData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildDashboardTab(primaryGreen, darkBlue),
          _buildHistoryTab(primaryGreen),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentTabIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Vistorias',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createVistoria,
        backgroundColor: primaryGreen,
        tooltip: 'Nova Vistoria',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- ABA 1: Dashboard Principal ---
  Widget _buildDashboardTab(Color primaryGreen, Color darkBlue) {
    // Estatísticas locais em tempo real
    final total = _vistorias.length;
    final drafts = _vistorias.where((v) => (v.data['status'] ?? 'rascunho').toString() == 'rascunho').length;
    final pending = _vistorias.where((v) => (v.data['status'] ?? 'rascunho').toString() != 'rascunho' && !v.synced).length;
    final synced = _vistorias.where((v) => v.synced).length;
    final unsyncedList = _vistorias.where((v) => !v.synced).toList();

    return RefreshIndicator(
      onRefresh: _refreshVistorias,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Técnico e Rede
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF70B324)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser != null ? _currentUser!['nome'] : 'Carregando...',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          _currentUser != null ? 'CPF: ${_currentUser!['cpf']}' : '-',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: _isOnline ? Colors.green : Colors.red),
                        const SizedBox(width: 6),
                        Text(
                          _isOnline ? 'ONLINE' : 'OFFLINE',
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: _isOnline ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Seção Estatísticas
          const Text('Painel de Licenciamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00509D))),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatBox('Total Geral', total.toString(), Icons.folder_open_outlined, Colors.blue),
              _buildStatBox('Rascunhos Celular', drafts.toString(), Icons.edit_note_outlined, Colors.grey),
              _buildStatBox('Aguardando Conexão', pending.toString(), Icons.cloud_upload_outlined, Colors.orange),
              _buildStatBox('Sincronizados', synced.toString(), Icons.cloud_done_outlined, Colors.green),
            ],
          ),
          const SizedBox(height: 24),

          if (unsyncedList.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _printUnsynced(unsyncedList),
                icon: const Icon(Icons.print, color: Colors.white),
                label: Text(
                  'Imprimir Não Sincronizadas (${unsyncedList.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF70B324),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Card de Ajuda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined, color: Colors.orangeAccent),
                    SizedBox(width: 8),
                    Text('Informativo Técnico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'As vistorias salvas como Rascunho ficam somente no aparelho. Elas não são enviadas na sincronização. Certifique-se de preencher todos os dados e marcar a opção "Finalizar e Enviar" antes de sincronizar.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String val, IconData icon, Color col) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: col, size: 24),
            const Spacer(),
            Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: col)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // --- ABA 2: Histórico de Vistorias ---
  Widget _buildHistoryTab(Color primaryGreen) {
    // Filtra lista de vistorias com base na busca e filtros de categoria
    final filtered = _vistorias.where((v) {
      final matchesSearch = _searchText.isEmpty ||
          (v.data['processo_n']?.toString() ?? '').toLowerCase().contains(_searchText.toLowerCase()) ||
          (v.data['requerente']?.toString() ?? '').toLowerCase().contains(_searchText.toLowerCase());

      final matchesFilterType = _selectedFilterType == 'Todos' ||
          (v.data['tipo']?.toString() ?? '').toLowerCase() == _selectedFilterType.toLowerCase();

      return matchesSearch && matchesFilterType;
    }).toList();

    final List<String> chips = ['Todos', 'Supressão Vegetal', 'Avicultura', 'Suinocultura', 'Bovinocultura', 'Aquicultura', 'Atividades Agroindustriais', 'Agricultura'];

    return Column(
      children: [
        // Campo de Pesquisa
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchText = val),
            decoration: InputDecoration(
              labelText: 'Buscar por Processo ou Requerente',
              hintText: 'Digite o termo...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchText = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),

        // Filtros Rápidos (Chips Horizontais)
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: chips.length,
            itemBuilder: (context, index) {
              final active = _selectedFilterType == chips[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(chips[index], style: TextStyle(fontSize: 11, color: active ? Colors.white : Colors.black87)),
                  selected: active,
                  selectedColor: primaryGreen,
                  backgroundColor: Colors.white,
                  onSelected: (val) {
                    setState(() => _selectedFilterType = chips[index]);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Lista do Histórico
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshVistorias,
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('Nenhum relatório correspondente.')),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final v = filtered[index];
                      final d = v.data;
                      final isDraft = (d['status'] ?? 'rascunho').toString().toLowerCase() == 'rascunho';
                      final isSynced = v.synced;

                      Color leadingColor;
                      IconData leadingIcon;

                      if (isSynced) {
                        leadingColor = Colors.green;
                        leadingIcon = Icons.cloud_done;
                      } else if (!isDraft) {
                        leadingColor = Colors.orange;
                        leadingIcon = Icons.cloud_queue;
                      } else {
                        leadingColor = Colors.grey;
                        leadingIcon = Icons.edit_note;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        child: ListTile(
                          leading: Icon(leadingIcon, color: leadingColor, size: 28),
                          title: Text(
                            d['processo_n']?.toString() ?? 'Processo Não Informado',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Requerente: ${d['requerente'] ?? "-"}', style: const TextStyle(fontSize: 11)),
                              Text('Tipo: ${d['tipo'] ?? "-"}', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 18),
                          onTap: () async {
                            if (_currentUser == null) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistoriaDetailPage(
                                  vistoria: v,
                                  userId: _currentUser!['id'],
                                  cpf: _currentUser!['cpf'],
                                ),
                              ),
                            );
                            _refreshVistorias();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}