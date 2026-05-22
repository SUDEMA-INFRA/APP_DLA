export interface UserData {
  id: number;
  cpf: string;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
}

export interface VistoriaData {
  local_id: string;
  user: number;
  data: {
    processo_n?: string;
    requerente?: string;
    latitude?: number;
    longitude?: number;
    status?: string;
    municipio?: number | string;
    municipio_nome?: string;
    tipo?: string;
    dispositivo?: string;
    supressao?: {
      tem_curso_dagua?: boolean;
      app_preservada?: boolean;
      indicios_uso_app?: boolean;
      rl_isolada?: boolean;
      rl_nativa_compativel?: boolean;
      bioma?: string;
      bloco_a_dap?: boolean;
      bloco_a_altura?: boolean;
      bloco_a_serapilheira?: boolean;
      bloco_a_epifitas?: boolean;
      bloco_a_subbosque?: boolean;
      
      // Mata Atlântica details
      bloco_a_estagio_sucessional?: string;
      bloco_a_dap_opcao?: string;
      bloco_a_altura_opcao?: string;
      bloco_a_serapilheira_opcao?: string;
      bloco_a_epifitas_opcao?: string;
      bloco_a_subbosque_opcao?: string;
      bloco_a_observacoes?: string;
      
      bloco_b_estrutura?: string;
      presenca_invasoras?: boolean;
      presenca_exoticas?: boolean;
      especies?: string;
      grau_infestacao?: string;
      loc_app?: string;
      loc_rl?: string;
      loc_uas?: string;
      pastos_abandonados?: boolean;
      supressao_solo?: boolean;
      fogo_app?: boolean;
      fogo_rl?: boolean;
      fogo_uas?: boolean;
      fogo_outras?: boolean;
      foto_geo_ok?: boolean;
      infracao?: string;
      medida_sugerida?: string;
      observacoes?: string;
    };
    avicultura?: {
      modelo?: string;
      
      // Corte fields
      corte_sistema_criacao?: string;
      corte_aves_soltas_chao?: boolean;
      corte_cama_casca_arroz?: boolean;
      corte_galpoes_longos?: boolean;
      corte_galpoes_curtos?: boolean;
      corte_bebedouros_chao?: boolean;
      corte_bebedouros_suspensos?: boolean;
      corte_comedouros_chao?: boolean;
      corte_comedouros_suspensos?: boolean;
      corte_pintos?: boolean;
      corte_frangos?: boolean;
      corte_ventiladores?: boolean;
      corte_ventiladores_func?: boolean;
      corte_sem_ventiladores?: boolean;
      corte_info_adicional?: string;
      corte_comprimento?: number;
      corte_largura?: number;
      corte_area?: number;
      corte_densidade?: string;
      corte_qtd_estimada?: number;
      corte_cama_destinacao?: string;
      corte_cama_outros?: string;
      
      // Postura fields
      postura_sistema_criacao?: string;
      postura_tipo_confinamento?: string;
      postura_info_adicional?: string;
      postura_fileiras?: number;
      postura_andares?: number;
      postura_gaiolas_modulo?: number;
      postura_aves_gaiola?: number;
      postura_qtd_estimada?: number;
      
      // Shared fields
      gera_residuos?: boolean;
      residuos_detalhes?: string;
      mortos_incinerados?: boolean;
      mortos_destinacao_alt?: string;
      foto_geo_ok?: boolean;
      infracao_constatada?: boolean;
      medida_sugerida?: string;
      observacoes?: string;
      
      // Legacy compatibility
      tipo_criacao?: string;
      qtd_animais?: number;
      qtd_galpoes?: number;
      qtd_modulos?: number;
      qtd_gaiolas_modulo?: number;
      aves_gaiola?: number;
      residuos_desc?: string;
    };
    suinocultura?: {
      modelo?: string;
      qtd_galpoes?: number;
      qtd_medio_por_galpao?: number;
      fase_terminacao?: boolean;
      fase_terminacao_qtd?: string;
      fase_matrizes?: boolean;
      fase_matrizes_qtd?: string;
      fase_reprodutores?: boolean;
      fase_reprodutores_qtd?: string;
      fase_adulto?: boolean;
      fase_adulto_qtd?: string;
      acumulo_residuos?: boolean;
      vazamento_dejetos?: boolean;
      odor_extremo?: boolean;
      dejetos_transbordando?: boolean;
      impermeabilizacao_contencao?: boolean;
      destinacao_adequada?: boolean;
      indicios_porte_maior?: boolean;
      indicios_porte_maior_detalhe?: string;
      mortos_incinerados?: boolean;
      mortos_destino?: string;
      foto_geo_ok?: boolean;
      infracao_constatada?: boolean;
      medida_sugerida?: string;
      observacoes?: string;

      // Legacy compatibility
      qtd_animais?: number;
      fase_producao?: string;
      dejetos_destinacao?: string;
      conformidade?: boolean;
    };
    bovinocultura?: {
      modelo?: string;
      area_ha?: number;
      dessedentacao?: string;
      qtd_cochos?: number;
      tamanho_cochos?: number;
      qtd_animais?: number;
      foto_geo_ok?: boolean;
      infracao_constatada?: boolean;
      medida_sugerida?: string;
      observacoes?: string;
    };
    aquicultura?: {
      qtd_tanques?: number;
      area_tanques?: number;
      possui_aeradores?: boolean;
      qtd_aeradores?: number;
      
      bomba_identificada?: boolean;
      bomba_situacao?: string;
      
      tubulacao_identificada?: boolean;
      tubulacao_situacao?: string;
      
      captacao_identificada?: boolean;
      captacao_situacao?: string;
      
      hidrometro?: boolean;
      hidrometro_situacao?: string;
      
      outros_itens_identificados?: boolean;
      outros_itens_situacao?: string;
      
      outorga?: boolean;
      outorga_identificacao?: string;
      
      descarte_residuos?: 'COMPOSTEIRA' | 'OUTRO' | string;
      descarte_residuos_outro?: string;
      
      fonte_agua?: string;
      
      foto_geo_ok?: boolean;
      infracao_constatada?: boolean;
      medida_sugerida?: string;
      observacoes?: string;
    };
    sucroalcooleiro?: {
      local_materia_prima?: string;
      produz_efluentes?: boolean;
      efluentes_coleta_destinacao?: string;
      produz_residuos?: boolean;
      residuos_coleta_destinacao?: string;
      gera_utiliza_bagaco?: boolean;
      bagaco_armazenamento_destinacao?: string;
      fontes_termicas?: boolean;
      fontes_termicas_quais?: string;
      utiliza_lenha?: boolean;
      lenha_nativa_exotica?: string;
      lenha_local_armazenamento?: string;
      tanques_adequados?: boolean;
      higienizacao_controle_efluentes?: boolean;
      fossa_septica?: boolean;
      equipamentos_memorial?: boolean;
      chamines_controle_emissoes?: boolean;
      sistema_vinhaca?: boolean;
      vinhaca_condicoes?: string;
      tanques_lagoas_impermeabilizadas?: boolean;
      vazamentos_infiltracoes?: boolean;
      efluentes_destinados_corretamente?: boolean;
      gestao_residuos_pgrs?: boolean;
      area_especifica_envase?: boolean;
      envase_condicoes?: string;
      armazenamento_requisitos_ambientais?: boolean;
      faz_uso_agrotoxicos?: boolean;
      agrotoxicos_quais?: string;
      agrotoxicos_receituario?: boolean | string;
      agrotoxicos_embalagens_destinacao?: string;
      foto_geo_ok?: boolean;
      infracao_constatada?: boolean;
      infracao_sugestao_medidas?: string;
      observacoes_complementares?: string;

      // Legacy fields
      residuos_solidos?: string;
      bagaco?: string;
      equipamentos_conformes?: boolean;
      armazenamento_ok?: boolean;
      observacoes?: string;
    };
    agricultura?: {
      atividade_agricola?: string;
      atividade_irrigada?: boolean;
      irrigada_outorga?: string;
      faz_uso_agrotoxicos?: boolean;
      agrotoxicos_quais?: string;
      agrotoxicos_receituario?: boolean | string;
      agrotoxicos_embalagens_destinacao?: string;
      tem_cursos_hidricos?: boolean;
      foto_geo_ok?: boolean;
      infracao_constatada?: boolean;
      infracao_sugestao_medidas?: string;
      observacoes_complementares?: string;

      // Legacy fields
      cultivo?: string;
      cursos_hidricos_entorno?: string;
      agrotoxicos?: string;
      observacoes?: string;
    };
  };
  created_at?: string;
  synced_at?: string;
  updated_at?: string;
}

// Helper to determine the actual type of a vistoria
export const getVistoriaType = (v: VistoriaData) => {
  if (v.data.tipo) {
    if (v.data.tipo === 'Sucroalcooleiro') return 'Atividades Agroindustriais';
    return v.data.tipo;
  }
  if (v.data.supressao) return 'Supressão Vegetal';
  if (v.data.avicultura) return 'Avicultura';
  if (v.data.suinocultura) return 'Suinocultura';
  if (v.data.bovinocultura) return 'Bovinocultura';
  if (v.data.aquicultura) return 'Aquicultura';
  if (v.data.sucroalcooleiro) return 'Atividades Agroindustriais';
  if (v.data.agricultura) return 'Agricultura';
  return 'Geral';
};

// Helper to format date
export const formatDate = (dateStr?: string) => {
  if (!dateStr) return '-';
  try {
    const d = new Date(dateStr);
    return d.toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  } catch {
    return dateStr;
  }
};
