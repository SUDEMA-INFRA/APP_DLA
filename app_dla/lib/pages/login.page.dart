import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'pin_setup.page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userData = await _authService.loginOnline(
          _cpfController.text, 
          _passwordController.text
        );

        if (userData != null) {
          final cpf = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
          
          // SEMPRE atualiza os dados locais (nome, email, etc) no login online
          await _authService.updateLocalUser(userData);
          
          final hasPin = await _authService.hasPin(cpf);

          if (mounted) {
            if (!hasPin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PinSetupPage(userData: userData)),
              );
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CPF ou senha inválidos'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          String errorMsg = 'Erro de conexão: Verifique sua internet ou a URL da API\n\nDetalhes: ${e.toString()}';
          if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
            errorMsg = 'Você está sem internet. Tente o "Entrar Offline".\n\nDetalhes: ${e.toString()}';
          } else if (e.toString().contains('Connection failed') || e.toString().contains('XMLHttpRequest')) {
            errorMsg = 'Servidor inacessível. Tente o "Entrar Offline" ou verifique sua conexão local.\n\nDetalhes: ${e.toString()}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.orange),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF70B324);
    const darkBlue = Color(0xFF00509D);

    return Scaffold(
      backgroundColor: const Color(0xFFf3f4f6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/EcoDataIcon.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                        children: [
                          TextSpan(text: 'Fis', style: TextStyle(color: darkBlue)),
                          TextSpan(text: 'Con', style: TextStyle(color: primaryGreen)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Acesso para técnicos de campo', style: TextStyle(fontSize: 14, color: Color(0xFF6b7280))),
                    const SizedBox(height: 32),
                    _buildLabel('CPF', darkBlue),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cpfController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        CpfInputFormatter(),
                      ],
                      decoration: _inputDecoration('Ex: 000.000.000-00'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite seu CPF';
                        }
                        final cleanCpf = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleanCpf.length < 11) {
                          return 'Digite o CPF completo (11 dígitos)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Senha', darkBlue),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _inputDecoration('••••••••').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Digite sua senha' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Entrar Online', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/offline-login'),
                      child: const Text('Entrar Offline', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe5e7eb))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe5e7eb))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF70B324), width: 1.5)),
    );
  }
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow numbers
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Cap at 11 digits
    final digits = text.substring(0, text.length > 11 ? 11 : text.length);
    
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
