import 'package:flutter/material.dart';
import '../services/vistoria_service.dart';
import 'vistoria_form_page.dart';
import '../utils/municipios.dart';

class VistoriaDetailPage extends StatefulWidget {
  final Vistoria vistoria;
  final int userId;
  final String cpf;

  const VistoriaDetailPage({
    super.key,
    required this.vistoria,
    required this.userId,
    required this.cpf,
  });

  @override
  State<VistoriaDetailPage> createState() => _VistoriaDetailPageState();
}

class _VistoriaDetailPageState extends State<VistoriaDetailPage> {
  late Vistoria _currentVistoria;

  @override
  void initState() {
    super.initState();
    _currentVistoria = widget.vistoria;
  }

  String _getMunicipioNome(int? id) {
    return Municipios.getName(id);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Excluir Relatório?'),
          ],
        ),
        content: const Text(
          'Esta ação removerá esta vistoria localmente do seu celular. Esta exclusão não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final service = VistoriaService();
      await service.deleteLocalVistoria(_currentVistoria.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vistoria excluída localmente! 🗑️'),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pop(context, true); // Retorna true para a listagem recarregar!
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _currentVistoria.data;
    final status = (d['status'] ?? 'rascunho').toString().toLowerCase();
    final isDraft = status == 'rascunho';
    final isSynced = _currentVistoria.synced;

    const primaryGreen = Color(0xFF006b33);
    const darkBlue = Color(0xFF0d1b3e);

    return Scaffold(
      backgroundColor: const Color(0xFFf3f4f6),
      appBar: AppBar(
        title: const Text('Detalhamento da Vistoria'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          // Permite editar se for rascunho
          if (isDraft && !isSynced)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Vistoria',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VistoriaFormPage(
                      userId: widget.userId,
                      cpf: widget.cpf,
                      existingVistoria: _currentVistoria,
                    ),
                  ),
                );
                if (result == true) {
                  // Se o rascunho mudou, recarrega
                  final service = VistoriaService();
                  final updatedList = await service.getLocalVistorias(widget.userId);
                  final updatedItem = updatedList.firstWhere((item) => item.id == _currentVistoria.id);
                  setState(() {
                    _currentVistoria = updatedItem;
                  });
                }
              },
            ),
          // Permite deletar localmente qualquer vistoria
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Deletar Localmente',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card de Status
          _buildStatusCard(isSynced, isDraft),
          const SizedBox(height: 16),

          // Seção 1: Dados Gerais
          _buildCard(
            title: 'Informações Gerais',
            icon: Icons.info_outline,
            iconColor: darkBlue,
            children: [
              _buildRow('Número do Processo', d['processo_n']?.toString() ?? 'Não informado'),
              _buildRow('Requerente', d['requerente']?.toString() ?? 'Não informado'),
              _buildRow('Município', _getMunicipioNome(d['municipio'] is int ? d['municipio'] : int.tryParse(d['municipio']?.toString() ?? ''))),
              _buildRow('Data de Criação', _currentVistoria.createdAt.toLocal().toString().substring(0, 16)),
            ],
          ),
          const SizedBox(height: 16),

          // Seção 2: Geolocalização
          _buildCard(
            title: 'Geolocalização (Campo)',
            icon: Icons.map_outlined,
            iconColor: Colors.redAccent,
            children: [
              _buildRow('Latitude', d['latitude']?.toString() ?? 'Não georreferenciada'),
              _buildRow('Longitude', d['longitude']?.toString() ?? 'Não georreferenciada'),
            ],
          ),
          const SizedBox(height: 16),

          // Seção 3: Dados Específicos por Tipo
          _buildSpecificDataCard(d),
          const SizedBox(height: 24),

          // Alerta se estiver bloqueado
          if (!isDraft || isSynced)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.blue.shade800),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Este relatório está finalizado ou sincronizado e foi bloqueado para modificações no aparelho.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isSynced, bool isDraft) {
    Color cardColor;
    Color textColor;
    IconData icon;
    String statusTitle;
    String statusDesc;

    if (isSynced) {
      cardColor = Colors.green.shade50;
      textColor = const Color(0xFF006b33);
      icon = Icons.cloud_done_outlined;
      statusTitle = 'Sincronizado na SUDEMA';
      statusDesc = 'Esta vistoria já foi enviada e registrada no banco de dados oficial.';
    } else if (!isDraft) {
      cardColor = Colors.amber.shade50;
      textColor = Colors.amber.shade900;
      icon = Icons.cloud_upload_outlined;
      statusTitle = 'Pronto para Sincronização';
      statusDesc = 'Relatório concluído. Aguardando conexão à internet para transmissão automática.';
    } else {
      cardColor = Colors.grey.shade100;
      textColor = Colors.grey.shade800;
      icon = Icons.edit_note_outlined;
      statusTitle = 'Rascunho Local';
      statusDesc = 'Salvo apenas no dispositivo. Preencha todos os campos para habilitar o envio.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: textColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDesc,
                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0d1b3e)),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificDataCard(Map<String, dynamic> d) {
    final tipo = d['tipo']?.toString() ?? 'Não especificado';

    if (tipo == 'Supressão Vegetal') {
      final s = d['supressao'] ?? d;
      return _buildCard(
        title: 'Especificações: Supressão Vegetal',
        icon: Icons.forest_outlined,
        iconColor: Colors.green,
        children: [
          _buildRow('Curso d\'água?', s['tem_curso_dagua'] == true ? 'Sim' : 'Não'),
          _buildRow('APP Preservada?', s['app_preservada'] == true ? 'Sim' : 'Não'),
          _buildRow('Bioma', s['bioma']?.toString() ?? 'Não informado'),
          _buildRow('Parecer Técnico', s['observacoes']?.toString() ?? 'Não informado'),
        ],
      );
    } else if (tipo == 'Avicultura') {
      final a = d['avicultura'] ?? d;
      return _buildCard(
        title: 'Especificações: Avicultura',
        icon: Icons.egg_outlined,
        iconColor: Colors.amber.shade700,
        children: [
          _buildRow('Modelo do Galpão', a['modelo']?.toString() ?? 'Não informado'),
          _buildRow('Tipo de Criação', a['tipo_criacao']?.toString() ?? 'Não informado'),
          _buildRow('Quantidade de Aves', a['qtd_animais']?.toString() ?? 'Não informado'),
          _buildRow('Quantidade de Galpões', a['qtd_galpoes']?.toString() ?? 'Não informado'),
        ],
      );
    } else if (tipo == 'Suinocultura') {
      final s = d['suinocultura'] ?? d;
      return _buildCard(
        title: 'Especificações: Suinocultura',
        icon: Icons.animation_outlined,
        iconColor: Colors.pink,
        children: [
          _buildRow('Quantidade de Galpões', s['qtd_galpoes']?.toString() ?? 'Não informado'),
          _buildRow('Quantidade de Animais', s['qtd_animais']?.toString() ?? 'Não informado'),
          _buildRow('Fase de Produção', s['fase_producao']?.toString() ?? 'Não informado'),
        ],
      );
    } else {
      return _buildCard(
        title: 'Licenciamento Simplificado',
        icon: Icons.assignment_outlined,
        iconColor: Colors.grey,
        children: [
          _buildRow('Modalidade', tipo),
          const SizedBox(height: 4),
          const Text(
            'Utiliza modelo simplificado de vistorias SUDEMA.',
            style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
          )
        ],
      );
    }
  }
}
