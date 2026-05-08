import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PinSetupPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PinSetupPage({super.key, required this.userData});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _savePin() async {
    if (_pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O PIN deve ter exatamente 4 dígitos')),
      );
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Os PINs não coincidem')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.saveUserLocally(widget.userData, _pinController.text);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar PIN: $e')),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security_rounded, size: 64, color: primaryGreen),
                  const SizedBox(height: 16),
                  const Text(
                    'Configurar PIN',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkBlue),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie um PIN para acessar o app offline com segurança.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dica: Sugerimos usar o dia e mês de seu nascimento (Ex: 1504 para 15 de abril).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: primaryGreen, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: _inputDecoration('Novo PIN (4 dígitos)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: _inputDecoration('Confirmar PIN'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Salvar e Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    const primaryGreen = Color(0xFF006b33);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe5e7eb))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFe5e7eb))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryGreen, width: 1.5)),
    );
  }
}
