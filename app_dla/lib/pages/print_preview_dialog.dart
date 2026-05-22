import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../services/print_service.dart';
import '../services/vistoria_service.dart';

class PrintPreviewDialog extends StatefulWidget {
  final Vistoria vistoria;

  const PrintPreviewDialog({
    super.key,
    required this.vistoria,
  });

  @override
  State<PrintPreviewDialog> createState() => _PrintPreviewDialogState();
}

class _PrintPreviewDialogState extends State<PrintPreviewDialog> {
  bool _printing = false;

  TextAlign _getTextAlign(PosAlign align) {
    switch (align) {
      case PosAlign.center:
        return TextAlign.center;
      case PosAlign.right:
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  Alignment _getAlignment(PosAlign align) {
    switch (align) {
      case PosAlign.center:
        return Alignment.center;
      case PosAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  Future<void> _handlePrint() async {
    setState(() {
      _printing = true;
    });

    final success = await PrintService.instance.printVistoria(widget.vistoria);

    if (mounted) {
      setState(() {
        _printing = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comprovante enviado para a impressora! 🖨️'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Erro de Impressão'),
              ],
            ),
            content: const Text(
              'Não foi possível se comunicar com a impressora.\n\n'
              '1. Verifique se o Bluetooth do celular está ligado.\n'
              '2. Verifique se a impressora térmica está ligada.\n'
              '3. Certifique-se de que a impressora está pareada nas configurações do Android.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = PrintService.instance.buildReceiptLines(widget.vistoria);
    const primaryGreen = Color(0xFF006b33);
    const paperBg = Color(0xFFfaf8f5); // Tom levemente amarelado de papel térmico

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho do Dialog
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.print_outlined, color: primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Pré-visualização do Ticket',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d1b3e),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // Informação de Bobina Fixa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Bobina de 58mm (Fonte Compacta - 42 colunas)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Cupom Simulado (Paper view)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: paperBg,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: lines.map((line) {
                        double fontSize = 9.0;
                        if (line.doubleSize) fontSize *= 1.5;

                        return Container(
                          alignment: _getAlignment(line.align),
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            line.text,
                            textAlign: _getTextAlign(line.align),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: fontSize,
                              fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
                              height: 1.15,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const Divider(height: 1),
          // Botões de Ação
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _printing ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _printing ? null : _handlePrint,
                    icon: _printing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.print_outlined),
                    label: Text(_printing ? 'Imprimindo...' : 'Imprimir'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
