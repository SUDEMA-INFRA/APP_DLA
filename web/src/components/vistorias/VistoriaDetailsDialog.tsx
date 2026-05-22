import React from 'react';
import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle, 
  DialogDescription, 
  DialogFooter 
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { 
  ClipboardCheck, 
  Smartphone, 
  MapPin, 
  Trees, 
  Sprout, 
  Activity, 
  Egg, 
  XCircle, 
  CheckCircle2, 
  Maximize2, 
  Download,
  Waves,
  AlertTriangle,
  Droplets,
  Wrench,
  AlertCircle
} from 'lucide-react';
import { type VistoriaData, type UserData, getVistoriaType, formatDate } from './types';

interface VistoriaDetailsDialogProps {
  isOpen: boolean;
  setIsOpen: (open: boolean) => void;
  selectedVistoria: VistoriaData | null;
  users: UserData[];
}

const renderBoolField = (value: boolean | undefined, label: string) => {
  return (
    <div className="flex items-center gap-2 py-1.5 px-3 rounded bg-slate-50/80 dark:bg-slate-900/80 border border-slate-150/40 dark:border-slate-800/40">
      {value === true ? (
        <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />
      ) : value === false ? (
        <XCircle className="w-4 h-4 text-rose-500 shrink-0" />
      ) : (
        <div className="w-4 h-4 rounded-full border-2 border-dashed border-slate-300 dark:border-slate-700 shrink-0" />
      )}
      <span className="text-xs text-slate-700 dark:text-slate-300 font-medium">{label}</span>
    </div>
  );
};

