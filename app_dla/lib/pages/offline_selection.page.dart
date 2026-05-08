import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OfflineSelectionPage extends StatefulWidget {
  const OfflineSelectionPage({super.key});

  @override
  State<OfflineSelectionPage> createState() => _OfflineSelectionPageState();
}

class _OfflineSelectionPageState extends State<OfflineSelectionPage> {
  final _authService = AuthService();
  List<Map<String, dynamic>> _localUsers = [];
  Map<String, dynamic>? _selectedUser;
  final _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _authService.getLocalUsers();
    setState(() => _localUsers = users);
  }

  Future<void> _verifyPin() async {
    if (_selectedUser == null) return;
    
    setState(() => _isLoading = true);
    try {
      final success = await _authService.verifyPinOffline(
        _selectedUser!['cpf'], 
        _pinController.text
      );

      if (success) {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN incorreto'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF006b33);
    const darkBlue = Color(0xFF0d1b3e);

    return Scaffold(
      backgroundColor: const Color(0xFFf3f4f6),
      appBar: AppBar(
        title: const Text('Entrar Offline'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkBlue,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedUser == null) ...[
                const Text('Selecione um perfil para entrar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _localUsers.length,
                    itemBuilder: (context, index) {
                      final user = _localUsers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: primaryGreen, child: Icon(Icons.person, color: Colors.white)),
                          title: Text(user['nome']),
                          subtitle: Text('CPF: ${user['cpf']}'),
                          onTap: () => setState(() => _selectedUser = user),
                        ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar para Login Online'),
                ),
              ] else ...[
                const Icon(Icons.lock_outline, size: 64, color: primaryGreen),
                const SizedBox(height: 16),
                Text(_selectedUser!['nome'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Digite seu PIN para acessar:', style: TextStyle(color: Color(0xFF6b7280))),
                const SizedBox(height: 32),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 16),
                  decoration: InputDecoration(
                    hintText: '••••',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPin,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white),
                    child: const Text('Entrar'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedUser = null),
                  child: const Text('Trocar Usuário'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
