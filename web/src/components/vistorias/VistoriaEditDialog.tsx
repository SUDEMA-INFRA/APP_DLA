import React, { useState, useEffect } from 'react';
import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle, 
  DialogDescription, 
  DialogFooter 
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { AlertCircle, AlertTriangle } from 'lucide-react';
import { type VistoriaData, getVistoriaType } from './types';

interface VistoriaEditDialogProps {
  isOpen: boolean;
  setIsOpen: (open: boolean) => void;
  editingVistoria: VistoriaData | null;
  setEditingVistoria: React.Dispatch<React.SetStateAction<VistoriaData | null>>;
  onSave: () => Promise<void>;
  isSaving: boolean;
}

const VistoriaEditDialog: React.FC<VistoriaEditDialogProps> = React.memo(({
  isOpen,
  setIsOpen,
  editingVistoria,
  setEditingVistoria,
  onSave,
  isSaving
}) => {
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  // Clear error message when dialog opens/closes
  useEffect(() => {
    if (!isOpen) {
      setErrorMsg(null);
    }
  }, [isOpen]);

  const handleSave = async () => {
    setErrorMsg(null);
    try {
      await onSave();
    } catch (err: any) {
      console.error("Erro ao salvar:", err);
      setErrorMsg(
        err?.response?.data?.detail || 
        err?.message || 
        "Erro ao salvar alterações. Por favor, verifique a conexão com o servidor e os dados preenchidos."
      );
    }
  };

  if (!editingVistoria) return null;

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogContent className="max-w-[90vw] md:max-w-3xl max-h-[90vh] overflow-y-auto bg-white dark:bg-slate-950 text-slate-900 dark:text-slate-100">
        <DialogHeader>
          <DialogTitle className="text-xl font-bold">Editar Vistoria</DialogTitle>
          <DialogDescription className="text-xs">
            Edite as informações e dados coletados em campo.
          </DialogDescription>
        </DialogHeader>
        
        {errorMsg && (
          <Alert variant="destructive" className="my-2 bg-rose-50/15 border-rose-500/30 text-rose-600 dark:text-rose-400">
            <AlertCircle className="h-4 w-4" />
            <AlertTitle className="font-bold text-xs uppercase tracking-wider">Falha de Validação</AlertTitle>
            <AlertDescription className="text-xs font-medium leading-relaxed">
              {errorMsg}
            </AlertDescription>
          </Alert>
        )}

        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1">
              <label className="text-sm font-semibold">Nº Processo</label>
              <Input 
                value={editingVistoria.data.processo_n || ''} 
                onChange={e => {
                  let val = e.target.value.replace(/\D/g, '');
                  if (val.length > 10) val = val.slice(0, 10);
                  if (val.length > 4) val = val.slice(0, 4) + '-' + val.slice(4);
                  setEditingVistoria({
                    ...editingVistoria, 
                    data: { ...editingVistoria.data, processo_n: val }
                  });
                }}
                placeholder="0000-000000"
                className="bg-white dark:bg-slate-900"
              />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-semibold">Requerente</label>
              <Input 
                value={editingVistoria.data.requerente || ''} 
                onChange={e => setEditingVistoria({
                  ...editingVistoria, 
                  data: { ...editingVistoria.data, requerente: e.target.value }
                })} 
                className="bg-white dark:bg-slate-900"
              />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-semibold">Latitude</label>
              <Input 
                type="number"
                value={editingVistoria.data.latitude || ''} 
                onChange={e => setEditingVistoria({
                  ...editingVistoria, 
                  data: { ...editingVistoria.data, latitude: Number(e.target.value) }
                })} 
                className="bg-white dark:bg-slate-900"
              />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-semibold">Longitude</label>
              <Input 
                type="number"
                value={editingVistoria.data.longitude || ''} 
                onChange={e => setEditingVistoria({
                  ...editingVistoria, 
                  data: { ...editingVistoria.data, longitude: Number(e.target.value) }
                })} 
                className="bg-white dark:bg-slate-900"
              />
            </div>
          </div>

          <div className="mt-4">
            <h3 className="font-bold border-b pb-2 mb-4 text-sm text-slate-800 dark:text-slate-200">
              Dados Específicos ({getVistoriaType(editingVistoria)})
            </h3>
            <div className="space-y-4">
              {(() => {
                const type = getVistoriaType(editingVistoria).toLowerCase();
                const typeKey = type.includes('supressão') || type.includes('supressao') ? 'supressao' : type;
                const subData = (editingVistoria.data as any)[typeKey] || {};

                const renderEditSelect = (
                  label: string, 
                  value: boolean | string | null | undefined, 
                  onChange: (val: any) => void, 
                  options: {value: any, label: string}[]
                ) => {
                  return (
                    <div className="space-y-1">
                      <label className="text-xs font-semibold text-slate-500 block uppercase tracking-wider">{label}</label>
                      <select
                        className="flex h-9 w-full rounded-md border border-slate-200 bg-white dark:bg-slate-900 px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 dark:border-slate-800 dark:text-slate-200"
                        value={value === null || value === undefined ? (options[0]?.value?.toString() || "") : value.toString()}
                        onChange={e => {
                          const val = e.target.value;
                          if (val === "") onChange(null);
                          else if (val === "true") onChange(true);
                          else if (val === "false") onChange(false);
                          else onChange(val);
                        }}
                      >
                        {options.map(opt => (
                          <option key={opt.value.toString()} value={opt.value.toString()}>{opt.label}</option>
                        ))}
                      </select>
                    </div>
                  );
                };

                const renderEditBoolSelect = (
                  label: string, 
                  value: boolean | null | undefined, 
                  onChange: (val: boolean | null) => void
                ) => {
                  return renderEditSelect(label, value, onChange, [
                    { value: true, label: "Sim" },
                    { value: false, label: "Não" }
                  ]);
                };

                const renderEditChips = <T extends string | boolean>(
                  label: string,
                  value: T | null | undefined,
                  onChange: (val: T) => void,
                  options: { value: T; label: string }[]
                ) => {
                  return (
                    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between p-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg shadow-sm space-y-2 sm:space-y-0 transition-all hover:border-slate-300">
                      <span className="text-xs font-bold text-slate-700 dark:text-slate-350 uppercase tracking-wider">{label}</span>
                      <div className="flex items-center space-x-2">
                        {options.map(opt => {
                          const isSelected = value === opt.value;
                          return (
                            <button
                              key={String(opt.value)}
                              type="button"
                              onClick={() => onChange(opt.value)}
                              className={`px-3 py-1 rounded-full text-xs font-semibold border transition-all ${
                                isSelected
                                  ? "bg-amber-500/15 text-amber-600 dark:text-amber-400 border-amber-500/30 font-bold"
                                  : "bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-700"
                              }`}
                            >
                              {opt.label}
                            </button>
                          );
                        })}
                      </div>
                    </div>
                  );
                };

                const renderEditFilterChip = (
                  label: string,
                  value: boolean | null | undefined,
                  onChange: (val: boolean) => void
                ) => {
                  const isSelected = value === true;
                  return (
                    <button
                      type="button"
                      onClick={() => onChange(!isSelected)}
                      className={`p-3 flex items-center justify-between rounded-lg border text-xs font-bold uppercase transition-all ${
                        isSelected
                          ? "bg-amber-500/15 text-amber-600 dark:text-amber-400 border-amber-500/30 shadow-sm"
                          : "bg-white dark:bg-slate-900 text-slate-500 dark:text-slate-400 border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800/40"
                      }`}
                    >
                      <span>{label}</span>
                      <span className={`h-2.5 w-2.5 rounded-full ${isSelected ? "bg-amber-500" : "bg-slate-200 dark:bg-slate-700"}`} />
                    </button>
                  );
                };

                const renderEditTextInput = (
                  label: string, 
                  value: string | null | undefined, 
                  onChange: (val: string) => void, 
                  placeholder = ""
                ) => {
                  return (
                    <div className="space-y-1">
                      <label className="text-xs font-semibold text-slate-500 block uppercase tracking-wider">{label}</label>
                      <Input
                        value={value || ""}
                        onChange={e => onChange(e.target.value)}
                        placeholder={placeholder}
                        className="bg-white dark:bg-slate-900 border-slate-200 dark:border-slate-800 text-sm"
                      />
                    </div>
                  );
                };

                const renderEditTextArea = (
                  label: string, 
                  value: string | null | undefined, 
                  onChange: (val: string) => void, 
                  placeholder = ""
                ) => {
                  return (
                    <div className="space-y-1 col-span-1 sm:col-span-2">
                      <label className="text-xs font-semibold text-slate-500 block uppercase tracking-wider">{label}</label>
                      <textarea
                        value={value || ""}
                        onChange={e => onChange(e.target.value)}
                        placeholder={placeholder}
                        rows={3}
                        className="flex min-h-[60px] w-full rounded-md border border-slate-200 bg-white dark:bg-slate-900 px-3 py-2 text-sm shadow-sm placeholder:text-slate-500 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 disabled:cursor-not-allowed disabled:opacity-50 dark:border-slate-800 dark:text-slate-200"
                      />
                    </div>
                  );
                };

                const renderReadOnlyField = (label: string, value: string | null | undefined) => {
                  return (
                    <div className="space-y-1">
                      <label className="text-xs font-semibold text-slate-400 block uppercase tracking-wider">{label} (Automático)</label>
                      <div className="flex h-9 w-full rounded-md border border-slate-100 bg-slate-50/50 px-3 py-1.5 text-sm text-slate-500 dark:border-slate-850 dark:bg-slate-900/50 dark:text-slate-400 font-medium">
                        {value || "Não definido"}
                      </div>
                    </div>
                  );
                };

                if (typeKey === 'supressao') {
                  const supressao = subData || {};
                  const updateField = (field: string, val: any) => {
                    setEditingVistoria(prev => {
                      if (!prev) return prev;
                      return {
                        ...prev,
                        data: {
                          ...prev.data,
                          supressao: {
                            ...((prev.data as any).supressao || {}),
                            [field]: val
                          }
                        }
                      };
                    });
                  };

                  return (
                    <div className="space-y-6">
                      {/* Bloco 1: Áreas Protegidas */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-emerald-600 dark:text-emerald-400 border-b pb-1 mb-2">
                          1. Áreas Protegidas e Reserva Legal
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Curso d'água, nascente ou lago", supressao.tem_curso_dagua, val => updateField('tem_curso_dagua', val))}
                          {renderEditBoolSelect("APP preservada", supressao.app_preservada, val => updateField('app_preservada', val))}
                          {renderEditBoolSelect("Indícios de uso na APP", supressao.indicios_uso_app, val => updateField('indicios_uso_app', val))}
                          {renderEditBoolSelect("RL isolada", supressao.rl_isolada, val => updateField('rl_isolada', val))}
                          {renderEditBoolSelect("RL compatível", supressao.rl_nativa_compativel, val => updateField('rl_nativa_compativel', val))}
                        </div>
                      </div>

                      {/* Bloco 2: Bioma e Estrutura Florestal */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-emerald-600 dark:text-emerald-400 border-b pb-1 mb-2">
                          2. Bioma e Estrutura Florestal
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditSelect("Bioma Predominante", supressao.bioma, val => {
                            updateField('bioma', val);
                            if (val === 'MA') {
                              updateField('bloco_b_estrutura', null);
                            } else if (val === 'CAATINGA') {
                              updateField('bloco_a_estagio_sucessional', null);
                              updateField('bloco_a_dap_opcao', null);
                              updateField('bloco_a_altura_opcao', null);
                              updateField('bloco_a_serapilheira_opcao', null);
                              updateField('bloco_a_epifitas_opcao', null);
                              updateField('bloco_a_subbosque_opcao', null);
                            }
                          }, [
                            { value: "MA", label: "Mata Atlântica" },
                            { value: "CAATINGA", label: "Caatinga" }
                          ])}

                          {supressao.bioma === 'MA' && (() => {
                            const handleStageChange = (val: string) => {
                              updateField('bloco_a_estagio_sucessional', val);
                              
                              if (val === 'Inicial') {
                                updateField('bloco_a_dap_opcao', 'Até 8 cm');
                                updateField('bloco_a_altura_opcao', 'Até 5 m');
                                updateField('bloco_a_serapilheira_opcao', 'Pouco espessa e descontínua');
                                updateField('bloco_a_epifitas_opcao', 'Ausentes ou muito raras');
                                updateField('bloco_a_subbosque_opcao', 'Pouco desenvolvido');
                              } else if (val === 'Médio') {
                                updateField('bloco_a_dap_opcao', 'Entre 8 e 15 cm');
                                updateField('bloco_a_altura_opcao', 'Entre 5 e 10 m');
                                updateField('bloco_a_serapilheira_opcao', 'Espessa e contínua');
                                updateField('bloco_a_epifitas_opcao', 'Presentes em quantidade moderada');
                                updateField('bloco_a_subbosque_opcao', 'Desenvolvido');
                              } else if (val === 'Avançado') {
                                updateField('bloco_a_dap_opcao', 'Superior a 15 cm');
                                updateField('bloco_a_altura_opcao', 'Superior a 10 m');
                                updateField('bloco_a_serapilheira_opcao', 'Muito espessa, contínua e rica');
                                updateField('bloco_a_epifitas_opcao', 'Muito abundantes e diversas');
                                updateField('bloco_a_subbosque_opcao', 'Muito desenvolvido e estratificado');
                              } else if (val === 'Não se Aplica') {
                                updateField('bloco_a_dap_opcao', 'Não se Aplica');
                                updateField('bloco_a_altura_opcao', 'Não se Aplica');
                                updateField('bloco_a_serapilheira_opcao', 'Ausente');
                                updateField('bloco_a_epifitas_opcao', 'Não se Aplica');
                                updateField('bloco_a_subbosque_opcao', 'Não se Aplica');
                              } else {
                                updateField('bloco_a_dap_opcao', null);
                                updateField('bloco_a_altura_opcao', null);
                                updateField('bloco_a_serapilheira_opcao', null);
                                updateField('bloco_a_epifitas_opcao', null);
                                updateField('bloco_a_subbosque_opcao', null);
                              }
                            };

                            return (
                              <>
                                {renderEditSelect("Estágio Sucessional", supressao.bloco_a_estagio_sucessional, handleStageChange, [
                                  { value: "Inicial", label: "Inicial" },
                                  { value: "Médio", label: "Médio" },
                                  { value: "Avançado", label: "Avançado" },
                                  { value: "Não se Aplica", label: "Não se Aplica" }
                                ])}
                                {renderReadOnlyField("DAP Médio", supressao.bloco_a_dap_opcao)}
                                {renderReadOnlyField("Altura / Dossel", supressao.bloco_a_altura_opcao)}
                                {renderReadOnlyField("Serapilheira", supressao.bloco_a_serapilheira_opcao)}
                                {renderReadOnlyField("Epífitas", supressao.bloco_a_epifitas_opcao)}
                                {renderReadOnlyField("Sub-bosque", supressao.bloco_a_subbosque_opcao)}
                                {renderEditTextArea("Observações da Mata Atlântica", supressao.bloco_a_observacoes, val => updateField('bloco_a_observacoes', val))}
                              </>
                            );
                          })()}

                          {supressao.bioma === 'CAATINGA' && (
                            <div className="col-span-1 sm:col-span-2">
                              {renderEditSelect("Estrutura Florestal (Caatinga)", supressao.bloco_b_estrutura, val => updateField('bloco_b_estrutura', val), [
                                { value: "Herbáceo-Arbustiva (Fase inicial / Rala)", label: "Herbáceo-Arbustiva (Fase inicial / Rala)" },
                                { value: "Arbustiva-Arbórea (Fase intermediária)", label: "Arbustiva-Arbórea (Fase intermediária)" },
                                { value: "Arbórea Fechada (Fase tardia / Densa)", label: "Arbórea Fechada (Fase tardia / Densa)" }
                              ])}
                            </div>
                          )}
                        </div>
                      </div>

                      {/* Bloco 3: Espécies Exóticas */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-emerald-600 dark:text-emerald-400 border-b pb-1 mb-2">
                          3. Espécies Exóticas e Invasoras
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Presença de Invasoras", supressao.presenca_invasoras, val => updateField('presenca_invasoras', val))}
                          {renderEditBoolSelect("Presença de Exóticas", supressao.presenca_exoticas, val => updateField('presenca_exoticas', val))}
                          {renderEditTextInput("Espécies Identificadas", supressao.especies, val => updateField('especies', val), "Ex: Leucena, Pinus")}
                          {renderEditSelect("Grau de Infestação", supressao.grau_infestacao, val => updateField('grau_infestacao', val), [
                            { value: "Nenhum", label: "Nenhum" },
                            { value: "Baixo — Indivíduos isolados", label: "Baixo — Indivíduos isolados" },
                            { value: "Médio — Pequenos adensamentos", label: "Médio — Pequenos adensamentos" },
                            { value: "Alto — Domínio de área significativo", label: "Alto — Domínio de área significativo" }
                          ])}
                        </div>
                      </div>

                      {/* Bloco 4: Localização da Supressão */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-emerald-600 dark:text-emerald-400 border-b pb-1 mb-2">
                          4. Localização da Supressão / Intervenção
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditTextInput("Ocorre em APP?", supressao.loc_app, val => updateField('loc_app', val), "Ex: Sim, no terço médio da encosta")}
                          {renderEditTextInput("Ocorre em Reserva Legal?", supressao.loc_rl, val => updateField('loc_rl', val), "Ex: Não ocorre")}
                          {renderEditTextInput("Ocorre em UAS (Uso Alternativo do Solo)?", supressao.loc_uas, val => updateField('loc_uas', val), "Ex: Sim, na área plana de pasto")}
                        </div>
                      </div>

                      {/* Bloco 5: Fatores de Degradação */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-emerald-600 dark:text-emerald-400 border-b pb-1 mb-2">
                          5. Fatores de Degradação e Registro
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Pastos Abandonados", supressao.pastos_abandonados, val => updateField('pastos_abandonados', val))}
                          {renderEditBoolSelect("Indícios de Supressão", supressao.supressao_solo, val => updateField('supressao_solo', val))}
                          {renderEditBoolSelect("Registro fotográfico georreferenciado ok", supressao.foto_geo_ok, val => updateField('foto_geo_ok', val))}
                          <div className="col-span-1 sm:col-span-2 border-t pt-3 space-y-2">
                            <span className="text-[10px] font-bold uppercase text-slate-400 block">Indícios de Ocorrência de Fogo/Incêndio:</span>
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                              {renderEditBoolSelect("Fogo em APP", supressao.fogo_app, val => updateField('fogo_app', val))}
                              {renderEditBoolSelect("Fogo em RL", supressao.fogo_rl, val => updateField('fogo_rl', val))}
                              {renderEditBoolSelect("Fogo em UAS", supressao.fogo_uas, val => updateField('fogo_uas', val))}
                              {renderEditBoolSelect("Fogo em outras áreas", supressao.fogo_outras, val => updateField('fogo_outras', val))}
                            </div>
                          </div>
                        </div>
                      </div>

                      {/* Bloco 6: Diagnóstico e Fiscalização (DIFI) */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-rose-600 dark:text-rose-400 border-b pb-1 mb-2">
                          6. Diagnóstico Administrativo e Fiscalização (DIFI)
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditTextArea("Infração Constatada / Descrição", supressao.infracao, val => updateField('infracao', val), "Descreva a infração constatada, se houver.")}
                          {renderEditTextArea("Medidas Sugeridas à DIFI", supressao.medida_sugerida, val => updateField('medida_sugerida', val), "Ex: Notificação, Embargo, Auto de Infração...")}
                          {renderEditTextArea("Observações Técnicas Gerais", supressao.observacoes, val => updateField('observacoes', val), "Acrescente quaisquer observações adicionais relativas à vistoria.")}
                        </div>
                      </div>
                    </div>
                  );
                } else if (typeKey === 'avicultura') {
                  const avicultura = subData || {};
                  
                  const updateField = (field: string, val: any) => {
                    setEditingVistoria(prev => {
                      if (!prev) return prev;
                      const currentAvi = (prev.data as any).avicultura || {};
                      const updatedAvicultura = {
                        ...currentAvi,
                        [field]: val
                      };

                      // Mutual exclusivity rules
                      if (field === 'corte_galpoes_longos' && val === true) {
                        updatedAvicultura.corte_galpoes_curtos = false;
                      } else if (field === 'corte_galpoes_curtos' && val === true) {
                        updatedAvicultura.corte_galpoes_longos = false;
                      } else if (field === 'corte_bebedouros_chao' && val === true) {
                        updatedAvicultura.corte_bebedouros_suspensos = false;
                      } else if (field === 'corte_bebedouros_suspensos' && val === true) {
                        updatedAvicultura.corte_bebedouros_chao = false;
                      } else if (field === 'corte_comedouros_chao' && val === true) {
                        updatedAvicultura.corte_comedouros_suspensos = false;
                      } else if (field === 'corte_comedouros_suspensos' && val === true) {
                        updatedAvicultura.corte_comedouros_chao = false;
                      } else if (field === 'corte_ventiladores') {
                        if (val === true) {
                          updatedAvicultura.corte_sem_ventiladores = false;
                        } else {
                          updatedAvicultura.corte_ventiladores_func = false;
                        }
                      } else if (field === 'corte_ventiladores_func' && val === true) {
                        updatedAvicultura.corte_ventiladores = true;
                        updatedAvicultura.corte_sem_ventiladores = false;
                      } else if (field === 'corte_sem_ventiladores' && val === true) {
                        updatedAvicultura.corte_ventiladores = false;
                        updatedAvicultura.corte_ventiladores_func = false;
                      }

                      // Realtime calculations for CORTE
                      if (field === 'corte_comprimento' || field === 'corte_largura' || field === 'corte_densidade') {
                        const comp = Number(field === 'corte_comprimento' ? val : updatedAvicultura.corte_comprimento || 0);
                        const larg = Number(field === 'corte_largura' ? val : updatedAvicultura.corte_largura || 0);
                        const area = comp * larg;
                        const densidade = (field === 'corte_densidade' ? val : updatedAvicultura.corte_densidade) || 'Convencional (12 a 15 aves/m²)';
                        const densidadeStr = String(densidade);
                        let factor = 13.5;
                        if (densidadeStr.includes('Climatizado') || densidadeStr.includes('Pressão Negativa')) factor = 20;
                        else if (densidadeStr.includes('fechado') || densidadeStr.includes('vedado')) factor = 15;
                        else if (densidadeStr.includes('exaustores')) factor = 16;

                        updatedAvicultura.corte_area = area;
                        updatedAvicultura.corte_qtd_estimada = Math.round(area * factor);
                      }

                      // Realtime calculations for POSTURA
                      if (field === 'postura_fileiras' || field === 'postura_andares' || field === 'postura_gaiolas_modulo' || field === 'postura_aves_gaiola') {
                        const fil = Number(field === 'postura_fileiras' ? val : updatedAvicultura.postura_fileiras || 0);
                        const and = Number(field === 'postura_andares' ? val : updatedAvicultura.postura_andares || 0);
                        const gai = Number(field === 'postura_gaiolas_modulo' ? val : updatedAvicultura.postura_gaiolas_modulo || 0);
                        const ave = Number(field === 'postura_aves_gaiola' ? val : updatedAvicultura.postura_aves_gaiola || 0);
                        updatedAvicultura.postura_qtd_estimada = fil * and * gai * ave;
                      }

                      return {
                        ...prev,
                        data: {
                          ...prev.data,
                          avicultura: updatedAvicultura
                        }
                      };
                    });
                  };

                  const isCorte = (avicultura.modelo || '').toUpperCase() === 'CORTE';

                  return (
                    <div className="space-y-6">
                      {/* Bloco 1: Modelo de Operação */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-amber-600 dark:text-amber-400 border-b pb-1 mb-2">
                          1. Modelo de Produção
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditSelect("Modelo Principal", avicultura.modelo, val => {
                            updateField('modelo', val);
                            if (val === 'CORTE') {
                              updateField('postura_sistema_criacao', null);
                              updateField('postura_tipo_confinamento', null);
                              updateField('postura_info_adicional', null);
                              updateField('postura_fileiras', null);
                              updateField('postura_andares', null);
                              updateField('postura_gaiolas_modulo', null);
                              updateField('postura_aves_gaiola', null);
                              updateField('postura_qtd_estimada', null);
                            } else {
                              updateField('corte_sistema_criacao', null);
                              updateField('corte_aves_soltas_chao', null);
                              updateField('corte_cama_casca_arroz', null);
                              updateField('corte_galpoes_longos', null);
                              updateField('corte_galpoes_curtos', null);
                              updateField('corte_bebedouros_chao', null);
                              updateField('corte_bebedouros_suspensos', null);
                              updateField('corte_comedouros_chao', null);
                              updateField('corte_comedouros_suspensos', null);
                              updateField('corte_pintos', null);
                              updateField('corte_frangos', null);
                              updateField('corte_ventiladores', null);
                              updateField('corte_ventiladores_func', null);
                              updateField('corte_sem_ventiladores', null);
                              updateField('corte_info_adicional', null);
                              updateField('corte_comprimento', null);
                              updateField('corte_largura', null);
                              updateField('corte_area', null);
                              updateField('corte_densidade', null);
                              updateField('corte_qtd_estimada', null);
                              updateField('corte_cama_destinacao', null);
                              updateField('corte_cama_outros', null);
                            }
                          }, [
                            { value: "CORTE", label: "Corte (Frango)" },
                            { value: "POSTURA", label: "Postura (Ovos)" }
                          ])}
                        </div>
                      </div>

                      {/* Bloco 2: Corte */}
                      {isCorte && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-4">
                          <h4 className="text-xs font-bold uppercase text-amber-600 dark:text-amber-400 border-b pb-1">
                            2. Avicultura de Corte - Parâmetros Técnicos
                          </h4>
                          <div className="grid grid-cols-1 gap-3">
                            {renderEditChips("Sistema de Criação", avicultura.corte_sistema_criacao, val => updateField('corte_sistema_criacao', val), [
                              { value: "Soltas", label: "Soltas" },
                              { value: "Confinadas", label: "Confinadas" }
                            ])}
                            {renderEditChips("Densidade Recomendada", avicultura.corte_densidade, val => updateField('corte_densidade', val), [
                              { value: "Convencional (12 a 15 aves/m²)", label: "Convencional (12-15/m²)" },
                              { value: "Galpão fechado com exaustores (15 a 17 aves/m²)", label: "Galpão Fechado (15-17/m²)" },
                              { value: "Galpão climatizado / Pressão Negativa (18 a 22 aves/m²)", label: "Climatizado (18-22/m²)" }
                            ])}
                          </div>

                          <div className="border-t pt-3">
                            <span className="text-xs font-bold uppercase text-slate-400 block mb-2">Características Observadas no Galpão</span>
                            <div className="grid grid-cols-1 gap-3">
                              {renderEditChips("Manejo no Chão / Cama", avicultura.corte_aves_soltas_chao ? "SOLTAS" : avicultura.corte_cama_casca_arroz ? "CAMA" : null, val => {
                                updateField('corte_aves_soltas_chao', val === "SOLTAS");
                                updateField('corte_cama_casca_arroz', val === "CAMA");
                              }, [
                                { value: "SOLTAS", label: "Soltas no Chão" },
                                { value: "CAMA", label: "Sobre Cama" }
                              ])}

                              {renderEditChips("Dimensão do Galpão", avicultura.corte_galpoes_longos ? "LONGOS" : avicultura.corte_galpoes_curtos ? "CURTOS" : null, val => {
                                updateField('corte_galpoes_longos', val === "LONGOS");
                                updateField('corte_galpoes_curtos', val === "CURTOS");
                              }, [
                                { value: "LONGOS", label: "Galpões Longos" },
                                { value: "CURTOS", label: "Galpões Curtos" }
                              ])}

                              {renderEditChips("Bebedouros", avicultura.corte_bebedouros_chao ? "CHAO" : avicultura.corte_bebedouros_suspensos ? "SUSPENSOS" : null, val => {
                                updateField('corte_bebedouros_chao', val === "CHAO");
                                updateField('corte_bebedouros_suspensos', val === "SUSPENSOS");
                              }, [
                                { value: "CHAO", label: "No Chão" },
                                { value: "SUSPENSOS", label: "Suspensos" }
                              ])}

                              {renderEditChips("Comedouros", avicultura.corte_comedouros_chao ? "CHAO" : avicultura.corte_comedouros_suspensos ? "SUSPENSOS" : null, val => {
                                updateField('corte_comedouros_chao', val === "CHAO");
                                updateField('corte_comedouros_suspensos', val === "SUSPENSOS");
                              }, [
                                { value: "CHAO", label: "No Chão" },
                                { value: "SUSPENSOS", label: "Suspensos" }
                              ])}

                              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                {renderEditFilterChip("Pintos (Fase Inicial)", avicultura.corte_pintos, val => updateField('corte_pintos', val))}
                                {renderEditFilterChip("Frangos (Fase Engorda)", avicultura.corte_frangos, val => updateField('corte_frangos', val))}
                              </div>

                              {renderEditChips("Ventilação no Galpão", avicultura.corte_ventiladores ? "POSSUI" : avicultura.corte_sem_ventiladores ? "NAO_POSSUI" : null, val => {
                                updateField('corte_ventiladores', val === "POSSUI");
                                updateField('corte_sem_ventiladores', val === "NAO_POSSUI");
                                if (val !== "POSSUI") {
                                  updateField('corte_ventiladores_func', false);
                                }
                              }, [
                                { value: "POSSUI", label: "Possui Ventiladores" },
                                { value: "NAO_POSSUI", label: "Não Possui" }
                              ])}

                              {avicultura.corte_ventiladores === true && (
                                <div className="mt-1">
                                  {renderEditFilterChip("Ventiladores Funcionando Adequadamente", avicultura.corte_ventiladores_func, val => updateField('corte_ventiladores_func', val))}
                                </div>
                              )}
                            </div>
                          </div>

                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 border-t pt-3">
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Comprimento do Galpão (m)</label>
                              <Input
                                type="number"
                                value={avicultura.corte_comprimento === null || avicultura.corte_comprimento === undefined ? '' : avicultura.corte_comprimento}
                                onChange={e => updateField('corte_comprimento', Number(e.target.value))}
                                placeholder="Ex: 100"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Largura do Galpão (m)</label>
                              <Input
                                type="number"
                                value={avicultura.corte_largura === null || avicultura.corte_largura === undefined ? '' : avicultura.corte_largura}
                                onChange={e => updateField('corte_largura', Number(e.target.value))}
                                placeholder="Ex: 12"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                            {renderReadOnlyField("Área Calculada (m²)", avicultura.corte_area ? `${avicultura.corte_area.toFixed(2)} m²` : '0 m²')}
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Estimativa de Animais</label>
                              <Input
                                type="number"
                                value={avicultura.corte_qtd_estimada === null || avicultura.corte_qtd_estimada === undefined ? '' : avicultura.corte_qtd_estimada}
                                onChange={e => updateField('corte_qtd_estimada', e.target.value === '' ? null : Number(e.target.value))}
                                placeholder="Ex: 24000"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                          </div>

                          <div className="border-t pt-3 space-y-3">
                            {renderEditChips("Destinação da Cama de Frango", avicultura.corte_cama_destinacao, val => updateField('corte_cama_destinacao', val), [
                              { value: "Compostagem", label: "Compostagem" },
                              { value: "Alimentação animal", label: "Alimentação Animal" },
                              { value: "Adubos em geral", label: "Adubos em Geral" },
                              { value: "Outros", label: "Outros" }
                            ])}
                            {avicultura.corte_cama_destinacao === 'Outros' && renderEditTextInput("Especifique a Destinação", avicultura.corte_cama_outros, val => updateField('corte_cama_outros', val))}
                          </div>

                          {renderEditTextArea("Observações da Avicultura de Corte", avicultura.corte_info_adicional, val => updateField('corte_info_adicional', val))}
                        </div>
                      )}

                      {/* Bloco 3: Postura */}
                      {!isCorte && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-4">
                          <h4 className="text-xs font-bold uppercase text-amber-600 dark:text-amber-400 border-b pb-1">
                            2. Avicultura de Postura - Parâmetros Técnicos
                          </h4>
                          <div className="grid grid-cols-1 gap-3">
                            {renderEditChips("Sistema de Criação", avicultura.postura_sistema_criacao, val => updateField('postura_sistema_criacao', val), [
                              { value: "Soltas", label: "Soltas" },
                              { value: "Confinadas", label: "Confinadas" }
                            ])}
                            {renderEditChips("Tipo de Confinamento", avicultura.postura_tipo_confinamento, val => updateField('postura_tipo_confinamento', val), [
                              { value: "Gaiolas suspensas", label: "Gaiolas Suspensas" },
                              { value: "Gaiolas em andares", label: "Gaiolas em Andares" },
                              { value: "Outro tipo", label: "Outro Tipo" }
                            ])}
                          </div>

                          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 border-t pt-3">
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Nº Fileiras</label>
                              <Input
                                type="number"
                                value={avicultura.postura_fileiras === null || avicultura.postura_fileiras === undefined ? '' : avicultura.postura_fileiras}
                                onChange={e => updateField('postura_fileiras', Number(e.target.value))}
                                placeholder="Ex: 4"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Nº Andares</label>
                              <Input
                                type="number"
                                value={avicultura.postura_andares === null || avicultura.postura_andares === undefined ? '' : avicultura.postura_andares}
                                onChange={e => updateField('postura_andares', Number(e.target.value))}
                                placeholder="Ex: 3"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Gaiolas / Módulo</label>
                              <Input
                                type="number"
                                value={avicultura.postura_gaiolas_modulo === null || avicultura.postura_gaiolas_modulo === undefined ? '' : avicultura.postura_gaiolas_modulo}
                                onChange={e => updateField('postura_gaiolas_modulo', Number(e.target.value))}
                                placeholder="Ex: 10"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Aves / Gaiola</label>
                              <Input
                                type="number"
                                value={avicultura.postura_aves_gaiola === null || avicultura.postura_aves_gaiola === undefined ? '' : avicultura.postura_aves_gaiola}
                                onChange={e => updateField('postura_aves_gaiola', Number(e.target.value))}
                                placeholder="Ex: 5"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                            <div className="col-span-2 sm:col-span-4 space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Estimativa Total de Aves</label>
                              <Input
                                type="number"
                                value={avicultura.postura_qtd_estimada === null || avicultura.postura_qtd_estimada === undefined ? '' : avicultura.postura_qtd_estimada}
                                onChange={e => updateField('postura_qtd_estimada', e.target.value === '' ? null : Number(e.target.value))}
                                placeholder="Ex: 1200"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                          </div>

                          {renderEditTextArea("Observações da Avicultura de Postura", avicultura.postura_info_adicional, val => updateField('postura_info_adicional', val))}
                        </div>
                      )}

                      {/* Bloco 4: Resíduos e Segurança Ambiental */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-emerald-600 dark:text-emerald-400 border-b pb-1 mb-2">
                          3. Segurança Ambiental e Resíduos
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Gera Resíduos", avicultura.gera_residuos, val => updateField('gera_residuos', val))}
                          {renderEditBoolSelect("Animais Mortos Incinerados", avicultura.mortos_incinerados, val => updateField('mortos_incinerados', val))}
                          {renderEditBoolSelect("Registro fotográfico georreferenciado ok", avicultura.foto_geo_ok, val => updateField('foto_geo_ok', val))}
                        </div>
                        {avicultura.gera_residuos && renderEditTextArea("Detalhes dos Resíduos", avicultura.residuos_detalhes, val => updateField('residuos_detalhes', val), "Descreva a geração e controle de resíduos")}
                        {!avicultura.mortos_incinerados && renderEditTextArea("Destinação Alternativa de Animais Mortos", avicultura.mortos_destinacao_alt, val => updateField('mortos_destinacao_alt', val), "Informe como é feita a destinação")}
                      </div>

                      {/* Bloco 5: Diagnóstico e Fiscalização (DIFI) */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-rose-600 dark:text-rose-400 border-b pb-1 mb-2">
                          4. Diagnóstico Administrativo e Fiscalização (DIFI)
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditBoolSelect("Infração Constatada", avicultura.infracao_constatada, val => updateField('infracao_constatada', val))}
                          {renderEditTextArea("Medidas Sugeridas à DIFI", avicultura.medida_sugerida, val => updateField('medida_sugerida', val), "Ex: Notificação, Embargo, Auto de Infração...")}
                          {renderEditTextArea("Observações Técnicas Gerais", avicultura.observacoes, val => updateField('observacoes', val), "Acrescente quaisquer observações adicionais relativas à vistoria.")}
                        </div>
                      </div>
                    </div>
                  );
                } else if (typeKey === 'suinocultura') {
                  const suinocultura = subData || {};
                  
                  const updateField = (field: string, val: any) => {
                    setEditingVistoria(prev => {
                      if (!prev) return prev;
                      const currentSui = (prev.data as any).suinocultura || {};
                      const updatedSuinocultura = {
                        ...currentSui,
                        [field]: val
                      };

                      // Calculations for legacy compatibility
                      const mod = updatedSuinocultura.modelo || 'CAIPIRA';
                      const qGalpoes = Number(updatedSuinocultura.qtd_galpoes === null || updatedSuinocultura.qtd_galpoes === undefined ? 0 : updatedSuinocultura.qtd_galpoes);
                      const qMedio = Number(updatedSuinocultura.qtd_medio_por_galpao === null || updatedSuinocultura.qtd_medio_por_galpao === undefined ? 0 : updatedSuinocultura.qtd_medio_por_galpao);
                      
                      let totalAnimais = qGalpoes * qMedio;
                      
                      if (mod === 'CAIPIRA' && qGalpoes === 0) {
                        const termQtd = parseInt(updatedSuinocultura.fase_terminacao_qtd || '0', 10) || 0;
                        const matQtd = parseInt(updatedSuinocultura.fase_matrizes_qtd || '0', 10) || 0;
                        const repQtd = parseInt(updatedSuinocultura.fase_reprodutores_qtd || '0', 10) || 0;
                        const adQtd = parseInt(updatedSuinocultura.fase_adulto_qtd || '0', 10) || 0;
                        totalAnimais = termQtd + matQtd + repQtd + adQtd;
                      }
                      
                      updatedSuinocultura.qtd_animais = totalAnimais;

                      // Populate legacy fase_producao
                      const activePhases: string[] = [];
                      if (updatedSuinocultura.fase_terminacao) activePhases.push('Terminação');
                      if (updatedSuinocultura.fase_matrizes) activePhases.push('Matrizes Gestantes');
                      if (updatedSuinocultura.fase_reprodutores) activePhases.push('Reprodutores');
                      if (updatedSuinocultura.fase_adulto) activePhases.push('Suíno Adulto');
                      updatedSuinocultura.fase_producao = activePhases.join(', ');

                      // Populate legacy dejetos_destinacao
                      updatedSuinocultura.dejetos_destinacao = updatedSuinocultura.destinacao_adequada 
                        ? 'Adequada' 
                        : 'Inadequada ou não informada';

                      // Map conformidade = !infracao_constatada
                      updatedSuinocultura.conformidade = !updatedSuinocultura.infracao_constatada;

                      return {
                        ...prev,
                        data: {
                          ...prev.data,
                          suinocultura: updatedSuinocultura
                        }
                      };
                    });
                  };

                  const isIndustrial = (suinocultura.modelo || '').toUpperCase() === 'INDUSTRIAL';

                  return (
                    <div className="space-y-6">
                      {/* Bloco 1: Modelo de Produção */}
                      <div className="bg-pink-50/20 dark:bg-pink-950/5 p-4 rounded-lg border border-pink-100 dark:border-pink-950/20 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-pink-600 dark:text-pink-400 border-b pb-1 mb-2">
                          1. Modelo de Produção
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditSelect("Modelo Principal", suinocultura.modelo, val => {
                            updateField('modelo', val);
                          }, [
                            { value: "CAIPIRA", label: "Caipira" },
                            { value: "INDUSTRIAL", label: "Industrial" }
                          ])}
                          <div className="text-[11px] text-slate-500 bg-white dark:bg-slate-900/40 p-2.5 rounded border border-slate-100 dark:border-slate-800 leading-relaxed">
                            <span className="font-bold block text-slate-700 dark:text-slate-300 mb-1">Dica de identificação:</span>
                            {isIndustrial ? (
                              <span className="block">• <strong>INDUSTRIAL</strong>: Baias de concreto, canaletas, piso ripado, estrutura de grande escala e confinamento completo.</span>
                            ) : (
                              <span className="block">• <strong>CAIPIRA</strong>: Animais com acesso a piquetes externos, estrutura mais simples e aberta, menor densidade.</span>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* Bloco 2: Capacidade e Infraestrutura */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-4">
                        <h4 className="text-xs font-bold uppercase text-pink-600 dark:text-pink-400 border-b pb-1">
                          2. Capacidade e Infraestrutura
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Nº de Galpões</label>
                            <Input
                              type="number"
                              value={suinocultura.qtd_galpoes === null || suinocultura.qtd_galpoes === undefined ? '' : suinocultura.qtd_galpoes}
                              onChange={e => updateField('qtd_galpoes', e.target.value === '' ? null : Number(e.target.value))}
                              placeholder="Ex: 2"
                              className="bg-white dark:bg-slate-900"
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Quantidade Média por Galpão</label>
                            <Input
                              type="number"
                              value={suinocultura.qtd_medio_por_galpao === null || suinocultura.qtd_medio_por_galpao === undefined ? '' : suinocultura.qtd_medio_por_galpao}
                              onChange={e => updateField('qtd_medio_por_galpao', e.target.value === '' ? null : Number(e.target.value))}
                              placeholder="Ex: 50"
                              className="bg-white dark:bg-slate-900"
                            />
                          </div>
                          {renderReadOnlyField("Quantidade Total Calculada", suinocultura.qtd_animais ? `${suinocultura.qtd_animais} animais` : '0 animais')}
                        </div>

                        {/* Fases */}
                        <div className="border-t pt-3">
                          <span className="text-xs font-bold uppercase text-slate-400 block mb-3">Fases de Produção & Estimativas</span>
                          <div className="grid grid-cols-1 gap-4">
                            {/* Fase Terminação */}
                            <div className="flex flex-col sm:flex-row sm:items-center justify-between p-3 bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-lg shadow-sm space-y-2 sm:space-y-0">
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => updateField('fase_terminacao', !suinocultura.fase_terminacao)}
                                  className={`px-3 py-1.5 rounded-full text-xs font-bold border transition-all ${
                                    suinocultura.fase_terminacao
                                      ? "bg-pink-500/15 text-pink-600 dark:text-pink-400 border-pink-500/30"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-500 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  Terminação
                                </button>
                              </div>
                              {suinocultura.fase_terminacao && (
                                <div className="w-full sm:w-48">
                                  <Input
                                    value={suinocultura.fase_terminacao_qtd || ''}
                                    onChange={e => updateField('fase_terminacao_qtd', e.target.value)}
                                    placeholder="Estimativa (Ex: 100)"
                                    className="bg-white dark:bg-slate-900 text-xs h-8"
                                  />
                                </div>
                              )}
                            </div>

                            {/* Fase Matrizes */}
                            <div className="flex flex-col sm:flex-row sm:items-center justify-between p-3 bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-lg shadow-sm space-y-2 sm:space-y-0">
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => updateField('fase_matrizes', !suinocultura.fase_matrizes)}
                                  className={`px-3 py-1.5 rounded-full text-xs font-bold border transition-all ${
                                    suinocultura.fase_matrizes
                                      ? "bg-pink-500/15 text-pink-600 dark:text-pink-400 border-pink-500/30"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-500 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  Matrizes Gestantes
                                </button>
                              </div>
                              {suinocultura.fase_matrizes && (
                                <div className="w-full sm:w-48">
                                  <Input
                                    value={suinocultura.fase_matrizes_qtd || ''}
                                    onChange={e => updateField('fase_matrizes_qtd', e.target.value)}
                                    placeholder="Estimativa (Ex: 20)"
                                    className="bg-white dark:bg-slate-900 text-xs h-8"
                                  />
                                </div>
                              )}
                            </div>

                            {/* Fase Reprodutores */}
                            <div className="flex flex-col sm:flex-row sm:items-center justify-between p-3 bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-lg shadow-sm space-y-2 sm:space-y-0">
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => updateField('fase_reprodutores', !suinocultura.fase_reprodutores)}
                                  className={`px-3 py-1.5 rounded-full text-xs font-bold border transition-all ${
                                    suinocultura.fase_reprodutores
                                      ? "bg-pink-500/15 text-pink-600 dark:text-pink-400 border-pink-500/30"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-500 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  Reprodutores
                                </button>
                              </div>
                              {suinocultura.fase_reprodutores && (
                                <div className="w-full sm:w-48">
                                  <Input
                                    value={suinocultura.fase_reprodutores_qtd || ''}
                                    onChange={e => updateField('fase_reprodutores_qtd', e.target.value)}
                                    placeholder="Estimativa (Ex: 5)"
                                    className="bg-white dark:bg-slate-900 text-xs h-8"
                                  />
                                </div>
                              )}
                            </div>

                            {/* Fase Adulto */}
                            <div className="flex flex-col sm:flex-row sm:items-center justify-between p-3 bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-lg shadow-sm space-y-2 sm:space-y-0">
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => updateField('fase_adulto', !suinocultura.fase_adulto)}
                                  className={`px-3 py-1.5 rounded-full text-xs font-bold border transition-all ${
                                    suinocultura.fase_adulto
                                      ? "bg-pink-500/15 text-pink-600 dark:text-pink-400 border-pink-500/30"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-500 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  Suíno Adulto
                                </button>
                              </div>
                              {suinocultura.fase_adulto && (
                                <div className="w-full sm:w-48">
                                  <Input
                                    value={suinocultura.fase_adulto_qtd || ''}
                                    onChange={e => updateField('fase_adulto_qtd', e.target.value)}
                                    placeholder="Estimativa (Ex: 50)"
                                    className="bg-white dark:bg-slate-900 text-xs h-8"
                                  />
                                </div>
                              )}
                            </div>
                          </div>
                        </div>
                      </div>

                      {/* Bloco 3: Segurança Sanitária e Ambiental */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-emerald-600 dark:text-emerald-400 border-b pb-1 mb-2">
                          3. Segurança Sanitária e Ambiental
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Existe acúmulo de resíduos?", suinocultura.acumulo_residuos, val => updateField('acumulo_residuos', val))}
                          {renderEditBoolSelect("Há vazamento de dejetos para fora?", suinocultura.vazamento_dejetos, val => updateField('vazamento_dejetos', val))}
                          {renderEditBoolSelect("Há odor extremo?", suinocultura.odor_extremo, val => updateField('odor_extremo', val))}
                          {renderEditBoolSelect("Os dejetos estão transbordando?", suinocultura.dejetos_transbordando, val => updateField('dejetos_transbordando', val))}
                          {renderEditBoolSelect("Existe sistema de impermeabilização/contenção?", suinocultura.impermeabilizacao_contencao, val => updateField('impermeabilizacao_contencao', val))}
                          {renderEditBoolSelect("Existe destinação adequada/tratamento?", suinocultura.destinacao_adequada, val => updateField('destinacao_adequada', val))}
                        </div>
                      </div>

                      {/* Bloco 4: Manejo e Destinação Animal */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-4">
                        <h4 className="text-xs font-bold uppercase text-pink-600 dark:text-pink-400 border-b pb-1">
                          4. Manejo e Destinação Animal
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Indícios de porte maior ou manejo inadequado?", suinocultura.indicios_porte_maior, val => updateField('indicios_porte_maior', val))}
                          {renderEditBoolSelect("Animais mortos são incinerados?", suinocultura.mortos_incinerados, val => updateField('mortos_incinerados', val))}
                        </div>

                        {suinocultura.indicios_porte_maior && (
                          <div className="mt-2">
                            {renderEditTextArea("Detalhes do Porte/Manejo Inadequado", suinocultura.indicios_porte_maior_detalhe, val => updateField('indicios_porte_maior_detalhe', val), "Detalhar indícios identificados...")}
                          </div>
                        )}

                        {!suinocultura.mortos_incinerados && (
                          <div className="mt-2">
                            {renderEditTextInput("Qual o destino dos animais mortos?", suinocultura.mortos_destino, val => updateField('mortos_destino', val), "Ex: Compostagem, Fossa Séptica, etc.")}
                          </div>
                        )}
                      </div>

                      {/* Bloco 5: Diagnóstico DIFI */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-rose-600 dark:text-rose-400 border-b pb-1 mb-2">
                          5. Diagnóstico Administrativo e Fiscalização (DIFI)
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditBoolSelect("Registro fotográfico georreferenciado ok?", suinocultura.foto_geo_ok, val => updateField('foto_geo_ok', val))}
                          {renderEditBoolSelect("Constatação de Infração?", suinocultura.infracao_constatada, val => updateField('infracao_constatada', val))}
                          {renderEditTextArea("Medidas Sugeridas à DIFI", suinocultura.medida_sugerida, val => updateField('medida_sugerida', val), "Ex: Notificação, Embargo, Auto de Infração...")}
                          {renderEditTextArea("Observações Técnicas Gerais", suinocultura.observacoes, val => updateField('observacoes', val), "Acrescente quaisquer observações adicionais relativas à vistoria.")}
                        </div>
                      </div>
                    </div>
                  );
                } else if (typeKey === 'bovinocultura') {
                  const bov = subData || {};
                  
                  const updateField = (field: string, val: any) => {
                    setEditingVistoria(prev => {
                      if (!prev) return prev;
                      const currentBov = (prev.data as any).bovinocultura || {};
                      const updatedBovinocultura = {
                        ...currentBov,
                        [field]: val
                      };

                      return {
                        ...prev,
                        data: {
                          ...prev.data,
                          bovinocultura: updatedBovinocultura
                        }
                      };
                    });
                  };

                  const isIntensivo = (bov.modelo || '').toUpperCase() === 'INTENSIVO';

                  return (
                    <div className="space-y-6">
                      {/* Bloco 1: Modelo de Produção */}
                      <div className="bg-amber-50/20 dark:bg-amber-950/5 p-4 rounded-lg border border-amber-100 dark:border-amber-950/20 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-amber-600 dark:text-amber-400 border-b pb-1 mb-2">
                          1. Modelo de Criação
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditSelect("Modelo Principal", bov.modelo, val => {
                            updateField('modelo', val);
                          }, [
                            { value: "EXTENSIVO", label: "Extensivo (Pasto)" },
                            { value: "INTENSIVO", label: "Intensivo (Confinamento)" }
                          ])}
                          <div className="text-[11px] text-slate-500 bg-white dark:bg-slate-900/40 p-2.5 rounded border border-slate-100 dark:border-slate-800 leading-relaxed">
                            <span className="font-bold block text-slate-700 dark:text-slate-350 mb-1">Dica de identificação:</span>
                            {isIntensivo ? (
                              <span className="block">• <strong>INTENSIVO</strong>: Currais de engorda, cochos fixos (concreto), linha de trato onde o alimento é distribuído, e alta concentração de animais por área.</span>
                            ) : (
                              <span className="block">• <strong>EXTENSIVO</strong>: Animais soltos em áreas amplas de pastagem. Nota: Se o pasto estiver muito desgastado, solo exposto e superlotação, o sistema pode estar intensificado.</span>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* Bloco 2: Capacidade e Infraestrutura */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-4">
                        <h4 className="text-xs font-bold uppercase text-amber-600 dark:text-amber-400 border-b pb-1">
                          2. Capacidade e Infraestrutura
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Área Destinada à Criação (ha)</label>
                            <Input
                              type="number"
                              step="0.01"
                              value={bov.area_ha === null || bov.area_ha === undefined ? '' : bov.area_ha}
                              onChange={e => updateField('area_ha', e.target.value === '' ? null : Number(e.target.value))}
                              placeholder="Ex: 50.5"
                              className="bg-white dark:bg-slate-900"
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Quantidade de Cochos</label>
                            <Input
                              type="number"
                              value={bov.qtd_cochos === null || bov.qtd_cochos === undefined ? '' : bov.qtd_cochos}
                              onChange={e => {
                                const val = e.target.value === '' ? null : Math.max(0, parseInt(e.target.value, 10));
                                updateField('qtd_cochos', val);
                              }}
                              placeholder="Ex: 10"
                              className="bg-white dark:bg-slate-900"
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Tamanho dos Cochos (m)</label>
                            <Input
                              type="number"
                              step="0.1"
                              value={bov.tamanho_cochos === null || bov.tamanho_cochos === undefined ? '' : bov.tamanho_cochos}
                              onChange={e => updateField('tamanho_cochos', e.target.value === '' ? null : Number(e.target.value))}
                              placeholder="Ex: 2.5"
                              className="bg-white dark:bg-slate-900"
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Quantidade de Animais</label>
                            <Input
                              type="number"
                              value={bov.qtd_animais === null || bov.qtd_animais === undefined ? '' : bov.qtd_animais}
                              onChange={e => {
                                const val = e.target.value === '' ? null : Math.max(0, parseInt(e.target.value, 10));
                                updateField('qtd_animais', val);
                              }}
                              placeholder="Ex: 150"
                              className="bg-white dark:bg-slate-900"
                            />
                          </div>
                        </div>
                        {renderEditTextArea("Forma de Dessedentação", bov.dessedentacao, val => updateField('dessedentacao', val), "Ex: Açude, Bebedouro automático, Rio...")}
                      </div>

                      {/* Bloco 3: Diagnóstico DIFI */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-rose-600 dark:text-rose-400 border-b pb-1 mb-2">
                          3. Diagnóstico Administrativo e Fiscalização (DIFI)
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Registro fotográfico georreferenciado ok?", bov.foto_geo_ok, val => updateField('foto_geo_ok', val))}
                          {renderEditBoolSelect("Constatação de Infração?", bov.infracao_constatada, val => updateField('infracao_constatada', val))}
                        </div>
                        {renderEditTextArea("Medidas Sugeridas à DIFI", bov.medida_sugerida, val => updateField('medida_sugerida', val), "Ex: Notificação, Embargo, Auto de Infração...")}
                        {renderEditTextArea("Observações Técnicas Gerais / Parecer Técnico", bov.observacoes, val => updateField('observacoes', val), "Acrescente quaisquer observações adicionais relativas à vistoria.")}
                      </div>
                    </div>
                  );
                } else if (typeKey === 'aquicultura') {
                  const aq = subData || {};
                  
                  const updateField = (field: string, val: any) => {
                    setEditingVistoria(prev => {
                      if (!prev) return prev;
                      const currentAq = (prev.data as any).aquicultura || {};
                      const updatedAquicultura = {
                        ...currentAq,
                        [field]: val
                      };

                      return {
                        ...prev,
                        data: {
                          ...prev.data,
                          aquicultura: updatedAquicultura
                        }
                      };
                    });
                  };

                  const hasManyAeradores = aq.possui_aeradores && aq.qtd_aeradores && aq.qtd_aeradores >= 3;
                  const isAreaExceeded = aq.area_tanques && aq.area_tanques > 4.9;

                  return (
                    <div className="space-y-6">
                      {/* Bloco 1: Capacidade e Dimensionamento */}
                      <div className="bg-cyan-50/20 dark:bg-cyan-950/5 p-4 rounded-lg border border-cyan-100 dark:border-cyan-950/20 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-cyan-600 dark:text-cyan-400 border-b pb-1 mb-2">
                          1. Capacidade e Viveiros
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Número de Tanques</label>
                            <Input
                              type="number"
                              value={aq.qtd_tanques === null || aq.qtd_tanques === undefined ? '' : aq.qtd_tanques}
                              onChange={e => {
                                const val = e.target.value === '' ? null : Math.max(0, parseInt(e.target.value, 10));
                                updateField('qtd_tanques', val);
                              }}
                              placeholder="Ex: 5"
                              className="bg-white dark:bg-slate-900"
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Área dos Tanques (ha)</label>
                            <Input
                              type="number"
                              step="0.01"
                              value={aq.area_tanques === null || aq.area_tanques === undefined ? '' : aq.area_tanques}
                              onChange={e => {
                                const val = e.target.value === '' ? null : Math.max(0, parseFloat(e.target.value));
                                updateField('area_tanques', val);
                              }}
                              placeholder="Ex: 1.4"
                              className="bg-white dark:bg-slate-900"
                            />
                          </div>
                        </div>

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mt-3">
                          {renderEditBoolSelect("Possui Aeradores?", aq.possui_aeradores, val => {
                            updateField('possui_aeradores', val);
                            if (!val) updateField('qtd_aeradores', null);
                          })}

                          {aq.possui_aeradores && (
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Quantidade em cada tanque</label>
                              <Input
                                type="number"
                                value={aq.qtd_aeradores === null || aq.qtd_aeradores === undefined ? '' : aq.qtd_aeradores}
                                onChange={e => {
                                  const val = e.target.value === '' ? null : Math.max(0, parseInt(e.target.value, 10));
                                  updateField('qtd_aeradores', val);
                                }}
                                placeholder="Ex: 2"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                          )}
                        </div>

                        {/* Alerta de Aeradores */}
                        {hasManyAeradores && (
                          <div className="flex gap-2.5 p-3 rounded bg-amber-500/10 border border-amber-500/20 text-amber-800 dark:text-amber-300 text-xs leading-relaxed mt-2">
                            <AlertTriangle className="w-4 h-4 shrink-0 text-amber-600 dark:text-amber-400" />
                            <div>
                              <span className="font-bold">Alerta de Intensidade: </span>
                              Há 3 ou mais aeradores por tanque. Isso pode indicar um sistema intensivo com maior potencial poluidor.
                            </div>
                          </div>
                        )}

                        {/* Alerta de Campo de Futebol (Incompatibilidade) */}
                        {isAreaExceeded && (
                          <div className="flex gap-2.5 p-3 rounded bg-rose-500/10 border border-rose-500/20 text-rose-800 dark:text-rose-300 text-xs leading-relaxed mt-2">
                            <AlertCircle className="w-4 h-4 shrink-0 text-rose-600 dark:text-rose-400" />
                            <div>
                              <span className="font-bold">Incompatibilidade Técnica: </span>
                              A soma visual dos viveiros ({aq.area_tanques} ha) ultrapassa 7 campos de futebol (~4.9 ha). A dispensa de licenciamento pode ser incompatível.
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Bloco 2: Itens Identificados e Infraestrutura */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-4">
                        <h4 className="text-xs font-bold uppercase text-cyan-600 dark:text-cyan-400 border-b pb-1">
                          2. Equipamentos e Infraestrutura
                        </h4>
                        
                        <div className="space-y-4">
                          {/* BOMBA */}
                          <div className="p-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg space-y-3">
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-bold text-slate-700 dark:text-slate-350 uppercase">BOMBA</span>
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => {
                                    const nextVal = !aq.bomba_identificada;
                                    updateField('bomba_identificada', nextVal);
                                    if (!nextVal) updateField('bomba_situacao', '');
                                  }}
                                  className={`px-3 py-1 rounded-full text-xs font-semibold border transition-all ${
                                    aq.bomba_identificada
                                      ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 font-bold"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  {aq.bomba_identificada ? "Identificada" : "Não Consta"}
                                </button>
                              </div>
                            </div>
                            {aq.bomba_identificada && (
                              <div className="space-y-1">
                                <label className="text-[11px] font-semibold text-slate-400 uppercase">Situação da Bomba</label>
                                <Input
                                  value={aq.bomba_situacao || ''}
                                  onChange={e => updateField('bomba_situacao', e.target.value)}
                                  placeholder="Ex: Em funcionamento, captando do açude..."
                                  className="bg-white dark:bg-slate-900 text-xs"
                                />
                              </div>
                            )}
                          </div>

                          {/* TUBULAÇÃO */}
                          <div className="p-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg space-y-3">
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-bold text-slate-700 dark:text-slate-350 uppercase">TUBULAÇÃO</span>
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => {
                                    const nextVal = !aq.tubulacao_identificada;
                                    updateField('tubulacao_identificada', nextVal);
                                    if (!nextVal) updateField('tubulacao_situacao', '');
                                  }}
                                  className={`px-3 py-1 rounded-full text-xs font-semibold border transition-all ${
                                    aq.tubulacao_identificada
                                      ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 font-bold"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  {aq.tubulacao_identificada ? "Identificada" : "Não Consta"}
                                </button>
                              </div>
                            </div>
                            {aq.tubulacao_identificada && (
                              <div className="space-y-1">
                                <label className="text-[11px] font-semibold text-slate-400 uppercase">Situação da Tubulação</label>
                                <Input
                                  value={aq.tubulacao_situacao || ''}
                                  onChange={e => updateField('tubulacao_situacao', e.target.value)}
                                  placeholder="Ex: PVC de 100mm, com conexões conformes..."
                                  className="bg-white dark:bg-slate-900 text-xs"
                                />
                              </div>
                            )}
                          </div>

                          {/* PONTO DE CAPTAÇÃO */}
                          <div className="p-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg space-y-3">
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-bold text-slate-700 dark:text-slate-350 uppercase">PONTO DE CAPTAÇÃO</span>
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => {
                                    const nextVal = !aq.captacao_identificada;
                                    updateField('captacao_identificada', nextVal);
                                    if (!nextVal) updateField('captacao_situacao', '');
                                  }}
                                  className={`px-3 py-1 rounded-full text-xs font-semibold border transition-all ${
                                    aq.captacao_identificada
                                      ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 font-bold"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  {aq.captacao_identificada ? "Identificado" : "Não Consta"}
                                </button>
                              </div>
                            </div>
                            {aq.captacao_identificada && (
                              <div className="space-y-1">
                                <label className="text-[11px] font-semibold text-slate-400 uppercase">Situação do Ponto de Captação</label>
                                <Input
                                  value={aq.captacao_situacao || ''}
                                  onChange={e => updateField('captacao_situacao', e.target.value)}
                                  placeholder="Ex: Margem esquerda do rio, desprotegido..."
                                  className="bg-white dark:bg-slate-900 text-xs"
                                />
                              </div>
                            )}
                          </div>

                          {/* HIDRÔMETRO */}
                          <div className="p-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg space-y-3">
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-bold text-slate-700 dark:text-slate-350 uppercase">HIDRÔMETRO</span>
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => {
                                    const nextVal = !aq.hidrometro;
                                    updateField('hidrometro', nextVal);
                                    if (!nextVal) updateField('hidrometro_situacao', '');
                                  }}
                                  className={`px-3 py-1 rounded-full text-xs font-semibold border transition-all ${
                                    aq.hidrometro
                                      ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 font-bold"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  {aq.hidrometro ? "Identificado" : "Não Consta"}
                                </button>
                              </div>
                            </div>
                            {aq.hidrometro && (
                              <div className="space-y-1">
                                <label className="text-[11px] font-semibold text-slate-400 uppercase">Situação do Hidrômetro</label>
                                <Input
                                  value={aq.hidrometro_situacao || ''}
                                  onChange={e => updateField('hidrometro_situacao', e.target.value)}
                                  placeholder="Ex: Selado e calibrado, leitura ok..."
                                  className="bg-white dark:bg-slate-900 text-xs"
                                />
                              </div>
                            )}
                          </div>

                          {/* OUTROS */}
                          <div className="p-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg space-y-3">
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-bold text-slate-700 dark:text-slate-350 uppercase">Outros itens identificados</span>
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => {
                                    const nextVal = !aq.outros_itens_identificados;
                                    updateField('outros_itens_identificados', nextVal);
                                    if (!nextVal) updateField('outros_itens_situacao', '');
                                  }}
                                  className={`px-3 py-1 rounded-full text-xs font-semibold border transition-all ${
                                    aq.outros_itens_identificados
                                      ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 font-bold"
                                      : "bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700 hover:bg-slate-100"
                                  }`}
                                >
                                  {aq.outros_itens_identificados ? "Identificado" : "Não Consta"}
                                </button>
                              </div>
                            </div>
                            {aq.outros_itens_identificados && (
                              <div className="space-y-1">
                                <label className="text-[11px] font-semibold text-slate-400 uppercase">Situação dos Outros Itens</label>
                                <Input
                                  value={aq.outros_itens_situacao || ''}
                                  onChange={e => updateField('outros_itens_situacao', e.target.value)}
                                  placeholder="Ex: Galpão de rações com infiltrações..."
                                  className="bg-white dark:bg-slate-900 text-xs"
                                />
                              </div>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* Bloco 3: Recursos Hídricos e Descarte */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-4">
                        <h4 className="text-xs font-bold uppercase text-cyan-600 dark:text-cyan-400 border-b pb-1">
                          3. Recursos Hídricos e Descarte
                        </h4>
                        
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Existe outorga de água?", aq.outorga, val => {
                            updateField('outorga', val);
                            if (!val) updateField('outorga_identificacao', '');
                          })}

                          {aq.outorga && (
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Identificação da Outorga</label>
                              <Input
                                value={aq.outorga_identificacao || ''}
                                onChange={e => updateField('outorga_identificacao', e.target.value)}
                                placeholder="Nº da Outorga / Processo"
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                          )}
                        </div>

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditSelect("Local de Descarte", aq.descarte_residuos, val => {
                            updateField('descarte_residuos', val);
                            if (val !== 'OUTRO') updateField('descarte_residuos_outro', '');
                          }, [
                            { value: "COMPOSTEIRA", label: "Composteira" },
                            { value: "OUTRO", label: "Outro" }
                          ])}

                          {aq.descarte_residuos === 'OUTRO' && (
                            <div className="space-y-1">
                              <label className="text-xs font-semibold text-slate-500 block uppercase">Identificação do Descarte</label>
                              <Input
                                value={aq.descarte_residuos_outro || ''}
                                onChange={e => updateField('descarte_residuos_outro', e.target.value)}
                                placeholder="Especifique o outro local..."
                                className="bg-white dark:bg-slate-900"
                              />
                            </div>
                          )}
                        </div>

                        {renderEditTextInput("Fonte de Abastecimento (Legado)", aq.fonte_agua, val => updateField('fonte_agua', val), "Ex: Açude, captação subterrânea...")}
                      </div>

                      {/* Bloco 4: Diagnóstico DIFI */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-rose-600 dark:text-rose-400 border-b pb-1 mb-2">
                          4. Diagnóstico Administrativo e Fiscalização (DIFI)
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Registro fotográfico georreferenciado ok?", aq.foto_geo_ok, val => updateField('foto_geo_ok', val))}
                          {renderEditBoolSelect("Constatação de Infração?", aq.infracao_constatada, val => updateField('infracao_constatada', val))}
                        </div>
                        {renderEditTextArea("Medidas Sugeridas à DIFI", aq.medida_sugerida, val => updateField('medida_sugerida', val), "Ex: Notificação, Embargo, Auto de Infração...")}
                        {renderEditTextArea("Observações Técnicas Gerais / Parecer Técnico", aq.observacoes, val => updateField('observacoes', val), "Acrescente quaisquer observações adicionais relativas à vistoria.")}
                      </div>
                    </div>
                  );
                } else if (typeKey === 'sucroalcooleiro') {
                  const suc = subData || {};
                  const updateField = (field: string, val: any) => {
                    setEditingVistoria(prev => {
                      if (!prev) return prev;
                      const currentSuc = (prev.data as any).sucroalcooleiro || {};
                      const updatedSuc = {
                        ...currentSuc,
                        [field]: val
                      };

                      // Legacy compatibility mappings
                      if (field === 'produz_residuos' && val === false) {
                        updatedSuc.residuos_coleta_destinacao = '';
                        updatedSuc.residuos_solidos = '';
                      }
                      if (field === 'residuos_coleta_destinacao') {
                        updatedSuc.residuos_solidos = val;
                      }
                      if (field === 'bagaco_armazenamento_destinacao') {
                        updatedSuc.bagaco = val;
                      }
                      if (field === 'equipamentos_memorial') {
                        updatedSuc.equipamentos_conformes = val;
                      }
                      if (field === 'armazenamento_requisitos_ambientais') {
                        updatedSuc.armazenamento_ok = val;
                      }
                      if (field === 'faz_uso_agrotoxicos' && val === false) {
                        updatedSuc.agrotoxicos_quais = '';
                        updatedSuc.agrotoxicos_receituario = false;
                        updatedSuc.agrotoxicos_embalagens_destinacao = '';
                      }

                      return {
                        ...prev,
                        data: {
                          ...prev.data,
                          sucroalcooleiro: updatedSuc
                        }
                      };
                    });
                  };

                  return (
                    <div className="space-y-6">
                      {/* Bloco 1: Matéria-Prima e Efluentes */}
                      <div className="bg-purple-50/20 dark:bg-purple-950/5 p-4 rounded-lg border border-purple-100 dark:border-purple-950/20 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-purple-650 dark:text-purple-400 border-b pb-1 mb-2">
                          1. Matéria-Prima e Efluentes
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditTextInput("Local de armazenamento da matéria-prima", suc.local_materia_prima, val => updateField('local_materia_prima', val), "Ex: Pátio de cana, galpão de recepção...")}
                          {renderEditBoolSelect("Produz efluentes?", suc.produz_efluentes, val => updateField('produz_efluentes', val))}
                          {suc.produz_efluentes && renderEditTextInput("Local de coleta e destinação dos efluentes", suc.efluentes_coleta_destinacao, val => updateField('efluentes_coleta_destinacao', val), "Ex: Lagoa de estabilização, canaletas...")}
                          {renderEditBoolSelect("Produz resíduos sólidos?", suc.produz_residuos, val => updateField('produz_residuos', val))}
                          {suc.produz_residuos && renderEditTextInput("Local de coleta e destinação dos resíduos sólidos", suc.residuos_coleta_destinacao, val => updateField('residuos_coleta_destinacao', val), "Ex: PGRS, compostagem...")}
                        </div>
                      </div>

                      {/* Bloco 2: Subprodutos e Fontes Térmicas */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-purple-650 dark:text-purple-400 border-b pb-1 mb-2">
                          2. Subprodutos e Matriz Energética
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditBoolSelect("Gera/Utiliza bagaço?", suc.gera_utiliza_bagaco, val => updateField('gera_utiliza_bagaco', val))}
                          {suc.gera_utiliza_bagaco && renderEditTextInput("Local de armazenamento e destinação do bagaço", suc.bagaco_armazenamento_destinacao, val => updateField('bagaco_armazenamento_destinacao', val), "Ex: Galpão de bagaço, queima na caldeira...")}
                          {renderEditBoolSelect("Existem fontes térmicas?", suc.fontes_termicas, val => updateField('fontes_termicas', val))}
                          {suc.fontes_termicas && renderEditTextInput("Qual a fonte térmica?", suc.fontes_termicas_quais, val => updateField('fontes_termicas_quais', val), "Ex: Caldeira a vapor, forno...")}
                          {renderEditBoolSelect("Utiliza lenha como combustível?", suc.utiliza_lenha, val => updateField('utiliza_lenha', val))}
                          {suc.utiliza_lenha && (
                            <>
                              {renderEditSelect("Origem da lenha", suc.lenha_nativa_exotica, val => updateField('lenha_nativa_exotica', val), [
                                { value: "", label: "Selecione a origem..." },
                                { value: "NATIVA", label: "Nativa" },
                                { value: "EXOTICA", label: "Exótica" }
                              ])}
                              {renderEditTextInput("Local de armazenamento da lenha", suc.lenha_local_armazenamento, val => updateField('lenha_local_armazenamento', val), "Ex: Pátio coberto de lenha...")}
                            </>
                          )}
                        </div>
                      </div>

                      {/* Bloco 3: Instalações e Equipamentos */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-purple-650 dark:text-purple-400 border-b pb-1 mb-2">
                          3. Integridade das Instalações e Equipamentos
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Tanques de armazenamento adequados/íntegros/identificados?", suc.tanques_adequados, val => updateField('tanques_adequados', val))}
                          {renderEditBoolSelect("Higienização e controle de efluentes da limpeza?", suc.higienizacao_controle_efluentes, val => updateField('higienizacao_controle_efluentes', val))}
                          {renderEditBoolSelect("Existe fossa séptica?", suc.fossa_septica, val => updateField('fossa_septica', val))}
                          {renderEditBoolSelect("Equipamentos em conformidade com memorial?", suc.equipamentos_memorial, val => updateField('equipamentos_memorial', val))}
                          {renderEditBoolSelect("Chaminés com sistemas de controle de emissões?", suc.chamines_controle_emissoes, val => updateField('chamines_controle_emissoes', val))}
                        </div>
                      </div>

                      {/* Bloco 4: Vinhaça e Armazenamento Impermeabilizado */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-purple-600 dark:text-purple-400 border-b pb-1 mb-2">
                          4. Gestão de Vinhaça e Estanqueidade
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditBoolSelect("Coleta, transporte e armazenamento da vinhaça?", suc.sistema_vinhaca, val => updateField('sistema_vinhaca', val))}
                          {suc.sistema_vinhaca && renderEditTextInput("Condições da vinhaça", suc.vinhaca_condicoes, val => updateField('vinhaca_condicoes', val), "Ex: Tubulação estanque, armazenamento impermeável...")}
                          {renderEditBoolSelect("Tanques/lagoas impermeabilizadas?", suc.tanques_lagoas_impermeabilizadas, val => updateField('tanques_lagoas_impermeabilizadas', val))}
                          {renderEditBoolSelect("Existem vazamentos ou infiltrações?", suc.vazamentos_infiltracoes, val => updateField('vazamentos_infiltracoes', val))}
                          {renderEditBoolSelect("Efluentes destinados corretamente?", suc.efluentes_destinados_corretamente, val => updateField('efluentes_destinados_corretamente', val))}
                          {renderEditBoolSelect("Gestão dos resíduos sólidos conforme PGRS?", suc.gestao_residuos_pgrs, val => updateField('gestao_residuos_pgrs', val))}
                        </div>
                      </div>

                      {/* Bloco 5: Envase e Depósito */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-purple-655 dark:text-purple-400 border-b pb-1 mb-2">
                          5. Envase e Depósito de Produtos
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditBoolSelect("Existe área específica para envase?", suc.area_especifica_envase, val => updateField('area_especifica_envase', val))}
                          {suc.area_especifica_envase && renderEditTextInput("Condições da área de envase", suc.envase_condicoes, val => updateField('envase_condicoes', val), "Ex: Piso higienizável, azulejado...")}
                          {renderEditBoolSelect("Local de armazenamento atende requisitos ambientais?", suc.armazenamento_requisitos_ambientais, val => updateField('armazenamento_requisitos_ambientais', val))}
                        </div>
                      </div>

                      {/* Bloco 6: Uso de Agrotóxicos */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-purple-650 dark:text-purple-400 border-b pb-1 mb-2">
                          6. Uso e Controle de Defensivos / Agrotóxicos
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditBoolSelect("Faz uso de agrotóxicos?", suc.faz_uso_agrotoxicos, val => updateField('faz_uso_agrotoxicos', val))}
                          {suc.faz_uso_agrotoxicos && (
                            <>
                              {renderEditTextInput("Quais agrotóxicos utiliza?", suc.agrotoxicos_quais, val => updateField('agrotoxicos_quais', val), "Ex: Glifosato, Atrazina...")}
                              {renderEditSelect("Possui receituário agronômico?", suc.agrotoxicos_receituario?.toString() || "", val => updateField('agrotoxicos_receituario', val), [
                                { value: "", label: "Selecione..." },
                                { value: "Sim", label: "Sim" },
                                { value: "Não", label: "Não" }
                              ])}
                              {renderEditTextInput("Destinação das embalagens vazias", suc.agrotoxicos_embalagens_destinacao, val => updateField('agrotoxicos_embalagens_destinacao', val), "Ex: Devolução ao revendedor, tríplice lavagem...")}
                            </>
                          )}
                        </div>
                      </div>

                      {/* Bloco 7: Diagnóstico e Fiscalização (DIFI) */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-955/10 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-rose-600 dark:text-rose-400 border-b pb-1 mb-2">
                          7. Ritos Legais e Fiscalização (DIFI)
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Registro fotográfico georreferenciado conforme rito?", suc.foto_geo_ok, val => updateField('foto_geo_ok', val))}
                          {renderEditBoolSelect("Houve constatação de infração?", suc.infracao_constatada, val => updateField('infracao_constatada', val))}
                        </div>
                        {suc.infracao_constatada && (
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Sugestão de medidas pela DIFI</label>
                            <select
                              className="flex h-9 w-full rounded-md border border-slate-200 bg-white dark:bg-slate-900 px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 dark:border-slate-800 dark:text-slate-200"
                              value={suc.infracao_sugestao_medidas || ""}
                              onChange={e => updateField('infracao_sugestao_medidas', e.target.value)}
                            >
                              <option value="">Selecione uma medida...</option>
                              <option value="Notificação: Para adequação do projeto ou apresentação de documentos.">Notificação</option>
                              <option value="Embargo: Para impedir continuidade de dano em área não autorizada.">Embargo</option>
                              <option value="Auto de Infração: Lavrado por desobediência às normas ambientais.">Auto de Infração</option>
                            </select>
                          </div>
                        )}
                        {renderEditTextArea("Observações técnicas complementares", suc.observacoes_complementares, val => updateField('observacoes_complementares', val), "Informações adicionais identificadas na vistoria...")}
                      </div>
                    </div>
                  );
                } else if (typeKey === 'agricultura') {
                  const agri = subData || {};
                  const updateField = (field: string, val: any) => {
                    setEditingVistoria(prev => {
                      if (!prev) return prev;
                      const currentAgri = (prev.data as any).agricultura || {};
                      const updatedAgri = {
                        ...currentAgri,
                        [field]: val
                      };

                      // Legacy compatibility mappings
                      if (field === 'atividade_agricola') {
                        updatedAgri.cultivo = val;
                      }
                      if (field === 'tem_cursos_hidricos') {
                        updatedAgri.cursos_hidricos_entorno = val ? 'Sim' : 'Não';
                      }
                      if (field === 'faz_uso_agrotoxicos' && val === false) {
                        updatedAgri.agrotoxicos_quais = '';
                        updatedAgri.agrotoxicos_receituario = false;
                        updatedAgri.agrotoxicos_embalagens_destinacao = '';
                        updatedAgri.agrotoxicos = '';
                      }
                      if (field === 'agrotoxicos_quais') {
                        updatedAgri.agrotoxicos = val;
                      }

                      return {
                        ...prev,
                        data: {
                          ...prev.data,
                          agricultura: updatedAgri
                        }
                      };
                    });
                  };

                  return (
                    <div className="space-y-6">
                      {/* Bloco 1: Identificação e Irrigação */}
                      <div className="bg-lime-50/20 dark:bg-lime-950/5 p-4 rounded-lg border border-lime-100/40 dark:bg-lime-900/10 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-lime-600 dark:text-lime-400 border-b pb-1 mb-2">
                          1. Identificação e Irrigação
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditTextInput("Atividade agrícola cultivada", agri.atividade_agricola, val => updateField('atividade_agricola', val), "Ex: Cultivo de milho, plantação de tomate...")}
                          {renderEditBoolSelect("Atividade é Irrigada?", agri.atividade_irrigada, val => updateField('atividade_irrigada', val))}
                          {agri.atividade_irrigada && renderEditTextInput("Possui outorga?", agri.irrigada_outorga, val => updateField('irrigada_outorga', val), "Ex: Outorga nº 1234/2026...")}
                        </div>
                      </div>

                      {/* Bloco 2: Uso de Agrotóxicos */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-lime-655 dark:text-lime-400 border-b pb-1 mb-2">
                          2. Uso e Gestão de Agrotóxicos
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditBoolSelect("Faz uso de agrotóxicos?", agri.faz_uso_agrotoxicos, val => updateField('faz_uso_agrotoxicos', val))}
                          {agri.faz_uso_agrotoxicos && (
                            <>
                              {renderEditTextInput("Quais agrotóxicos utiliza?", agri.agrotoxicos_quais, val => updateField('agrotoxicos_quais', val), "Ex: Glifosato, Carbofurano...")}
                              {renderEditSelect("Possui receituário agronômico?", agri.agrotoxicos_receituario?.toString() || "", val => updateField('agrotoxicos_receituario', val), [
                                { value: "", label: "Selecione..." },
                                { value: "Sim", label: "Sim" },
                                { value: "Não", label: "Não" }
                              ])}
                              {renderEditTextInput("Destinação das embalagens vazias", agri.agrotoxicos_embalagens_destinacao, val => updateField('agrotoxicos_embalagens_destinacao', val), "Ex: Devolução ao revendedor, tríplice lavagem...")}
                            </>
                          )}
                        </div>
                      </div>

                      {/* Bloco 3: Recursos Hídricos e Entorno */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-800 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-lime-655 dark:text-lime-400 border-b pb-1 mb-2">
                          3. Recursos Hídricos e Entorno
                        </h4>
                        <div className="grid grid-cols-1 gap-3">
                          {renderEditBoolSelect("Existem cursos hídricos, nascentes ou reservatórios no entorno?", agri.tem_cursos_hidricos, val => updateField('tem_cursos_hidricos', val))}
                        </div>
                      </div>

                      {/* Bloco 4: Diagnóstico e Fiscalização (DIFI) */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-955/10 space-y-3">
                        <h4 className="text-xs font-bold uppercase text-rose-600 dark:text-rose-400 border-b pb-1 mb-2">
                          4. Ritos Legais e Fiscalização (DIFI)
                        </h4>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                          {renderEditBoolSelect("Registro fotográfico georreferenciado conforme rito?", agri.foto_geo_ok, val => updateField('foto_geo_ok', val))}
                          {renderEditBoolSelect("Houve constatação de infração?", agri.infracao_constatada, val => updateField('infracao_constatada', val))}
                        </div>
                        {agri.infracao_constatada && (
                          <div className="space-y-1">
                            <label className="text-xs font-semibold text-slate-500 block uppercase">Sugestão de medidas pela DIFI</label>
                            <select
                              className="flex h-9 w-full rounded-md border border-slate-200 bg-white dark:bg-slate-900 px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 dark:border-slate-800 dark:text-slate-200"
                              value={agri.infracao_sugestao_medidas || ""}
                              onChange={e => updateField('infracao_sugestao_medidas', e.target.value)}
                            >
                              <option value="">Selecione uma medida...</option>
                              <option value="Notificação: Para adequação do projeto ou apresentação de documentos.">Notificação</option>
                              <option value="Embargo: Para impedir continuidade de dano em área não autorizada.">Embargo</option>
                              <option value="Auto de Infração: Lavrado por desobediência às normas ambientais.">Auto de Infração</option>
                            </select>
                          </div>
                        )}
                        {renderEditTextArea("Informações complementares e parecer técnico", agri.observacoes_complementares, val => updateField('observacoes_complementares', val), "Informações adicionais identificadas na vistoria...")}
                      </div>
                    </div>
                  );
                }

                // Fallback loop for other models (suinocultura, bovinocultura, etc)
                return (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {Object.entries(subData).map(([key, value]) => {
                      if (key === 'id' || key === 'vistoria') return null;
                      
                      const handleChange = (newVal: any) => {
                        setEditingVistoria(prev => {
                          if (!prev) return prev;
                          return {
                            ...prev,
                            data: {
                              ...prev.data,
                              [typeKey]: {
                                ...((prev.data as any)[typeKey] || {}),
                                [key]: newVal
                              }
                            }
                          };
                        });
                      };

                      return (
                        <div key={key} className="space-y-1">
                          <label className="text-xs font-semibold uppercase tracking-wider text-slate-500">
                            {key.replace(/_/g, ' ')}
                          </label>
                          {typeof value === 'boolean' || value === true || value === false ? (
                            <select 
                              className="flex h-9 w-full rounded-md border border-slate-200 bg-white dark:bg-slate-900 px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 dark:border-slate-800 dark:text-slate-200"
                              value={value ? "true" : "false"}
                              onChange={e => handleChange(e.target.value === "true")}
                            >
                              <option value="true">Sim</option>
                              <option value="false">Não</option>
                            </select>
                          ) : typeof value === 'number' ? (
                            <Input 
                              type="number"
                              value={value}
                              onChange={e => handleChange(Number(e.target.value))}
                              className="bg-white dark:bg-slate-900"
                            />
                          ) : (
                            <Input 
                              value={(value as string) || ''}
                              onChange={e => handleChange(e.target.value)}
                              className="bg-white dark:bg-slate-900"
                            />
                          )}
                        </div>
                      );
                    })}
                  </div>
                );
              })()}
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => setIsOpen(false)}>Cancelar</Button>
          <Button onClick={handleSave} disabled={isSaving} className="bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 hover:bg-slate-800 dark:hover:bg-slate-200">
            {isSaving ? "Salvando..." : "Salvar Alterações"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
});

VistoriaEditDialog.displayName = 'VistoriaEditDialog';

export default VistoriaEditDialog;
