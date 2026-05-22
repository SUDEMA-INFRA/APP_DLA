import 'package:flutter/material.dart';
import '../services/vistoria_service.dart';
import 'vistoria_form_page.dart';
import '../utils/municipios.dart';
import '../services/print_service.dart';
import '../widgets/print_preview_dialog.dart';

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

  Future<void> _printComprovante(BuildContext context) async {
    // Abre a pré-visualização e espera confirmação
    final shouldPrint = await PrintPreviewDialog.show(context, _currentVistoria);

    if (shouldPrint != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conectando à impressora térmica... 🖨️'),
        duration: Duration(seconds: 2),
      ),
    );

    final success = await PrintService.instance.printVistoria(_currentVistoria);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comprovante impresso com sucesso! 🖨️'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao imprimir. Verifique a impressora.'),
            backgroundColor: Colors.red,
          ),
        );
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
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimir Comprovante',
            onPressed: () => _printComprovante(context),
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

  Widget _buildBoolIndicator(String title, bool val, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            val ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: val ? const Color(0xFF10B981) : Colors.red.shade400,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: val ? const Color(0xFF10B981).withOpacity(0.1) : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: val ? const Color(0xFF10B981).withOpacity(0.3) : Colors.red.shade200,
              ),
            ),
            child: Text(
              val ? 'Sim' : 'Não',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: val ? const Color(0xFF006b33) : Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF006b33), size: 16),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006b33), letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificDataCard(Map<String, dynamic> d) {
    final tipo = d['tipo']?.toString() ?? 'Não especificado';

    if (tipo == 'Supressão Vegetal') {
      final s = d['supressao'] ?? d;
      final bool isMa = s['bioma'] == 'MA' || s['bioma']?.toString()?.toUpperCase() == 'MATA ATLÂNTICA';
      final String biomaName = isMa ? 'Mata Atlântica' : 'Caatinga';

      return _buildCard(
        title: 'Especificações: Supressão Vegetal',
        icon: Icons.forest_outlined,
        iconColor: Colors.green,
        children: [
          // HIGHLIGHT BIOMA
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.forest_outlined, color: Colors.green.shade800, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bioma Predominante', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        biomaName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                      ),
                    ],
                  ),
                ),
                if (s['foto_geo_ok'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 10, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('FOTO GEO OK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          _buildSectionHeader('1. Áreas Protegidas e Diagnóstico Básico', Icons.shield_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Curso d\'água / Nascente / Lago presente', s['tem_curso_dagua'] == true, subtitle: 'Identificado no imóvel'),
          _buildBoolIndicator('Vegetação da APP preservada', s['app_preservada'] == true, subtitle: 'Conformidade com APP'),
          _buildBoolIndicator('Indícios de uso do solo ou supressão na APP', s['indicios_uso_app'] == true, subtitle: 'Sinais de degradação antrópica na APP'),
          _buildBoolIndicator('Reserva Legal (RL) isolada de atividades', s['rl_isolada'] == true, subtitle: 'Isolamento de atividades produtivas'),
          _buildBoolIndicator('Vegetação da RL compatível com o CAR', s['rl_nativa_compativel'] == true, subtitle: 'Conformidade com cadastro CAR'),

          const SizedBox(height: 8),
          _buildSectionHeader('2. Ficha Técnica do Bioma ($biomaName)', Icons.list_alt_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          if (isMa) ...[
            _buildRow('Estágio Sucessional', s['bloco_a_estagio_sucessional']?.toString() ?? 'Não informado'),
            _buildRow('DAP Médio', s['bloco_a_dap_opcao']?.toString() ?? 'Não informado'),
            _buildRow('Altura (Dossel)', s['bloco_a_altura_opcao']?.toString() ?? 'Não informado'),
            _buildRow('Serapilheira', s['bloco_a_serapilheira_opcao']?.toString() ?? 'Não informado'),
            _buildRow('Epífitas / Cipós', s['bloco_a_epifitas_opcao']?.toString() ?? 'Não informado'),
            _buildRow('Sub-bosque', s['bloco_a_subbosque_opcao']?.toString() ?? 'Não informado'),
            if (s['bloco_a_observacoes'] != null && s['bloco_a_observacoes'].toString().isNotEmpty)
              _buildRow('Obs. Bloco A', s['bloco_a_observacoes']),
          ] else ...[
            _buildRow('Estrutura da Caatinga', s['bloco_b_estrutura']?.toString() ?? 'Não informado'),
            if (s['bloco_b_observacoes'] != null && s['bloco_b_observacoes'].toString().isNotEmpty)
              _buildRow('Obs. Bloco B', s['bloco_b_observacoes']),
          ],

          const SizedBox(height: 8),
          _buildSectionHeader('3. Diagnóstico Físico-Ambiental', Icons.warning_amber_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Presença de Espécies Invasoras', s['presenca_invasoras'] == true),
          _buildBoolIndicator('Presença de Espécies Exóticas', s['presenca_exoticas'] == true),
          if (s['presenca_invasoras'] == true || s['presenca_exoticas'] == true) ...[
            _buildRow('Espécies', s['especies']?.toString() ?? 'Não detalhado'),
            _buildRow('Grau de Infestação', s['grau_infestacao']?.toString() ?? 'Baixo'),
            _buildRow('Localização Invasoras', 'APP: ${s['loc_app'] == true ? 'Sim' : 'Não'} | RL: ${s['loc_rl'] == true ? 'Sim' : 'Não'} | UAS: ${s['loc_uas'] == true ? 'Sim' : 'Não'}'),
          ],
          _buildBoolIndicator('Presença de pastos/roçados abandonados > 5 anos', s['pastos_abandonados'] == true),
          _buildBoolIndicator('Supressão vegetal ou movimentação de solo', s['supressao_solo'] == true),

          const SizedBox(height: 8),
          _buildSectionHeader('4. Registro de Ocorrência de Fogo', Icons.local_fire_department_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Queimada / Uso do fogo na APP', s['fogo_app'] == true),
          _buildBoolIndicator('Queimada / Uso do fogo na RL', s['fogo_rl'] == true),
          _buildBoolIndicator('Queimada / Uso do fogo na UAS', s['fogo_uas'] == true),
          _buildBoolIndicator('Queimada / Uso do fogo em outras áreas', s['fogo_outras'] == true),

          const SizedBox(height: 8),
          _buildSectionHeader('5. Fiscalização & Medidas DIFI', Icons.gavel_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Constatação de infração ambiental no local', s['infracao']?.toString().startsWith('Sim') == true || s['infracao_constatada'] == true),
          if (s['infracao'] != null && s['infracao'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Text(
                s['infracao'].toString(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red),
              ),
            ),
          _buildRow('Medidas Sugeridas DIFI', s['medida_sugerida']?.toString() ?? 'Nenhuma sugerida'),

          const SizedBox(height: 8),
          _buildSectionHeader('6. Parecer Técnico & Informações', Icons.edit_note),
          const Divider(height: 4),
          const SizedBox(height: 8),
          const Text('Observações Técnicas / Parecer:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              s['observacoes']?.toString() ?? 'Sem parecer técnico registrado.',
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      );
    } else if (tipo == 'Avicultura') {
      final a = d['avicultura'] ?? d;
      final String modelo = a['modelo']?.toString()?.toUpperCase() ?? 'CORTE';
      final bool isCorte = modelo == 'CORTE';

      return _buildCard(
        title: 'Especificações: Avicultura',
        icon: Icons.egg_outlined,
        iconColor: Colors.amber.shade700,
        children: [
          // HIGHLIGHT MODELO DE PRODUÇÃO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.widgets_outlined, color: Colors.amber.shade800, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modelo de Produção', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        isCorte ? 'Corte (Frango)' : 'Postura (Ovos)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ],
                  ),
                ),
                if (a['foto_geo_ok'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 10, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('FOTO GEO OK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          if (isCorte) ...[
            _buildSectionHeader('1. Avicultura de Corte - Parâmetros Técnicos', Icons.settings_outlined),
            const Divider(height: 4),
            const SizedBox(height: 8),
            _buildRow('Sistema de Criação', a['corte_sistema_criacao']?.toString() ?? 'Não informado'),
            _buildRow('Densidade Recomendada', a['corte_densidade']?.toString() ?? 'Não informada'),
            
            const SizedBox(height: 8),
            _buildSectionHeader('2. Características Observadas no Galpão', Icons.remove_red_eye_outlined),
            const Divider(height: 4),
            const SizedBox(height: 8),
            _buildBoolIndicator('Aves soltas no chão', a['corte_aves_soltas_chao'] == true),
            _buildBoolIndicator('Criação sobre cama (casca de arroz)', a['corte_cama_casca_arroz'] == true),
            _buildBoolIndicator('Dimensões: Galpões Longos', a['corte_galpoes_longos'] == true),
            _buildBoolIndicator('Dimensões: Galpões Curtos', a['corte_galpoes_curtos'] == true),
            _buildBoolIndicator('Bebedouros no chão', a['corte_bebedouros_chao'] == true),
            _buildBoolIndicator('Bebedouros suspensos', a['corte_bebedouros_suspensos'] == true),
            _buildBoolIndicator('Comedouros no chão', a['corte_comedouros_chao'] == true),
            _buildBoolIndicator('Comedouros suspensos', a['corte_comedouros_suspensos'] == true),
            _buildBoolIndicator('Fase Pintos (Inicial)', a['corte_pintos'] == true),
            _buildBoolIndicator('Fase Frangos (Engorda)', a['corte_frangos'] == true),
            _buildBoolIndicator('Possui Ventiladores Internos', a['corte_ventiladores'] == true),
            if (a['corte_ventiladores'] == true)
              _buildBoolIndicator('Ventiladores Funcionando', a['corte_ventiladores_func'] == true),
            _buildBoolIndicator('Não Possui Ventiladores', a['corte_sem_ventiladores'] == true),

            const SizedBox(height: 8),
            _buildSectionHeader('3. Medidas & Capacidade do Galpão', Icons.analytics_outlined),
            const Divider(height: 4),
            const SizedBox(height: 8),
            _buildRow('Comprimento (m)', a['corte_comprimento']?.toString() ?? 'Não informado'),
            _buildRow('Largura (m)', a['corte_largura']?.toString() ?? 'Não informado'),
            _buildRow('Área Calculada', a['corte_area'] != null ? '${a['corte_area']} m²' : 'Não informada'),
            _buildRow('Estimativa de Animais', a['corte_qtd_estimada']?.toString() ?? 'Não calculada'),

            const SizedBox(height: 8),
            _buildSectionHeader('4. Destinação de Resíduos da Cama', Icons.recycling_outlined),
            const Divider(height: 4),
            const SizedBox(height: 8),
            _buildRow('Foco de Destinação', a['corte_cama_destinacao']?.toString() ?? 'Não informada'),
            if (a['corte_cama_destinacao']?.toString() == 'Outros')
              _buildRow('Detalhes Outro Destino', a['corte_cama_outros']?.toString() ?? 'Não especificado'),
            
            if (a['corte_info_adicional'] != null && a['corte_info_adicional'].toString().trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSectionHeader('5. Observações Específicas', Icons.chat_bubble_outline),
              const Divider(height: 4),
              const SizedBox(height: 8),
              Text(
                a['corte_info_adicional'].toString(),
                style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
              ),
            ],
          ] else ...[
            _buildSectionHeader('1. Avicultura de Postura - Parâmetros Técnicos', Icons.settings_outlined),
            const Divider(height: 4),
            const SizedBox(height: 8),
            _buildRow('Sistema de Criação', a['postura_sistema_criacao']?.toString() ?? 'Não informado'),
            _buildRow('Tipo de Confinamento', a['postura_tipo_confinamento']?.toString() ?? 'Não informado'),

            const SizedBox(height: 8),
            _buildSectionHeader('2. Grade de Contagem (Gaiolas/Aves)', Icons.grid_on_outlined),
            const Divider(height: 4),
            const SizedBox(height: 8),
            _buildRow('Nº de Fileiras', a['postura_fileiras']?.toString() ?? 'Não informado'),
            _buildRow('Nº de Andares', a['postura_andares']?.toString() ?? 'Não informado'),
            _buildRow('Gaiolas por Módulo', a['postura_gaiolas_modulo']?.toString() ?? 'Não informado'),
            _buildRow('Aves por Gaiola', a['postura_aves_gaiola']?.toString() ?? 'Não informado'),
            _buildRow('Estimativa Total de Aves', a['postura_qtd_estimada']?.toString() ?? 'Não calculada'),

            if (a['postura_info_adicional'] != null && a['postura_info_adicional'].toString().trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSectionHeader('3. Observações Específicas', Icons.chat_bubble_outline),
              const Divider(height: 4),
              const SizedBox(height: 8),
              Text(
                a['postura_info_adicional'].toString(),
                style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
              ),
            ],
          ],

          const SizedBox(height: 8),
          _buildSectionHeader('Conformidades Ambientais & DIFI', Icons.shield_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Gera resíduos no local', a['gera_residuos'] == true),
          if (a['gera_residuos'] == true && a['residuos_detalhes'] != null && a['residuos_detalhes'].toString().isNotEmpty)
            _buildRow('Detalhe dos Resíduos', a['residuos_detalhes'].toString()),
          
          _buildBoolIndicator('Destinação de animais mortos por incineração', a['mortos_incinerados'] != false),
          if (a['mortos_incinerados'] == false && a['mortos_destinacao_alt'] != null && a['mortos_destinacao_alt'].toString().isNotEmpty)
            _buildRow('Destinação Alternativa', a['mortos_destinacao_alt'].toString()),

          _buildBoolIndicator('Fiscalização: Constatação de infração administrativa', a['infracao_constatada'] == true),
          _buildRow('Medidas DIFI Sugeridas', a['medida_sugerida']?.toString() ?? 'Nenhuma sugerida'),

          const SizedBox(height: 12),
          const Text('Observações Técnicas / Parecer Geral:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              a['observacoes']?.toString() ?? 'Sem parecer técnico registrado.',
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      );
    } else if (tipo == 'Suinocultura') {
      final s = d['suinocultura'] ?? d;
      final String modelo = s['modelo']?.toString()?.toUpperCase() ?? 'CAIPIRA';
      final bool isIndustrial = modelo == 'INDUSTRIAL';

      return _buildCard(
        title: 'Especificações: Suinocultura',
        icon: Icons.pets,
        iconColor: Colors.pink,
        children: [
          // HIGHLIGHT MODELO DE PRODUÇÃO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.pets, color: Colors.pink.shade800, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modelo de Produção', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        isIndustrial ? 'Industrial' : 'Caipira',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink.shade900),
                      ),
                    ],
                  ),
                ),
                if (s['foto_geo_ok'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 10, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('FOTO GEO OK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          _buildSectionHeader('1. Capacidade e Infraestrutura', Icons.settings_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildRow('Quantidade de Galpões', s['qtd_galpoes']?.toString() ?? 'Não informado'),
          _buildRow('Média de Animais por Galpão', s['qtd_medio_por_galpao']?.toString() ?? 'Não informado'),
          _buildRow('Estimativa Total de Animais', s['qtd_animais']?.toString() ?? 'Não informada'),

          const SizedBox(height: 8),
          _buildSectionHeader('2. Fases de Produção & Estimativas', Icons.check_box_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator(
            'Suíno em terminação',
            s['fase_terminacao'] == true,
            subtitle: s['fase_terminacao'] == true ? 'Estimativa: ${s['fase_terminacao_qtd'] ?? "Não informada"}' : null,
          ),
          _buildBoolIndicator(
            'Matrizes gestantes',
            s['fase_matrizes'] == true,
            subtitle: s['fase_matrizes'] == true ? 'Estimativa: ${s['fase_matrizes_qtd'] ?? "Não informada"}' : null,
          ),
          _buildBoolIndicator(
            'Reprodutores',
            s['fase_reprodutores'] == true,
            subtitle: s['fase_reprodutores'] == true ? 'Estimativa: ${s['fase_reprodutores_qtd'] ?? "Não informada"}' : null,
          ),
          _buildBoolIndicator(
            'Suíno adulto',
            s['fase_adulto'] == true,
            subtitle: s['fase_adulto'] == true ? 'Estimativa: ${s['fase_adulto_qtd'] ?? "Não informada"}' : null,
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('3. Diagnóstico Sanitário e Ambiental', Icons.warning_amber_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Existe acúmulo de resíduos?', s['acumulo_residuos'] == true),
          _buildBoolIndicator('Há vazamento de dejetos para fora do sistema?', s['vazamento_dejetos'] == true),
          _buildBoolIndicator('Há odor extremo?', s['odor_extremo'] == true),
          _buildBoolIndicator('Os dejetos estão transbordando?', s['dejetos_transbordando'] == true),
          _buildBoolIndicator('Existe sistema de impermeabilização e contenção?', s['impermeabilizacao_contencao'] == true),
          _buildBoolIndicator('Existe destinação adequada e/ou tratamento dos dejetos?', s['destinacao_adequada'] == true),

          const SizedBox(height: 8),
          _buildSectionHeader('4. Manejo & Porte do Empreendimento', Icons.assignment_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Indícios de porte maior ou manejo inadequado?', s['indicios_porte_maior'] == true),
          if (s['indicios_porte_maior'] == true && s['indicios_porte_maior_detalhe'] != null && s['indicios_porte_maior_detalhe'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Text(
                'Detalhes: ${s['indicios_porte_maior_detalhe']}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),

          const SizedBox(height: 8),
          _buildSectionHeader('5. Destinação de Animais Mortos', Icons.delete_outline),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Animais mortos são incinerados?', s['mortos_incinerados'] != false),
          if (s['mortos_incinerados'] == false && s['mortos_destino'] != null && s['mortos_destino'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Text(
                'Destino Alternativo: ${s['mortos_destino']}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),

          const SizedBox(height: 8),
          _buildSectionHeader('6. Ritos Legais & Fiscalização', Icons.gavel_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Constatação de infração ambiental no local', s['infracao_constatada'] == true),
          _buildRow('Medidas Sugeridas DIFI', s['medida_sugerida']?.toString() ?? 'Nenhuma sugerida'),

          const SizedBox(height: 8),
          _buildSectionHeader('7. Parecer Técnico & Informações', Icons.edit_note),
          const Divider(height: 4),
          const SizedBox(height: 8),
          const Text('Observações Técnicas / Parecer:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              s['observacoes']?.toString() ?? 'Sem parecer técnico registrado.',
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      );
    } else if (tipo == 'Bovinocultura') {
      final b = d['bovinocultura'] ?? d;
      final isIntensivo = b['modelo']?.toString()?.toUpperCase() == 'INTENSIVO';
      return _buildCard(
        title: 'Especificações: Bovinocultura',
        icon: Icons.grass_outlined,
        iconColor: Colors.brown,
        children: [
          // Header Row with Model and Georef Badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.brown.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modelo de Criação', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        isIntensivo ? 'Intensivo (Confinamento)' : 'Extensivo (Pasto)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown.shade900),
                      ),
                    ],
                  ),
                ),
                if (b['foto_geo_ok'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 10, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('FOTO GEO OK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('1. Dimensionamento e Infraestrutura', Icons.straighten_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildRow('Área destinada à criação (ha)', b['area_ha']?.toString() ?? 'Não informado'),
          _buildRow('Quantidade de Cochos', b['qtd_cochos']?.toString() ?? 'Não informado'),
          _buildRow('Tamanho dos Cochos (m)', b['tamanho_cochos']?.toString() ?? 'Não informado'),
          _buildRow('Dessedentação', b['dessedentacao']?.toString() ?? 'Não informado'),

          const SizedBox(height: 12),
          _buildSectionHeader('2. Efetivo Bovino/Bubalino/Ovino/Caprino', Icons.pets_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildRow('Quantidade Estimada de Animais', b['qtd_animais']?.toString() ?? 'Não informado'),

          const SizedBox(height: 12),
          _buildSectionHeader('3. Ritos Legais & Fiscalização', Icons.gavel_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Constatação de infração ambiental no local', b['infracao_constatada'] == true),
          if (b['infracao_constatada'] == true)
            _buildRow('Medidas Sugeridas DIFI', b['medida_sugerida']?.toString() ?? 'Nenhuma sugerida'),

          const SizedBox(height: 12),
          _buildSectionHeader('4. Parecer Técnico & Informações', Icons.edit_note),
          const Divider(height: 4),
          const SizedBox(height: 8),
          const Text('Observações Técnicas / Parecer:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              b['observacoes']?.toString() ?? 'Sem parecer técnico registrado.',
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      );
    } else if (tipo == 'Aquicultura') {
      final aq = d['aquicultura'] ?? d;
      const primaryCyan = Color(0xFF0097A7);
      const darkSlate = Color(0xFF1E293B);
      
      final aeradoresCount = int.tryParse(aq['qtd_aeradores']?.toString() ?? '0') ?? 0;
      final possessesAeradores = aq['possui_aeradores'] == true;
      final showAeradorWarning = possessesAeradores && aeradoresCount >= 3;
      
      final String descarte = aq['descarte_residuos']?.toString()?.toUpperCase() ?? 'COMPOSTEIRA';

      return _buildCard(
        title: 'Especificações: Aquicultura',
        icon: Icons.water_outlined,
        iconColor: primaryCyan,
        children: [
          // HIGHLIGHT VIVEIROS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyan.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyan.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.waves, color: primaryCyan, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Capacidade total de viveiros', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        '${aq['qtd_tanques'] ?? 0} tanques | ${aq['area_tanques'] ?? 0} ha',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
                      ),
                    ],
                  ),
                ),
                if (aq['foto_geo_ok'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 10, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('FOTO GEO OK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('1. Capacidade e Dimensões', Icons.straighten_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildRow('Nº de tanques', aq['qtd_tanques']?.toString() ?? 'Não informado'),
          _buildRow('Área total dos tanques (ha)', aq['area_tanques']?.toString() ?? 'Não informado'),
          
          const SizedBox(height: 8),
          _buildSectionHeader('2. Sistemas de Aeração', Icons.wind_power_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator(
            'Tanques possuem aeradores', 
            possessesAeradores, 
            subtitle: possessesAeradores ? 'Quantidade por tanque: ${aq['qtd_aeradores'] ?? "Não informada"}' : null
          ),
          if (showAeradorWarning) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Alerta rápido: 3 ou mais aeradores por tanque pode indicar sistema intensivo e maior potencial poluidor.',
                      style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          _buildSectionHeader('3. Equipamentos e Estruturas Identificadas', Icons.inventory_2_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator(
            'BOMBA', 
            aq['bomba_identificada'] == true,
            subtitle: aq['bomba_identificada'] == true ? 'Situação: ${aq['bomba_situacao']?.toString() ?? "Não descrita"}' : null
          ),
          _buildBoolIndicator(
            'TUBULAÇÃO', 
            aq['tubulacao_identificada'] == true,
            subtitle: aq['tubulacao_identificada'] == true ? 'Situação: ${aq['tubulacao_situacao']?.toString() ?? "Não descrita"}' : null
          ),
          _buildBoolIndicator(
            'PONTO DE CAPTAÇÃO', 
            aq['captacao_identificada'] == true,
            subtitle: aq['captacao_identificada'] == true ? 'Situação: ${aq['captacao_situacao']?.toString() ?? "Não descrita"}' : null
          ),
          _buildBoolIndicator(
            'HIDRÔMETRO', 
            aq['hidrometro'] == true,
            subtitle: aq['hidrometro'] == true ? 'Situação: ${aq['hidrometro_situacao']?.toString() ?? "Não descrita"}' : null
          ),
          _buildBoolIndicator(
            'OUTROS', 
            aq['outros_itens_identificados'] == true,
            subtitle: aq['outros_itens_identificados'] == true ? 'Situação: ${aq['outros_itens_situacao']?.toString() ?? "Não descrita"}' : null
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('4. Recursos Hídricos & Resíduos', Icons.local_drink_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator(
            'Existe outorga de água', 
            aq['outorga'] == true,
            subtitle: aq['outorga'] == true ? 'Identificação: ${aq['outorga_identificacao']?.toString() ?? "Não descrita"}' : null
          ),
          _buildRow(
            'Local de descarte de resíduos', 
            descarte == 'OUTRO' 
                ? 'Outro: ${aq['descarte_residuos_outro']?.toString() ?? "Não informado"}'
                : 'Composteira'
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('5. Fiscalização & Ritos DIFI', Icons.gavel_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Registro Fotográfico Georreferenciado realizado conforme rito', aq['foto_geo_ok'] == true),
          _buildBoolIndicator('Constatação de infração ambiental no local', aq['infracao_constatada'] == true),
          if (aq['infracao_constatada'] == true) ...[
            _buildRow('Sugestão de Medidas DIFI', aq['medida_sugerida']?.toString() ?? 'Nenhuma sugerida'),
          ],

          const SizedBox(height: 8),
          _buildSectionHeader('6. Parecer Técnico & Informações', Icons.edit_note),
          const Divider(height: 4),
          const SizedBox(height: 8),
          const Text('Observações Técnicas / Parecer:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              aq['observacoes']?.toString() ?? 'Sem parecer técnico registrado.',
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      );
    } else if (tipo == 'Sucroalcooleiro' || tipo == 'Atividades Agroindustriais') {
      final su = d['sucroalcooleiro'] ?? d;
      return _buildCard(
        title: 'Especificações: Atividades Agroindustriais',
        icon: Icons.factory_outlined,
        iconColor: Colors.purple,
        children: [
          // HIGHLIGHT MATÉRIA PRIMA
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Armazenamento de Matéria-Prima', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        su['local_materia_prima']?.toString() ?? 'Não informado',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                    ],
                  ),
                ),
                if (su['foto_geo_ok'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 10, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('FOTO GEO OK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          _buildSectionHeader('1. Efluentes, Resíduos e Bagaço', Icons.recycling_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Produz efluentes?', su['produz_efluentes'] == true),
          if (su['produz_efluentes'] == true)
            _buildRow('Coleta e Destinação Efluentes', su['efluentes_coleta_destinacao']?.toString() ?? 'Não informado'),
          _buildBoolIndicator('Produz resíduos sólidos?', su['produz_residuos'] == true),
          if (su['produz_residuos'] == true)
            _buildRow('Coleta e Destinação Resíduos', su['residuos_coleta_destinacao']?.toString() ?? 'Não informado'),
          _buildBoolIndicator('Gera/Utiliza bagaço?', su['gera_utiliza_bagaco'] == true),
          if (su['gera_utiliza_bagaco'] == true)
            _buildRow('Armazenamento/Destinação Bagaço', su['bagaco_armazenamento_destinacao']?.toString() ?? 'Não informado'),

          _buildSectionHeader('2. Combustão e Fontes Térmicas', Icons.local_fire_department_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Existem fontes térmicas?', su['fontes_termicas'] == true),
          if (su['fontes_termicas'] == true)
            _buildRow('Fontes Térmicas Identificadas', su['fontes_termicas_quais']?.toString() ?? 'Não informado'),
          _buildBoolIndicator('Utiliza lenha como combustível?', su['utiliza_lenha'] == true),
          if (su['utiliza_lenha'] == true) ...[
            _buildRow('Origem da lenha', su['lenha_nativa_exotica']?.toString() == 'EXOTICA' ? 'Exótica' : 'Nativa'),
            _buildRow('Local de armazenamento da lenha', su['lenha_local_armazenamento']?.toString() ?? 'Não informado'),
          ],

          _buildSectionHeader('3. Controle Técnico & Operacional', Icons.build_circle_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Tanques de armazenamento adequados/íntegros/identificados?', su['tanques_adequados'] == true),
          _buildBoolIndicator('Existe higienização e controle de efluentes da limpeza?', su['higienizacao_controle_efluentes'] == true),
          _buildBoolIndicator('Existe fossa séptica?', su['fossa_septica'] == true),
          _buildBoolIndicator('Equipamentos conforme memorial descritivo?', su['equipamentos_memorial'] == true || su['equipamentos_conformes'] == true),
          _buildBoolIndicator('Chaminés possuem sistemas de controle de emissões?', su['chamines_controle_emissoes'] == true),

          _buildSectionHeader('4. Gestão de Vinhaça, Lagoas & Vazamentos', Icons.water_damage_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Possui sistema de coleta/transporte/armazenamento vinhaça?', su['sistema_vinhaca'] == true),
          if (su['sistema_vinhaca'] == true)
            _buildRow('Condições da Vinhaça', su['vinhaca_condicoes']?.toString() ?? 'Não informado'),
          _buildBoolIndicator('Possui tanques/lagoas impermeabilizadas?', su['tanques_lagoas_impermeabilizadas'] == true),
          _buildBoolIndicator('Existem vazamentos ou infiltrações (tubulação/armazenamento)?', su['vazamentos_infiltracoes'] == true),
          _buildBoolIndicator('Os efluentes são destinados corretamente?', su['efluentes_destinados_corretamente'] == true),
          _buildBoolIndicator('Gestão de resíduos sólidos conforme PGRS?', su['gestao_residuos_pgrs'] == true),

          _buildSectionHeader('5. Envase, Logística e Insumos', Icons.inventory_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Existe área específica para envase?', su['area_especifica_envase'] == true),
          if (su['area_especifica_envase'] == true)
            _buildRow('Condições de Envase', su['envase_condicoes']?.toString() ?? 'Não informado'),
          _buildBoolIndicator('Armazenamento atende aos requisitos ambientais?', su['armazenamento_requisitos_ambientais'] == true || su['armazenamento_ok'] == true),
          _buildBoolIndicator('Faz uso de agrotóxicos?', su['faz_uso_agrotoxicos'] == true),
          if (su['faz_uso_agrotoxicos'] == true) ...[
            _buildRow('Quais agrotóxicos', su['agrotoxicos_quais']?.toString() ?? 'Não informado'),
            _buildBoolIndicator('Possui receituário agronômico?', su['agrotoxicos_receituario'] == true),
            _buildRow('Destinação embalagens', su['agrotoxicos_embalagens_destinacao']?.toString() ?? 'Não informado'),
          ],

          _buildSectionHeader('6. Ritos Legais & Fiscalização', Icons.gavel_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Registro Fotográfico Georreferenciado realizado conforme rito', su['foto_geo_ok'] == true),
          _buildBoolIndicator('Constatação de infração ambiental no local', su['infracao_constatada'] == true),
          if (su['infracao_constatada'] == true) ...[
            _buildRow('Sugestão de Medidas DIFI', su['infracao_sugestao_medidas']?.toString() ?? su['medida_sugerida']?.toString() ?? 'Nenhuma sugerida'),
          ],

          _buildSectionHeader('7. Parecer Técnico & Informações', Icons.edit_note),
          const Divider(height: 4),
          const SizedBox(height: 8),
          const Text('Observações Técnicas / Parecer:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              su['observacoes_complementares']?.toString() ?? su['observacoes']?.toString() ?? 'Sem parecer técnico registrado.',
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      );
    } else if (tipo == 'Agricultura') {
      final ag = d['agricultura'] ?? d;
      return _buildCard(
        title: 'Especificações: Atividades Agrícolas',
        icon: Icons.agriculture_outlined,
        iconColor: Colors.lightGreen,
        children: [
          // HIGHLIGHT CULTIVO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.lightGreen.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.lightGreen.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.agriculture, color: Colors.lightGreen, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Atividade Agrícola / Cultivo', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        ag['atividade_agricola']?.toString() ?? ag['cultivo']?.toString() ?? 'Não informado',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                      ),
                    ],
                  ),
                ),
                if (ag['foto_geo_ok'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 10, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('FOTO GEO OK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          _buildSectionHeader('1. Irrigação & Recursos Hídricos', Icons.water_drop_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Atividade é Irrigada?', ag['atividade_irrigada'] == true),
          if (ag['atividade_irrigada'] == true)
            _buildRow('Possui outorga?', ag['irrigada_outorga']?.toString() ?? 'Não informado'),
          _buildBoolIndicator('Existem corpos hídricos no entorno do cultivo?', ag['tem_cursos_hidricos'] == true || ag['cursos_hidricos_entorno']?.toString()?.toLowerCase() == 'sim'),

          _buildSectionHeader('2. Uso de Defensivos & Insumos', Icons.pest_control_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Faz uso de agrotóxicos?', ag['faz_uso_agrotoxicos'] == true),
          if (ag['faz_uso_agrotoxicos'] == true) ...[
            _buildRow('Quais agrotóxicos', ag['agrotoxicos_quais']?.toString() ?? ag['agrotoxicos']?.toString() ?? 'Não detalhado'),
            _buildBoolIndicator('Possui receituário agronômico?', ag['agrotoxicos_receituario'] == true),
            _buildRow('Destinação de embalagens', ag['agrotoxicos_embalagens_destinacao']?.toString() ?? 'Não detalhado'),
          ],

          _buildSectionHeader('3. Ritos Legais & Fiscalização', Icons.gavel_outlined),
          const Divider(height: 4),
          const SizedBox(height: 8),
          _buildBoolIndicator('Registro Fotográfico Georreferenciado realizado conforme rito', ag['foto_geo_ok'] == true),
          _buildBoolIndicator('Constatação de infração ambiental no local', ag['infracao_constatada'] == true),
          if (ag['infracao_constatada'] == true) ...[
            _buildRow('Sugestão de Medidas DIFI', ag['infracao_sugestao_medidas']?.toString() ?? ag['medida_sugerida']?.toString() ?? 'Nenhuma sugerida'),
          ],

          _buildSectionHeader('4. Parecer Técnico & Informações', Icons.edit_note),
          const Divider(height: 4),
          const SizedBox(height: 8),
          const Text('Observações Técnicas / Parecer:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              ag['observacoes_complementares']?.toString() ?? ag['observacoes']?.toString() ?? 'Sem parecer técnico registrado.',
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
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