const VistoriaDetailsDialog: React.FC<VistoriaDetailsDialogProps> = React.memo(({
  isOpen,
  setIsOpen,
  selectedVistoria,
  users
}) => {
  // Helper to resolve user name from id
  const getUserName = (userId: number) => {
    const user = users.find(u => u.id === userId);
    return user 
      ? `${user.first_name || ''} ${user.last_name || ''}`.trim() || user.username
      : `ID: ${userId}`;
  };

  // Stylized Type Badge mapping
  const getTypeBadge = (type: string) => {
    const lowerType = type.toLowerCase();
    if (lowerType.includes('supressão') || lowerType.includes('ambiental') || lowerType.includes('supressao')) {
      return (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400 text-xs font-semibold">
          <Trees className="w-3.5 h-3.5" />
          Supressão Vegetal
        </span>
      );
    }
    if (lowerType.includes('avicultura')) {
      return (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400 text-xs font-semibold">
          <Egg className="w-3.5 h-3.5" />
          Avicultura
        </span>
      );
    }
    if (lowerType.includes('suinocultura')) {
      return (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-pink-100 text-pink-800 dark:bg-pink-900/30 dark:text-pink-400 text-xs font-semibold">
          Suinocultura
        </span>
      );
    }
    if (lowerType.includes('bovinocultura')) {
      return (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-400 text-xs font-semibold">
          Bovinocultura
        </span>
      );
    }
    if (lowerType.includes('aquicultura')) {
      return (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400 text-xs font-semibold">
          Aquicultura
        </span>
      );
    }
    if (lowerType.includes('sucroalcooleiro')) {
      return (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400 text-xs font-semibold">
          Sucroalcooleiro
        </span>
      );
    }
    if (lowerType.includes('agricultura')) {
      return (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-lime-100 text-lime-800 dark:bg-lime-900/30 dark:text-lime-400 text-xs font-semibold">
          Agricultura
        </span>
      );
    }
    return (
      <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-400 text-xs font-semibold">
        Geral
      </span>
    );
  };

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogContent className="max-w-[90vw] md:max-w-5xl lg:max-w-6xl xl:max-w-7xl h-[85vh] max-h-[85vh] flex flex-col print-dialog-content bg-white dark:bg-slate-950">
        {selectedVistoria && (
          <>
            <style dangerouslySetInnerHTML={{ __html: `
              @media print {
                /* Reset body and print backgrounds */
                body {
                  background: white !important;
                  color: black !important;
                  font-size: 11pt !important;
                  margin: 0 !important;
                  padding: 0 !important;
                  overflow: visible !important;
                }
                /* Hide main dashboard layout and root completely */
                #root,
                [data-sidebar],
                header,
                main,
                footer {
                  display: none !important;
                  visibility: hidden !important;
                }
                /* Hide backdrops and dark overlays completely */
                div[class*="bg-black/"],
                div[class*="backdrop-blur"] {
                  display: none !important;
                }
                /* Reset fixed wrapper portal container to flow naturally */
                div[role="presentation"],
                div[class*="fixed inset-0"] {
                  position: relative !important;
                  display: block !important;
                  background: white !important;
                  width: 100% !important;
                  height: auto !important;
                  max-height: none !important;
                  overflow: visible !important;
                  inset: auto !important;
                }
                /* Set dialog container styles to fill the printed page and reset translations */
                .print-dialog-content {
                  position: relative !important;
                  left: 0 !important;
                  top: 0 !important;
                  transform: none !important;
                  translate: none !important;
                  width: 100% !important;
                  max-width: 100% !important;
                  height: auto !important;
                  max-height: none !important;
                  overflow: visible !important;
                  box-shadow: none !important;
                  border: none !important;
                  background: white !important;
                  color: black !important;
                  padding: 0 !important;
                  margin: 0 !important;
                  display: block !important;
                  visibility: visible !important;
                }
                /* Prevent screen scroll settings (height/max-height/overflow) from cutting off printed columns */
                .print-dialog-content [class*="overflow-y-auto"],
                .print-dialog-content [class*="max-h-full"],
                .print-dialog-content .overflow-y-auto,
                .print-dialog-content .max-h-full {
                  overflow: visible !important;
                  max-height: none !important;
                  height: auto !important;
                }
                .print-dialog-content * {
                  visibility: visible !important;
                }
                /* Hide printing button block and footer in printout */
                .dialog-footer,
                button,
                button[class*="absolute right-4 top-4"],
                .print-dialog-content button,
                .print-dialog-content [role="button"],
                .print-dialog-content svg:not(.w-3.5):not(.w-4) {
                  display: none !important;
                  visibility: hidden !important;
                }
                /* Force grid columns to keep side-by-side A4 aspect ratio instead of wrapping */
                .print-dialog-content .grid {
                  display: grid !important;
                  grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
                  gap: 1.5rem !important;
                }
                .print-dialog-content .md\\:col-span-1 {
                  grid-column: span 1 / span 1 !important;
                  display: block !important;
                }
                .print-dialog-content .md\\:col-span-2 {
                  grid-column: span 2 / span 2 !important;
                  display: block !important;
                }
                /* Force nested cards to show grid content clearly */
                .print-dialog-content .md\\:grid-cols-2 {
                  display: grid !important;
                  grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
                  gap: 1rem !important;
                }
                /* Preserve page breaks across sections cleanly */
                iframe {
                  border: 1px solid #ccc !important;
                  page-break-inside: avoid !important;
                  max-height: 250px !important;
                }
                .card, .border, .p-4 {
                  page-break-inside: avoid !important;
                  background: white !important;
                  border-color: #e2e8f0 !important;
                }
              }
            `}} />
            <DialogHeader className="border-b border-slate-100 dark:border-slate-800 pb-4">
              <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                <div className="flex items-center gap-2">
                  <ClipboardCheck className="w-6 h-6 text-primary shrink-0" />
                  <DialogTitle className="text-xl font-bold text-slate-900 dark:text-slate-155">
                    Processo {selectedVistoria.data.processo_n || 'N/A'}
                  </DialogTitle>
                </div>
                <div className="flex items-center gap-2">
                  {getTypeBadge(getVistoriaType(selectedVistoria))}
                  <span className="text-xs font-mono text-muted-foreground bg-slate-100 dark:bg-slate-850 px-2 py-0.5 rounded">
                    ID: {selectedVistoria.local_id}
                  </span>
                </div>
              </div>
              <DialogDescription className="pt-2">
                Dados completos e preenchimento de campo do requerente <strong>{selectedVistoria.data.requerente || 'Não informado'}</strong>.
              </DialogDescription>
            </DialogHeader>

            {/* Grid content of Vistoria */}
            <div className="grid md:grid-cols-3 gap-6 py-4 flex-1 min-h-0 print:overflow-visible">
              
              {/* Left Side: General Info */}
              <div className="md:col-span-1 space-y-4 overflow-y-auto max-h-full pr-2 scrollbar-thin print:overflow-visible print:max-h-none">
                <h4 className="font-bold text-sm text-slate-900 dark:text-slate-100 border-b pb-2 uppercase tracking-wide">Informações Gerais</h4>
                
                <div className="space-y-3 text-xs">
                  <div>
                    <span className="text-muted-foreground block">Requerente</span>
                    <span className="font-semibold text-slate-800 dark:text-slate-200">{selectedVistoria.data.requerente || '-'}</span>
                  </div>
                  <div>
                    <span className="text-muted-foreground block">Técnico Resp.</span>
                    <span className="font-semibold text-slate-800 dark:text-slate-200">{getUserName(selectedVistoria.user)}</span>
                  </div>
                  <div>
                    <span className="text-muted-foreground block">Dispositivo de Origem</span>
                    <span className="font-semibold text-slate-800 dark:text-slate-200 flex items-center gap-1 mt-0.5">
                      <Smartphone className="w-3.5 h-3.5 text-slate-400" />
                      {selectedVistoria.data.dispositivo || 'Não informado'}
                    </span>
                  </div>

                  <div>
                    <span className="text-muted-foreground block">Município</span>
                    <span className="font-semibold text-slate-800 dark:text-slate-200">
                      {selectedVistoria.data.municipio_nome || selectedVistoria.data.municipio || '-'}
                    </span>
                  </div>
                  <div>
                    <span className="text-muted-foreground block">Coordenadas Geográficas</span>
                    {selectedVistoria.data.latitude && selectedVistoria.data.longitude ? (
                      <div className="flex items-center gap-1 font-mono text-[11px] text-slate-800 dark:text-slate-200">
                        <MapPin className="w-3.5 h-3.5 text-red-500 shrink-0" />
                        <span>{selectedVistoria.data.latitude.toFixed(6)}, {selectedVistoria.data.longitude.toFixed(6)}</span>
                      </div>
                    ) : (
                      <span>Não georreferenciado</span>
                    )}
                  </div>
                  <div>
                    <span className="text-muted-foreground block">Criado Em (Celular)</span>
                    <span className="font-semibold text-slate-800 dark:text-slate-200">{formatDate(selectedVistoria.created_at)}</span>
                  </div>
                  <div>
                    <span className="text-muted-foreground block">Sincronizado No Servidor</span>
                    <span className="font-semibold text-slate-800 dark:text-slate-200">{formatDate(selectedVistoria.synced_at)}</span>
                  </div>
                </div>

                {/* Live Google Maps Preview */}
                {selectedVistoria.data.latitude && selectedVistoria.data.longitude && (
                  <div className="bg-slate-100 dark:bg-slate-900 rounded-lg p-3 text-center border space-y-2">
                    <div className="text-[10px] uppercase font-bold text-muted-foreground tracking-wider">Localização da Vistoria</div>
                    <div className="bg-slate-200 dark:bg-slate-800 h-48 rounded-lg overflow-hidden border border-slate-300 dark:border-slate-700 relative">
                      <iframe
                        title="Localização da Vistoria"
                        width="100%"
                        height="100%"
                        style={{ border: 0 }}
                        loading="lazy"
                        allowFullScreen
                        referrerPolicy="no-referrer-when-downgrade"
                        src={`https://maps.google.com/maps?q=${selectedVistoria.data.latitude},${selectedVistoria.data.longitude}&z=15&output=embed`}
                      />
                    </div>
                    <a 
                      href={`https://www.google.com/maps/search/?api=1&query=${selectedVistoria.data.latitude},${selectedVistoria.data.longitude}`}
                      target="_blank" 
                      rel="noopener noreferrer"
                      className="text-[11px] text-blue-500 hover:underline block font-semibold"
                    >
                      Ver no Google Maps Ampliado →
                    </a>
                  </div>
                )}
              </div>

              {/* Right Side: Specific Sub-model Form Details */}
              <div className="md:col-span-2 space-y-4 overflow-y-auto max-h-full pr-2 scrollbar-thin print:overflow-visible print:max-h-none">
                <h4 className="font-bold text-sm text-slate-900 dark:text-slate-100 border-b pb-2 uppercase tracking-wide">Ficha Técnica do Formulário</h4>

                {/* SUPRESSÃO VEGETAL UI */}
                {selectedVistoria.data.supressao && (
                  <div className="space-y-6">
                    
                    {/* CARD 1: Áreas Protegidas e Reserva Legal */}
                    <div className="bg-emerald-50/20 dark:bg-emerald-950/5 p-4 rounded-lg border border-emerald-100/40 dark:border-emerald-900/10 space-y-3">
                      <div className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                        <Trees className="w-4 h-4" />
                        <span>1. Áreas Protegidas e Reserva Legal</span>
                      </div>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                        {renderBoolField(selectedVistoria.data.supressao.tem_curso_dagua, "Curso d'água, nascente ou lago no imóvel")}
                        {renderBoolField(selectedVistoria.data.supressao.app_preservada, "Vegetação de APP preservada")}
                        {renderBoolField(selectedVistoria.data.supressao.indicios_uso_app, "Indícios de uso ou supressão dentro de APP")}
                        {renderBoolField(selectedVistoria.data.supressao.rl_isolada, "Reserva Legal isolada de atividades produtivas")}
                        {renderBoolField(selectedVistoria.data.supressao.rl_nativa_compativel, "Vegetação de Reserva Legal compatível com CAR")}
                      </div>
                    </div>

                    {/* CARD 2: Bioma e Estágio Sucessional */}
                    <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                      <div className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                        <Sprout className="w-4 h-4" />
                        <span>2. Bioma e Estrutura Florestal</span>
                      </div>
                      <div className="grid grid-cols-2 gap-4 text-xs">
                        <div>
                          <span className="text-muted-foreground block font-medium">Bioma Predominante</span>
                          <span className="font-bold text-sm text-slate-800 dark:text-slate-200">
                            {selectedVistoria.data.supressao.bioma === 'MA' ? 'Mata Atlântica' : 
                             selectedVistoria.data.supressao.bioma === 'CAATINGA' ? 'Caatinga' : 
                             selectedVistoria.data.supressao.bioma || '-'}
                          </span>
                        </div>
                        {selectedVistoria.data.supressao.bioma === 'CAATINGA' && (
                          <div>
                            <span className="text-muted-foreground block font-medium">Estrutura da Vegetação (Caatinga)</span>
                            <span className="font-bold text-sm text-slate-800 dark:text-slate-200">
                              {selectedVistoria.data.supressao.bloco_b_estrutura || '-'}
                            </span>
                          </div>
                        )}
                      </div>

                      {/* Bloco A: Mata Atlântica Details */}
                      {selectedVistoria.data.supressao.bioma === 'MA' && (() => {
                        const s = selectedVistoria.data.supressao;
                        
                        // Determine stage
                        const estagio = s.bloco_a_estagio_sucessional || (
                          (!s.bloco_a_dap && !s.bloco_a_altura) ? 'Inicial' : 'Médio / Avançado'
                        );

                        // Determine details
                        const dap = s.bloco_a_dap_opcao || (s.bloco_a_dap ? 'Superior a 8 cm' : 'Até 8 cm');
                        const altura = s.bloco_a_altura_opcao || (s.bloco_a_altura ? 'Superior a 5 m' : 'Até 5 m');
                        const serapilheira = s.bloco_a_serapilheira_opcao || (s.bloco_a_serapilheira ? 'Presente e contínua' : 'Pouca ou Nenhuma');
                        const epifitas = s.bloco_a_epifitas_opcao || (s.bloco_a_epifitas ? 'Presente (briófitas/pteridófitas)' : 'Pouca ou Nenhuma');
                        const subbosque = s.bloco_a_subbosque_opcao || (s.bloco_a_subbosque ? 'Presente com diversidade' : 'Pouco desenvolvido / Ausente');
                        const obs = s.bloco_a_observacoes;

                        return (
                          <div className="border-t pt-3 space-y-3">
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-semibold text-slate-500">Estágio Sucessional (Mata Atlântica):</span>
                              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400">
                                {estagio}
                              </span>
                            </div>

                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border border-slate-100 dark:border-slate-800">
                                <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">DAP Médio</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{dap}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border border-slate-100 dark:border-slate-800">
                                <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">Altura (Dossel)</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{altura}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border border-slate-100 dark:border-slate-800">
                                <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">Serapilheira</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{serapilheira}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border border-slate-100 dark:border-slate-800">
                                <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">Epífitas / Cipós</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{epifitas}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border border-slate-100 dark:border-slate-800 sm:col-span-2">
                                <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">Sub-bosque</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{subbosque}</span>
                              </div>
                            </div>

                            {obs && (
                              <div className="bg-amber-50/20 dark:bg-amber-950/5 p-3 rounded border border-amber-100/30 dark:border-amber-950/10 text-xs">
                                <span className="text-amber-700 dark:text-amber-400 block font-bold uppercase text-[9px] tracking-wider mb-1">Informações Adicionais (Bloco A):</span>
                                <p className="text-slate-700 dark:text-slate-300 leading-relaxed">{obs}</p>
                              </div>
                            )}
                          </div>
                        );
                      })()}
                    </div>

                    {/* CARD 3: Espécies Invasoras e Exóticas */}
                    <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                      <div className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                        <Activity className="w-4 h-4" />
                        <span>3. Espécies Exóticas e Invasoras</span>
                      </div>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 mb-3">
                        {renderBoolField(selectedVistoria.data.supressao.presenca_exoticas, "Presença de espécies exóticas")}
                        {renderBoolField(selectedVistoria.data.supressao.presenca_invasoras, "Presença de espécies exóticas invasoras")}
                      </div>
                      <div className="grid grid-cols-2 gap-4 text-xs border-t pt-3">
                        <div>
                          <span className="text-muted-foreground block font-medium">Espécies Citadas</span>
                          <span className="font-bold text-slate-800 dark:text-slate-200">
                            {selectedVistoria.data.supressao.especies || 'Nenhuma'}
                          </span>
                        </div>
                        <div>
                          <span className="text-muted-foreground block font-medium">Grau de Infestação</span>
                          <span className="font-bold text-slate-800 dark:text-slate-200">
                            {selectedVistoria.data.supressao.grau_infestacao || 'Nenhum'}
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* CARD 4: Localização da Supressão */}
                    <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                      <div className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                        <MapPin className="w-4 h-4" />
                        <span>4. Localização da Supressão / Intervenção</span>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
                        <div>
                          <span className="text-muted-foreground block font-medium">Área de Preservação Permanente (APP)</span>
                          <p className="bg-white dark:bg-slate-900 p-2 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed min-h-[40px]">
                            {selectedVistoria.data.supressao.loc_app || 'Não ocorre em APP'}
                          </p>
                        </div>
                        <div>
                          <span className="text-muted-foreground block font-medium">Reserva Legal (RL)</span>
                          <p className="bg-white dark:bg-slate-900 p-2 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed min-h-[40px]">
                            {selectedVistoria.data.supressao.loc_rl || 'Não ocorre em Reserva Legal'}
                          </p>
                        </div>
                        <div>
                          <span className="text-muted-foreground block font-medium">Uso Alternativo do Solo (UAS)</span>
                          <p className="bg-white dark:bg-slate-900 p-2 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed min-h-[40px]">
                            {selectedVistoria.data.supressao.loc_uas || 'Não ocorre em UAS'}
                          </p>
                        </div>
                      </div>
                    </div>

                    {/* CARD 5: Fatores de Degradação / Uso do Solo */}
                    <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                      <div className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4"><path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"></path><path d="M12 8v4"></path><path d="M12 16h.01"></path></svg>
                        <span>5. Fatores de Degradação e Registro</span>
                      </div>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 mb-3">
                        {renderBoolField(selectedVistoria.data.supressao.pastos_abandonados, "Área composta por pastos abandonados")}
                        {renderBoolField(selectedVistoria.data.supressao.supressao_solo, "Indícios de supressão ou uso do solo")}
                        {renderBoolField(selectedVistoria.data.supressao.foto_geo_ok, "Registro fotográfico georreferenciado completo")}
                      </div>
                      <div className="border-t pt-3 space-y-2">
                        <span className="text-xs font-semibold text-slate-500 block">Indícios de Ocorrência de Fogo/Incêndio:</span>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                          {renderBoolField(selectedVistoria.data.supressao.fogo_app, "Ocorrência de fogo em APP")}
                          {renderBoolField(selectedVistoria.data.supressao.fogo_rl, "Ocorrência de fogo em Reserva Legal")}
                          {renderBoolField(selectedVistoria.data.supressao.fogo_uas, "Ocorrência de fogo em UAS")}
                          {renderBoolField(selectedVistoria.data.supressao.fogo_outras, "Ocorrência de fogo em outras áreas")}
                        </div>
                      </div>
                    </div>

                    {/* CARD 6: Infrações e Medidas DIFI */}
                    <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                      <div className="text-xs font-bold uppercase tracking-wider text-rose-600 dark:text-rose-400 flex items-center gap-2">
                        <ClipboardCheck className="w-4 h-4" />
                        <span>6. Diagnóstico Administrativo e Fiscalização (DIFI)</span>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                        <div>
                          <span className="text-muted-foreground block font-semibold mb-1">Infração Constatada / Descrição</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 leading-relaxed min-h-[50px] font-semibold text-red-600 dark:text-red-400">
                            {selectedVistoria.data.supressao.infracao || 'Nenhuma infração ambiental identificada.'}
                          </p>
                        </div>
                        <div>
                          <span className="text-muted-foreground block font-semibold mb-1">Medidas Sugeridas à DIFI</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 leading-relaxed min-h-[50px] font-semibold text-blue-600 dark:text-blue-400">
                            {selectedVistoria.data.supressao.medida_sugerida || 'Nenhuma medida sugerida.'}
                          </p>
                        </div>
                      </div>
                    </div>

                    {/* Observações Técnicas */}
                    {selectedVistoria.data.supressao.observacoes && (
                      <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-2">
                        <span className="text-xs font-bold uppercase tracking-wider text-slate-500 block">Observações Técnicas Gerais</span>
                        <p className="bg-white dark:bg-slate-900 p-3 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 leading-relaxed text-xs">
                          {selectedVistoria.data.supressao.observacoes}
                        </p>
                      </div>
                    )}

                  </div>
                )}

                {/* AVICULTURA UI */}
                {selectedVistoria.data.avicultura && (() => {
                  const avi = selectedVistoria.data.avicultura;
                  const isCorte = (avi.modelo || '').toUpperCase() === 'CORTE';
                  
                  return (
                    <div className="space-y-6">
                      {/* 1. Modelo de Produção */}
                      <div className="bg-amber-50/20 dark:bg-amber-950/5 p-4 rounded-lg border border-amber-100 dark:border-amber-950/20 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-amber-600 dark:text-amber-400 flex items-center gap-2">
                          <Egg className="w-4 h-4" />
                          <span>1. Modelo de Produção</span>
                        </div>
                        <div className="grid grid-cols-2 gap-4 text-xs">
                          <div>
                            <span className="text-muted-foreground block font-medium">Modelo Principal</span>
                            <span className="font-bold text-sm text-slate-800 dark:text-slate-200">
                              {isCorte ? 'Corte (Frango)' : 'Postura (Ovos)'}
                            </span>
                          </div>
                        </div>
                      </div>

                      {/* 2. Bloco Corte */}
                      {isCorte && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-4">
                          <div className="text-xs font-bold uppercase tracking-wider text-amber-600 dark:text-amber-400 flex items-center gap-2">
                            <Trees className="w-4 h-4" />
                            <span>2. Detalhes da Avicultura de Corte</span>
                          </div>
                          <div className="grid grid-cols-2 gap-4 text-xs">
                            <div>
                              <span className="text-muted-foreground block font-medium">Sistema de Criação</span>
                              <span className="font-bold text-slate-800 dark:text-slate-200">{avi.corte_sistema_criacao || 'Não informado'}</span>
                            </div>
                            <div>
                              <span className="text-muted-foreground block font-medium">Densidade Recomendada</span>
                              <span className="font-bold text-slate-800 dark:text-slate-200">{avi.corte_densidade || 'Não informado'}</span>
                            </div>
                          </div>

                          <div className="border-t pt-3">
                            <span className="text-xs font-semibold text-slate-500 block mb-2">Características Observadas no Galpão:</span>
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                              {renderBoolField(avi.corte_aves_soltas_chao, "Aves criadas soltas no chão")}
                              {renderBoolField(avi.corte_cama_casca_arroz, "Criação sobre cama (casca de arroz)")}
                              {renderBoolField(avi.corte_galpoes_longos, "Galpões longos")}
                              {renderBoolField(avi.corte_galpoes_curtos, "Galpões curtos")}
                              {renderBoolField(avi.corte_bebedouros_chao, "Bebedouros no chão")}
                              {renderBoolField(avi.corte_bebedouros_suspensos, "Bebedouros suspensos")}
                              {renderBoolField(avi.corte_comedouros_chao, "Comedouros no chão")}
                              {renderBoolField(avi.corte_comedouros_suspensos, "Comedouros suspensos")}
                              {renderBoolField(avi.corte_pintos, "Pintos")}
                              {renderBoolField(avi.corte_frangos, "Frangos")}
                              {renderBoolField(avi.corte_ventiladores, "Possui ventiladores internos")}
                              {renderBoolField(avi.corte_ventiladores_func, "Ventiladores funcionando adequadamente")}
                              {renderBoolField(avi.corte_sem_ventiladores, "Não possui ventiladores")}
                            </div>
                          </div>

                          {avi.corte_info_adicional && (
                            <div className="bg-white dark:bg-slate-900 p-3 rounded border text-xs">
                              <span className="text-muted-foreground block font-bold text-[9px] uppercase tracking-wider mb-1">Observações Adicionais:</span>
                              <p className="text-slate-700 dark:text-slate-350 leading-relaxed">{avi.corte_info_adicional}</p>
                            </div>
                          )}

                          <div className="border-t pt-3 space-y-3">
                            <span className="text-xs font-semibold text-slate-500 block">Estimativa de Produção e Área:</span>
                            <div className="grid grid-cols-1 sm:grid-cols-4 gap-2 text-xs">
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                                <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Comprimento</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{avi.corte_comprimento ? `${avi.corte_comprimento} m` : '-'}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                                <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Largura</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{avi.corte_largura ? `${avi.corte_largura} m` : '-'}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                                <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Área Galpão</span>
                                <span className="font-bold text-slate-800 dark:text-slate-200">{avi.corte_area ? `${avi.corte_area.toFixed(2)} m²` : '-'}</span>
                              </div>
                              <div className="bg-amber-100/50 dark:bg-amber-950/20 p-2.5 rounded border border-amber-200">
                                <span className="text-amber-700 dark:text-amber-400 block text-[9px] uppercase font-bold tracking-wider mb-0.5">Quantidade Estimada</span>
                                <span className="font-black text-amber-800 dark:text-amber-400">{avi.corte_qtd_estimada ? Number(avi.corte_qtd_estimada).toLocaleString('pt-BR') : '-'}</span>
                              </div>
                            </div>
                          </div>

                          <div className="border-t pt-3 text-xs">
                            <span className="text-muted-foreground block font-medium">Destinação da Cama de Frango</span>
                            <span className="font-bold text-slate-800 dark:text-slate-200">{avi.corte_cama_destinacao || 'Não informado'}</span>
                            {avi.corte_cama_destinacao === 'Outros' && avi.corte_cama_outros && (
                              <p className="bg-white dark:bg-slate-900 p-2 rounded border text-slate-600 dark:text-slate-400 mt-1 leading-relaxed">
                                {avi.corte_cama_outros}
                              </p>
                            )}
                          </div>
                        </div>
                      )}

                      {/* 3. Bloco Postura */}
                      {!isCorte && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-4">
                          <div className="text-xs font-bold uppercase tracking-wider text-amber-600 dark:text-amber-400 flex items-center gap-2">
                            <Sprout className="w-4 h-4" />
                            <span>2. Detalhes da Avicultura de Postura</span>
                          </div>
                          <div className="grid grid-cols-2 gap-4 text-xs">
                            <div>
                              <span className="text-muted-foreground block font-medium">Sistema de Criação</span>
                              <span className="font-bold text-slate-800 dark:text-slate-200">{avi.postura_sistema_criacao || 'Não informado'}</span>
                            </div>
                            <div>
                              <span className="text-muted-foreground block font-medium">Tipo de Confinamento</span>
                              <span className="font-bold text-slate-800 dark:text-slate-200">{avi.postura_tipo_confinamento || 'Não informado'}</span>
                            </div>
                          </div>

                          {avi.postura_info_adicional && (
                            <div className="bg-white dark:bg-slate-900 p-3 rounded border text-xs">
                              <span className="text-muted-foreground block font-bold text-[9px] uppercase tracking-wider mb-1">Observações Adicionais:</span>
                              <p className="text-slate-700 dark:text-slate-350 leading-relaxed">{avi.postura_info_adicional}</p>
                            </div>
                          )}

                          <div className="border-t pt-3 space-y-3">
                            <span className="text-xs font-semibold text-slate-500 block">Especificações dos Módulos e Gaiolas:</span>
                            <div className="grid grid-cols-1 sm:grid-cols-5 gap-2 text-xs">
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                                <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Nº Fileiras</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{avi.postura_fileiras || '-'}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                                <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Nº Andares</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{avi.postura_andares || '-'}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                                <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Gaiolas / Mód</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{avi.postura_gaiolas_modulo || '-'}</span>
                              </div>
                              <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                                <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Aves / Gaiola</span>
                                <span className="font-semibold text-slate-800 dark:text-slate-200">{avi.postura_aves_gaiola || '-'}</span>
                              </div>
                              <div className="bg-amber-100/50 dark:bg-amber-950/20 p-2.5 rounded border border-amber-200">
                                <span className="text-amber-700 dark:text-amber-400 block text-[9px] uppercase font-bold tracking-wider mb-0.5">Quantidade Total</span>
                                <span className="font-black text-amber-800 dark:text-amber-400">{avi.postura_qtd_estimada ? Number(avi.postura_qtd_estimada).toLocaleString('pt-BR') : '-'}</span>
                              </div>
                            </div>
                          </div>
                        </div>
                      )}

                      {/* 4. Resíduos e Segurança Ambiental */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                          <Activity className="w-4 h-4" />
                          <span>3. Segurança Ambiental e Resíduos</span>
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                          {renderBoolField(avi.gera_residuos, "Geração de resíduos no local")}
                          {renderBoolField(avi.mortos_incinerados, "Animais mortos incinerados")}
                          {renderBoolField(avi.foto_geo_ok, "Registro fotográfico georreferenciado ok")}
                        </div>
                        {avi.gera_residuos && avi.residuos_detalhes && (
                          <div className="border-t pt-2 text-xs">
                            <span className="text-muted-foreground block font-bold text-[9px] uppercase tracking-wider mb-1">Detalhes dos Resíduos:</span>
                            <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 text-slate-700 dark:text-slate-300 leading-relaxed">{avi.residuos_detalhes}</p>
                          </div>
                        )}
                        {!avi.mortos_incinerados && avi.mortos_destinacao_alt && (
                          <div className="border-t pt-2 text-xs">
                            <span className="text-muted-foreground block font-bold text-[9px] uppercase tracking-wider mb-1">Destinação alternativa dos animais mortos:</span>
                            <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 text-slate-700 dark:text-slate-300 leading-relaxed">{avi.mortos_destinacao_alt}</p>
                          </div>
                        )}
                      </div>

                      {/* 5. Diagnóstico DIFI */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-rose-600 dark:text-rose-400 flex items-center gap-2">
                          <ClipboardCheck className="w-4 h-4" />
                          <span>4. Diagnóstico Administrativo e Fiscalização (DIFI)</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                          <div>
                            <span className="text-muted-foreground block font-semibold mb-1">Constatação de Infração</span>
                            <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-bold ${avi.infracao_constatada ? 'bg-red-100 text-red-800' : 'bg-slate-100 text-slate-800'}`}>
                              {avi.infracao_constatada ? 'Sim, Houve infração' : 'Não'}
                            </span>
                          </div>
                          <div>
                            <span className="text-muted-foreground block font-semibold mb-1">Medidas Sugeridas</span>
                            <span className="font-bold text-blue-600 dark:text-blue-400">{avi.medida_sugerida || 'Nenhuma medida sugerida.'}</span>
                          </div>
                        </div>
                      </div>

                      {/* 6. Parecer Técnico */}
                      {avi.observacoes && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-2">
                          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 block">Parecer Técnico / Informações Complementares</span>
                          <p className="bg-white dark:bg-slate-900 p-3 rounded border border-slate-200 text-slate-700 dark:text-slate-350 leading-relaxed text-xs">
                            {avi.observacoes}
                          </p>
                        </div>
                      )}
                    </div>
                  );
                })()}

                {/* SUINOCULTURA UI */}
                {selectedVistoria.data.suinocultura && (() => {
                  const sui = selectedVistoria.data.suinocultura;
                  const isIndustrial = (sui.modelo || '').toUpperCase() === 'INDUSTRIAL';
                  
                  return (
                    <div className="space-y-6">
                      {/* 1. Modelo de Produção */}
                      <div className="bg-pink-50/20 dark:bg-pink-950/5 p-4 rounded-lg border border-pink-100 dark:border-pink-950/20 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-pink-600 dark:text-pink-400 flex items-center gap-2">
                          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4"><path d="M12 2a5 5 0 0 1 5 5v3a5 5 0 0 1-5 5H8a5 5 0 0 1-5-5V7a5 5 0 0 1 5-5z"></path><path d="M6 18c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2"></path></svg>
                          <span>1. Modelo de Produção</span>
                        </div>
                        <div className="grid grid-cols-2 gap-4 text-xs">
                          <div>
                            <span className="text-muted-foreground block font-medium">Modelo Principal</span>
                            <span className="font-bold text-sm text-slate-800 dark:text-slate-200">
                              {isIndustrial ? 'Industrial' : 'Caipira'}
                            </span>
                          </div>
                        </div>
                      </div>

                      {/* 2. Capacidade e Infraestrutura */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-4">
                        <div className="text-xs font-bold uppercase tracking-wider text-pink-600 dark:text-pink-400 flex items-center gap-2">
                          <Activity className="w-4 h-4" />
                          <span>2. Capacidade e Infraestrutura</span>
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-2 text-xs">
                          <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                            <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Nº de Galpões</span>
                            <span className="font-semibold text-slate-800 dark:text-slate-200">{sui.qtd_galpoes ?? '-'}</span>
                          </div>
                          <div className="bg-slate-100/50 dark:bg-slate-900/50 p-2.5 rounded border">
                            <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider mb-0.5">Média por Galpão</span>
                            <span className="font-semibold text-slate-800 dark:text-slate-200">{sui.qtd_medio_por_galpao ?? '-'}</span>
                          </div>
                          <div className="bg-pink-100/50 dark:bg-pink-950/20 p-2.5 rounded border border-pink-200">
                            <span className="text-pink-700 dark:text-pink-400 block text-[9px] uppercase font-bold tracking-wider mb-0.5">Quantidade Total</span>
                            <span className="font-black text-pink-800 dark:text-pink-400">{sui.qtd_animais ? Number(sui.qtd_animais).toLocaleString('pt-BR') : '-'}</span>
                          </div>
                        </div>

                        {/* Fases */}
                        <div className="border-t pt-3">
                          <span className="text-xs font-semibold text-slate-500 block mb-2">Fases de Produção & Estimativas:</span>
                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                            {renderBoolField(sui.fase_terminacao, `Suíno em terminação ${sui.fase_terminacao && sui.fase_terminacao_qtd ? `(Est: ${sui.fase_terminacao_qtd})` : ''}`)}
                            {renderBoolField(sui.fase_matrizes, `Matrizes gestantes ${sui.fase_matrizes && sui.fase_matrizes_qtd ? `(Est: ${sui.fase_matrizes_qtd})` : ''}`)}
                            {renderBoolField(sui.fase_reprodutores, `Reprodutores ${sui.fase_reprodutores && sui.fase_reprodutores_qtd ? `(Est: ${sui.fase_reprodutores_qtd})` : ''}`)}
                            {renderBoolField(sui.fase_adulto, `Suíno adulto ${sui.fase_adulto && sui.fase_adulto_qtd ? `(Est: ${sui.fase_adulto_qtd})` : ''}`)}
                          </div>
                        </div>
                      </div>

                      {/* 3. Diagnóstico Sanitário e Ambiental */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                          <Activity className="w-4 h-4" />
                          <span>3. Segurança Sanitária e Ambiental</span>
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                          {renderBoolField(sui.acumulo_residuos, "Existe acúmulo de Resíduos")}
                          {renderBoolField(sui.vazamento_dejetos, "Há vazamento de dejetos para fora do sistema")}
                          {renderBoolField(sui.odor_extremo, "Há odor extremo")}
                          {renderBoolField(sui.dejetos_transbordando, "Os dejetos estão transbordando")}
                          {renderBoolField(sui.impermeabilizacao_contencao, "Existe sistema de impermeabilização e contenção")}
                          {renderBoolField(sui.destinacao_adequada, "Existe destinação adequada e/ou tratamento")}
                        </div>
                      </div>

                      {/* 4. Manejo & Porte */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-pink-600 dark:text-pink-400 flex items-center gap-2">
                          <Smartphone className="w-4 h-4" />
                          <span>4. Manejo e Destinação Animal</span>
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                          {renderBoolField(sui.indicios_porte_maior, "Indícios de porte maior ou manejo inadequado")}
                          {renderBoolField(sui.mortos_incinerados, "Animais mortos são incinerados")}
                        </div>

                        {sui.indicios_porte_maior && sui.indicios_porte_maior_detalhe && (
                          <div className="border-t pt-2 text-xs">
                            <span className="text-muted-foreground block font-bold text-[9px] uppercase tracking-wider mb-1">Detalhes do Porte/Manejo Inadequado:</span>
                            <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 text-slate-700 dark:text-slate-350 leading-relaxed">{sui.indicios_porte_maior_detalhe}</p>
                          </div>
                        )}

                        {!sui.mortos_incinerados && sui.mortos_destino && (
                          <div className="border-t pt-2 text-xs">
                            <span className="text-muted-foreground block font-bold text-[9px] uppercase tracking-wider mb-1">Destinação alternativa dos animais mortos:</span>
                            <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 text-slate-700 dark:text-slate-350 leading-relaxed">{sui.mortos_destino}</p>
                          </div>
                        )}
                      </div>

                      {/* 5. Diagnóstico DIFI */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-rose-600 dark:text-rose-400 flex items-center gap-2">
                          <ClipboardCheck className="w-4 h-4" />
                          <span>5. Diagnóstico Administrativo e Fiscalização (DIFI)</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                          <div>
                            <span className="text-muted-foreground block font-semibold mb-1">Constatação de Infração</span>
                            <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-bold ${sui.infracao_constatada ? 'bg-red-100 text-red-800' : 'bg-slate-100 text-slate-800'}`}>
                              {sui.infracao_constatada ? 'Sim, Houve infração' : 'Não'}
                            </span>
                          </div>
                          <div>
                            <span className="text-muted-foreground block font-semibold mb-1">Medidas Sugeridas</span>
                            <span className="font-bold text-blue-600 dark:text-blue-400">{sui.medida_sugerida || 'Nenhuma medida sugerida.'}</span>
                          </div>
                        </div>
                      </div>

                      {/* 6. Parecer Técnico */}
                      {sui.observacoes && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-2">
                          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 block">Parecer Técnico / Informações Complementares</span>
                          <p className="bg-white dark:bg-slate-900 p-3 rounded border border-slate-200 text-slate-700 dark:text-slate-350 leading-relaxed text-xs">
                            {sui.observacoes}
                          </p>
                        </div>
                      )}
                    </div>
                  );
                })()}

                {/* BOVINOCULTURA UI */}
                {selectedVistoria.data.bovinocultura && (() => {
                  const bov = selectedVistoria.data.bovinocultura;
                  const isIntensivo = bov.modelo?.toUpperCase() === 'INTENSIVO';
                  return (
                    <div className="space-y-4">
                      {/* Sub-header card */}
                      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-4 rounded-lg bg-amber-50/20 dark:bg-amber-950/10 border border-amber-100/40 dark:border-amber-950/20">
                        <div className="flex items-center gap-3">
                          <div className="p-2 rounded bg-amber-100/60 dark:bg-amber-950/40 text-amber-800 dark:text-amber-350">
                            <Sprout className="w-5 h-5 text-amber-600 dark:text-amber-400" />
                          </div>
                          <div>
                            <span className="text-[10px] text-muted-foreground uppercase font-bold tracking-wider block">Modalidade de Criação</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-200">
                              {isIntensivo ? 'Intensivo (Confinamento)' : 'Extensivo (Pasto)'}
                            </span>
                          </div>
                        </div>
                        <div className="flex flex-wrap gap-2">
                          {renderBoolField(bov.foto_geo_ok, "Foto Georreferenciada em conformidade")}
                        </div>
                      </div>

                      {/* 1. Dimensionamento e Infraestrutura */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-slate-600 dark:text-slate-400 flex items-center gap-2">
                          <Maximize2 className="w-4 h-4 text-amber-600" />
                          <span>1. Dimensionamento e Infraestrutura</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 text-xs">
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40">
                            <span className="text-muted-foreground block font-medium mb-0.5">Área Destinada à Criação</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100">
                              {bov.area_ha ? `${bov.area_ha} ha` : '-'}
                            </span>
                          </div>
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40">
                            <span className="text-muted-foreground block font-medium mb-0.5">Quantidade de Cochos</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100">
                              {bov.qtd_cochos !== undefined && bov.qtd_cochos !== null ? bov.qtd_cochos : '-'}
                            </span>
                          </div>
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40">
                            <span className="text-muted-foreground block font-medium mb-0.5">Tamanho dos Cochos</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100">
                              {bov.tamanho_cochos ? `${bov.tamanho_cochos} m` : '-'}
                            </span>
                          </div>
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40">
                            <span className="text-muted-foreground block font-medium mb-0.5">Quantidade de Animais</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100">
                              {bov.qtd_animais !== undefined && bov.qtd_animais !== null ? bov.qtd_animais : '-'}
                            </span>
                          </div>
                        </div>
                      </div>

                      {/* 2. Dessedentação */}
                      {bov.dessedentacao && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-2">
                          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 block">Dessedentação Animal</span>
                          <p className="bg-white dark:bg-slate-900 p-3 rounded border border-slate-200 text-slate-700 dark:text-slate-350 leading-relaxed text-xs">
                            {bov.dessedentacao}
                          </p>
                        </div>
                      )}

                      {/* 3. Diagnóstico DIFI */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-rose-600 dark:text-rose-400 flex items-center gap-2">
                          <ClipboardCheck className="w-4 h-4" />
                          <span>3. Diagnóstico Administrativo e Fiscalização (DIFI)</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                          <div>
                            <span className="text-muted-foreground block font-semibold mb-1">Constatação de Infração</span>
                            <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-bold ${bov.infracao_constatada ? 'bg-red-100 text-red-800' : 'bg-slate-100 text-slate-800'}`}>
                              {bov.infracao_constatada ? 'Sim, Houve infração' : 'Não'}
                            </span>
                          </div>
                          <div>
                            <span className="text-muted-foreground block font-semibold mb-1">Medidas Sugeridas</span>
                            <span className="font-bold text-blue-600 dark:text-blue-400">{bov.medida_sugerida || 'Nenhuma medida sugerida.'}</span>
                          </div>
                        </div>
                      </div>

                      {/* 4. Parecer Técnico */}
                      {bov.observacoes && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-2">
                          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 block">Parecer Técnico / Informações Complementares</span>
                          <p className="bg-white dark:bg-slate-900 p-3 rounded border border-slate-200 text-slate-700 dark:text-slate-350 leading-relaxed text-xs">
                            {bov.observacoes}
                          </p>
                        </div>
                      )}
                    </div>
                  );
                })()}

                {/* AQUICULTURA UI */}
                {selectedVistoria.data.aquicultura && (() => {
                  const aq = selectedVistoria.data.aquicultura;
                  const hasManyAeradores = aq.possui_aeradores && aq.qtd_aeradores && aq.qtd_aeradores >= 3;
                  const isAreaExceeded = aq.area_tanques && aq.area_tanques > 4.9; // 7 campos * 0.7ha
                  
                  return (
                    <div className="space-y-4">
                      {/* Sub-header card */}
                      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-4 rounded-lg bg-cyan-50/20 dark:bg-cyan-950/10 border border-cyan-100/40 dark:border-cyan-950/20">
                        <div className="flex items-center gap-3">
                          <div className="p-2 rounded bg-cyan-100/60 dark:bg-cyan-950/40 text-cyan-800 dark:text-cyan-350">
                            <Waves className="w-5 h-5 text-cyan-600 dark:text-cyan-400" />
                          </div>
                          <div>
                            <span className="text-[10px] text-muted-foreground uppercase font-bold tracking-wider block">Atividade</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-200">
                              Aquicultura (Piscicultura e Carcinicultura)
                            </span>
                          </div>
                        </div>
                        <div className="flex flex-wrap gap-2">
                          {renderBoolField(aq.foto_geo_ok, "Foto Georreferenciada")}
                        </div>
                      </div>

                      {/* 1. Capacidade e Dimensionamento */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-slate-600 dark:text-slate-400 flex items-center gap-2">
                          <Maximize2 className="w-4 h-4 text-cyan-600" />
                          <span>1. Capacidade e Viveiros</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40">
                            <span className="text-muted-foreground block font-medium mb-0.5">Número de Tanques</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100">
                              {aq.qtd_tanques !== undefined && aq.qtd_tanques !== null ? aq.qtd_tanques : '-'}
                            </span>
                          </div>
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40">
                            <span className="text-muted-foreground block font-medium mb-0.5">Área dos Tanques</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100">
                              {aq.area_tanques ? `${aq.area_tanques} ha` : '-'}
                            </span>
                          </div>
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40">
                            <span className="text-muted-foreground block font-medium mb-0.5">Tanque possui Aeradores?</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100">
                              {aq.possui_aeradores ? `Sim (${aq.qtd_aeradores || 0} p/ tanque)` : 'Não'}
                            </span>
                          </div>
                        </div>

                        {/* Alerta de Aeradores */}
                        {hasManyAeradores && (
                          <div className="flex gap-2.5 p-3 rounded bg-amber-500/10 border border-amber-500/20 text-amber-800 dark:text-amber-300 text-xs leading-relaxed">
                            <AlertTriangle className="w-4 h-4 shrink-0 text-amber-600 dark:text-amber-400" />
                            <div>
                              <span className="font-bold">Alerta de Intensidade: </span>
                              Há {aq.qtd_aeradores} aeradores por tanque. Um sistema com 3 ou mais aeradores em tanques pequenos pode configurar um sistema intensivo com maior potencial poluidor.
                            </div>
                          </div>
                        )}

                        {/* Alerta de Campo de Futebol (Incompatibilidade) */}
                        {isAreaExceeded && (
                          <div className="flex gap-2.5 p-3 rounded bg-rose-500/10 border border-rose-500/20 text-rose-800 dark:text-rose-300 text-xs leading-relaxed">
                            <AlertCircle className="w-4 h-4 shrink-0 text-rose-600 dark:text-rose-400" />
                            <div>
                              <span className="font-bold">Incompatibilidade Técnica: </span>
                              A soma visual dos viveiros ({aq.area_tanques} ha) ultrapassa 7 campos de futebol (~4.9 ha). A dispensa de licenciamento ambiental pode ser incompatível com a escala do empreendimento.
                            </div>
                          </div>
                        )}
                      </div>

                      {/* 2. Itens Identificados e Infraestrutura */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-slate-600 dark:text-slate-400 flex items-center gap-2">
                          <Wrench className="w-4 h-4 text-cyan-600" />
                          <span>2. Equipamentos e Infraestrutura Identificados</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
                          {/* BOMBA */}
                          <div className="p-3 rounded border bg-white dark:bg-slate-950 border-slate-150/40 dark:border-slate-800/40 space-y-1">
                            <div className="flex items-center justify-between">
                              <span className="font-bold text-slate-700 dark:text-slate-350">BOMBA</span>
                              {aq.bomba_identificada ? (
                                <span className="bg-emerald-100 text-emerald-800 dark:bg-emerald-950/45 dark:text-emerald-400 px-2 py-0.5 rounded text-[10px] font-bold">Identificado</span>
                              ) : (
                                <span className="bg-slate-100 text-slate-500 dark:bg-slate-900 dark:text-slate-600 px-2 py-0.5 rounded text-[10px]">Não Consta</span>
                              )}
                            </div>
                            {aq.bomba_identificada && aq.bomba_situacao && (
                              <p className="text-[11px] text-slate-600 dark:text-slate-400 bg-slate-50/80 dark:bg-slate-900/80 p-1.5 rounded border border-slate-100 dark:border-slate-900/60 leading-normal">
                                <span className="font-semibold">Situação:</span> {aq.bomba_situacao}
                              </p>
                            )}
                          </div>

                          {/* TUBULAÇÃO */}
                          <div className="p-3 rounded border bg-white dark:bg-slate-950 border-slate-150/40 dark:border-slate-800/40 space-y-1">
                            <div className="flex items-center justify-between">
                              <span className="font-bold text-slate-700 dark:text-slate-350">TUBULAÇÃO</span>
                              {aq.tubulacao_identificada ? (
                                <span className="bg-emerald-100 text-emerald-800 dark:bg-emerald-950/45 dark:text-emerald-400 px-2 py-0.5 rounded text-[10px] font-bold">Identificado</span>
                              ) : (
                                <span className="bg-slate-100 text-slate-500 dark:bg-slate-900 dark:text-slate-600 px-2 py-0.5 rounded text-[10px]">Não Consta</span>
                              )}
                            </div>
                            {aq.tubulacao_identificada && aq.tubulacao_situacao && (
                              <p className="text-[11px] text-slate-600 dark:text-slate-400 bg-slate-50/80 dark:bg-slate-900/80 p-1.5 rounded border border-slate-100 dark:border-slate-900/60 leading-normal">
                                <span className="font-semibold">Situação:</span> {aq.tubulacao_situacao}
                              </p>
                            )}
                          </div>

                          {/* PONTO DE CAPTAÇÃO */}
                          <div className="p-3 rounded border bg-white dark:bg-slate-950 border-slate-150/40 dark:border-slate-800/40 space-y-1">
                            <div className="flex items-center justify-between">
                              <span className="font-bold text-slate-700 dark:text-slate-350">PONTO DE CAPTAÇÃO</span>
                              {aq.captacao_identificada ? (
                                <span className="bg-emerald-100 text-emerald-800 dark:bg-emerald-950/45 dark:text-emerald-400 px-2 py-0.5 rounded text-[10px] font-bold">Identificado</span>
                              ) : (
                                <span className="bg-slate-100 text-slate-500 dark:bg-slate-900 dark:text-slate-600 px-2 py-0.5 rounded text-[10px]">Não Consta</span>
                              )}
                            </div>
                            {aq.captacao_identificada && aq.captacao_situacao && (
                              <p className="text-[11px] text-slate-600 dark:text-slate-400 bg-slate-50/80 dark:bg-slate-900/80 p-1.5 rounded border border-slate-100 dark:border-slate-900/60 leading-normal">
                                <span className="font-semibold">Situação:</span> {aq.captacao_situacao}
                              </p>
                            )}
                          </div>

                          {/* HIDRÔMETRO */}
                          <div className="p-3 rounded border bg-white dark:bg-slate-950 border-slate-150/40 dark:border-slate-800/40 space-y-1">
                            <div className="flex items-center justify-between">
                              <span className="font-bold text-slate-700 dark:text-slate-350">HIDRÔMETRO</span>
                              {aq.hidrometro ? (
                                <span className="bg-emerald-100 text-emerald-800 dark:bg-emerald-950/45 dark:text-emerald-400 px-2 py-0.5 rounded text-[10px] font-bold">Identificado</span>
                              ) : (
                                <span className="bg-slate-100 text-slate-500 dark:bg-slate-900 dark:text-slate-600 px-2 py-0.5 rounded text-[10px]">Não Consta</span>
                              )}
                            </div>
                            {aq.hidrometro && aq.hidrometro_situacao && (
                              <p className="text-[11px] text-slate-600 dark:text-slate-400 bg-slate-50/80 dark:bg-slate-900/80 p-1.5 rounded border border-slate-100 dark:border-slate-900/60 leading-normal">
                                <span className="font-semibold">Situação:</span> {aq.hidrometro_situacao}
                              </p>
                            )}
                          </div>

                          {/* OUTROS */}
                          <div className="p-3 rounded border bg-white dark:bg-slate-950 border-slate-150/40 dark:border-slate-800/40 space-y-1 col-span-1 md:col-span-2">
                            <div className="flex items-center justify-between">
                              <span className="font-bold text-slate-700 dark:text-slate-350">Outros itens identificados</span>
                              {aq.outros_itens_identificados ? (
                                <span className="bg-emerald-100 text-emerald-800 dark:bg-emerald-950/45 dark:text-emerald-400 px-2 py-0.5 rounded text-[10px] font-bold">Identificado</span>
                              ) : (
                                <span className="bg-slate-100 text-slate-500 dark:bg-slate-900 dark:text-slate-600 px-2 py-0.5 rounded text-[10px]">Não Consta</span>
                              )}
                            </div>
                            {aq.outros_itens_identificados && aq.outros_itens_situacao && (
                              <p className="text-[11px] text-slate-600 dark:text-slate-400 bg-slate-50/80 dark:bg-slate-900/80 p-1.5 rounded border border-slate-100 dark:border-slate-900/60 leading-normal">
                                <span className="font-semibold">Situação:</span> {aq.outros_itens_situacao}
                              </p>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* 3. Recursos Hídricos e Descarte */}
                      <div className="bg-slate-50/50 dark:bg-slate-900/10 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-slate-600 dark:text-slate-400 flex items-center gap-2">
                          <Droplets className="w-4 h-4 text-cyan-600" />
                          <span>3. Recursos Hídricos e Descarte de Resíduos</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                          {/* Outorga */}
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40 space-y-1">
                            <span className="text-muted-foreground block font-medium">Outorga de Água</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100 block">
                              {aq.outorga ? 'Sim, possui outorga' : 'Não possui outorga'}
                            </span>
                            {aq.outorga && aq.outorga_identificacao && (
                              <div className="mt-1 text-[11px] text-slate-600 dark:text-slate-400 bg-slate-50/50 dark:bg-slate-900/30 p-1.5 rounded border border-slate-100 dark:border-slate-800/60">
                                <span className="font-semibold">Identificação:</span> {aq.outorga_identificacao}
                              </div>
                            )}
                          </div>

                          {/* Descarte */}
                          <div className="bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40 space-y-1">
                            <span className="text-muted-foreground block font-medium">Descarte de Resíduos</span>
                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100 block">
                              {aq.descarte_residuos === 'COMPOSTEIRA' ? 'Composteira' : 'Outro'}
                            </span>
                            {aq.descarte_residuos === 'OUTRO' && aq.descarte_residuos_outro && (
                              <div className="mt-1 text-[11px] text-slate-600 dark:text-slate-400 bg-slate-50/50 dark:bg-slate-900/30 p-1.5 rounded border border-slate-100 dark:border-slate-800/60">
                                <span className="font-semibold">Destinação descrita:</span> {aq.descarte_residuos_outro}
                              </div>
                            )}
                          </div>
                        </div>

                        {/* Fonte de Água (Legacy) */}
                        {aq.fonte_agua && (
                          <div className="border-t pt-3 text-xs bg-white dark:bg-slate-950 p-3 rounded border border-slate-150/40 dark:border-slate-800/40 space-y-1 mt-2">
                            <span className="text-muted-foreground block font-medium">Fonte de Abastecimento de Água (Legado)</span>
                            <p className="text-[11px] text-slate-700 dark:text-slate-300 leading-relaxed font-semibold">
                              {aq.fonte_agua}
                            </p>
                          </div>
                        )}
                      </div>

                      {/* 4. Diagnóstico DIFI */}
                      <div className="bg-rose-50/10 dark:bg-rose-950/5 p-4 rounded-lg border border-rose-100/40 dark:border-rose-950/10 space-y-3">
                        <div className="text-xs font-bold uppercase tracking-wider text-rose-600 dark:text-rose-400 flex items-center gap-2">
                          <ClipboardCheck className="w-4 h-4" />
                          <span>4. Diagnóstico Administrativo e Fiscalização (DIFI)</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                          <div>
                            <span className="text-muted-foreground block font-semibold mb-1">Constatação de Infração</span>
                            <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-bold ${aq.infracao_constatada ? 'bg-red-100 text-red-800' : 'bg-slate-100 text-slate-800'}`}>
                              {aq.infracao_constatada ? 'Sim, Houve infração' : 'Não'}
                            </span>
                          </div>
                          <div>
                            <span className="text-muted-foreground block font-semibold mb-1">Medidas Sugeridas</span>
                            <span className="font-bold text-blue-600 dark:text-blue-400">{aq.medida_sugerida || 'Nenhuma medida sugerida.'}</span>
                          </div>
                        </div>
                      </div>

                      {/* 5. Parecer Técnico */}
                      {aq.observacoes && (
                        <div className="bg-slate-50/50 dark:bg-slate-900/30 p-4 rounded-lg border border-slate-100 dark:border-slate-900 space-y-2">
                          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 block">Parecer Técnico / Informações Complementares</span>
                          <p className="bg-white dark:bg-slate-900 p-3 rounded border border-slate-200 text-slate-700 dark:text-slate-350 leading-relaxed text-xs">
                            {aq.observacoes}
                          </p>
                        </div>
                      )}
                    </div>
                  );
                })()}

                {/* SUCROALCOOLEIRO UI */}
                {selectedVistoria.data.sucroalcooleiro && (
                  <div className="space-y-4 bg-purple-50/30 dark:bg-purple-950/10 p-4 rounded-lg border border-purple-100 dark:border-purple-950/30">
                    <div className="grid grid-cols-2 gap-4 text-xs">
                      <div className="flex items-center gap-2">
                        {selectedVistoria.data.sucroalcooleiro.equipamentos_conformes ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                        <span className="font-bold text-slate-800 dark:text-slate-200">Equipamentos Conformes</span>
                      </div>
                      <div className="flex items-center gap-2">
                        {selectedVistoria.data.sucroalcooleiro.armazenamento_ok ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                        <span className="font-bold text-slate-800 dark:text-slate-200">Armazenamento Correto</span>
                      </div>
                    </div>
                    {selectedVistoria.data.sucroalcooleiro.residuos_solidos && (
                      <div className="border-t pt-3 mt-3 text-xs">
                        <span className="text-muted-foreground block">Destinação de Resíduos Sólidos</span>
                        <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed">
                          {selectedVistoria.data.sucroalcooleiro.residuos_solidos}
                        </p>
                      </div>
                    )}
                    {selectedVistoria.data.sucroalcooleiro.bagaco && (
                      <div className="border-t pt-3 text-xs">
                        <span className="text-muted-foreground block">Disposição do Bagaço</span>
                        <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed">
                          {selectedVistoria.data.sucroalcooleiro.bagaco}
                        </p>
                      </div>
                    )}
                  </div>
                )}

                {/* AGRICULTURA UI */}
                {selectedVistoria.data.agricultura && (
                  <div className="space-y-4 bg-lime-50/30 dark:bg-lime-950/10 p-4 rounded-lg border border-lime-100 dark:border-lime-950/30">
                    <div className="grid grid-cols-1 gap-4 text-xs">
                      {selectedVistoria.data.agricultura.cultivo && (
                        <div>
                          <span className="text-muted-foreground block font-semibold mb-1">Tipos de Cultivo</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 leading-relaxed">
                            {selectedVistoria.data.agricultura.cultivo}
                          </p>
                        </div>
                      )}
                      {selectedVistoria.data.agricultura.cursos_hidricos_entorno && (
                        <div className="border-t pt-3">
                          <span className="text-muted-foreground block font-semibold mb-1">Cursos Hídricos no Entorno</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 leading-relaxed">
                            {selectedVistoria.data.agricultura.cursos_hidricos_entorno}
                          </p>
                        </div>
                      )}
                      {selectedVistoria.data.agricultura.agrotoxicos && (
                        <div className="border-t pt-3">
                          <span className="text-muted-foreground block font-semibold mb-1">Uso de Agrotóxicos</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 leading-relaxed">
                            {selectedVistoria.data.agricultura.agrotoxicos}
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                )}

                {/* FALLBACK GENERAL FORM INFO */}
                {!selectedVistoria.data.supressao && 
                 !selectedVistoria.data.avicultura && 
                 !selectedVistoria.data.suinocultura && 
                 !selectedVistoria.data.bovinocultura && 
                 !selectedVistoria.data.aquicultura && 
                 !selectedVistoria.data.sucroalcooleiro && 
                 !selectedVistoria.data.agricultura && (
                  <div className="bg-slate-50 dark:bg-slate-900 rounded-lg p-6 text-center border border-dashed text-slate-500 space-y-2">
                    <Maximize2 className="w-8 h-8 text-slate-400 mx-auto" />
                    <div>Não há ficha técnica específica para esta modalidade.</div>
                    <div className="text-[11px] text-muted-foreground">O formulário de campo registrou apenas as informações gerais da vistoria técnica.</div>
                  </div>
                )}

              </div>

            </div>

            <DialogFooter className="border-t border-slate-100 dark:border-slate-800 pt-4 mt-4 dialog-footer">
              <Button variant="outline" onClick={() => setIsOpen(false)}>
                Fechar Detalhes
              </Button>
              <Button className="gap-2 bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 hover:bg-slate-800 dark:hover:bg-slate-200" onClick={() => window.print()}>
                <Download className="w-4 h-4" />
                Exportar PDF / Imprimir
              </Button>
            </DialogFooter>
          </>
        )}
      </DialogContent>
    </Dialog>
  );
});

VistoriaDetailsDialog.displayName = 'VistoriaDetailsDialog';

export default VistoriaDetailsDialog;
