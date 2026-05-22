import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../services/vistoria_service.dart';
import '../services/print_service.dart';

/// Modal de pré-visualização do ticket térmico.
/// Simula fielmente a saída de uma impressora térmica 58mm.
///
/// A impressora 58mm imprime:
///   - 32 caracteres por linha em width=size1
///   - 16 caracteres por linha em width=size2
///
/// O preview calcula o fontSize exato para que 32 chars monospace
/// preencham a largura do "papel" no preview, e pré-quebra as linhas
/// nos mesmos pontos que a impressora faria.
class PrintPreviewDialog extends StatelessWidget {
  final Vistoria vistoria;

  const PrintPreviewDialog({super.key, required this.vistoria});

  static Future<bool?> show(BuildContext context, Vistoria vistoria) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrintPreviewDialog(vistoria: vistoria),
    );
  }

  /// Chars por linha na impressora 58mm (32 colunas)
  static const int _charsPerLineSize1 = 32; // Font A (32 colunas)
  static const int _charsPerLineSize2 = 16; // Font A double-width (16 colunas)

  /// Padding interno do "papel"
  static const double _paperHPadding = 6.0;

  /// Quebra uma string longa em linhas de [maxChars] caracteres,
  /// exatamente como a impressora faz (quebra dura, sem word-wrap).
  List<String> _wrapText(String text, int maxChars) {
    if (text.length <= maxChars) return [text];
    final lines = <String>[];
    for (var i = 0; i < text.length; i += maxChars) {
      final end = (i + maxChars > text.length) ? text.length : i + maxChars;
      lines.add(text.substring(i, end));
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final printService = PrintService.instance;
    final lines = printService.buildReceiptLines(vistoria);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // --- Handle bar ---
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // --- Title bar ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.grey.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pré-visualização do Comprovante',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e293b),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // --- Ticket preview ---
              Expanded(
                child: Container(
                  color: const Color(0xFFE8E8E0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Largura do papel = largura da tela - margens externas
                      final paperWidth = constraints.maxWidth - 32;
                      final contentWidth = paperWidth - (_paperHPadding * 2);

                      // Calcula o fontSize base medindo quantos px um char monospace ocupa.
                      // Para fonte monospace, cada char ocupa ~0.6 * fontSize.
                      // 32 chars * 0.6 * fontSize = contentWidth
                      // fontSize = contentWidth / (32 * 0.6)
                      final baseFontSize = contentWidth / (_charsPerLineSize1 * 0.6);
                      final doubleWidthFontSize = contentWidth / (_charsPerLineSize2 * 0.6);

                      return SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Center(
                          child: Container(
                            width: paperWidth,
                            padding: EdgeInsets.symmetric(
                              horizontal: _paperHPadding,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFF5),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildAllLines(lines, baseFontSize, doubleWidthFontSize),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // --- Action buttons ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Imprimir', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006b33),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Constrói todas as linhas do ticket com pré-quebra nos limites da impressora.
  List<Widget> _buildAllLines(
    List<ReceiptLine> lines,
    double baseFontSize,
    double doubleWidthFontSize,
  ) {
    final widgets = <Widget>[];

    for (final line in lines) {
      final text = line.text;
      final bold = line.bold;
      final align = line.align;
      final doubleSize = line.doubleSize;

      // Determina chars por linha e fontSize conforme o mapeamento ESC/POS
      double fontSize = doubleSize ? doubleWidthFontSize : baseFontSize;
      double lineHeight = doubleSize ? 1.4 : 1.2;

      widgets.add(
        Text(
          text,
          textAlign: align == PosAlign.center
              ? TextAlign.center
              : (align == PosAlign.right ? TextAlign.right : TextAlign.left),
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
            color: const Color(0xFF1a1a1a),
            height: lineHeight,
            letterSpacing: 0,
          ),
        ),
      );
    }

    return widgets;
  }
}
