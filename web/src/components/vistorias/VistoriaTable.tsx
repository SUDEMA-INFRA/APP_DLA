import React from 'react';
import { 
  Table, 
  TableHeader, 
  TableBody, 
  TableRow, 
  TableHead, 
  TableCell 
} from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { 
  Smartphone, 
  User as UserIcon, 
  MapPin, 
  XCircle, 
  CheckCircle2, 
  Calendar, 
  Eye, 
  Trees, 
  Egg 
} from 'lucide-react';
import { type VistoriaData, type UserData, getVistoriaType, formatDate } from './types';

interface VistoriaTableProps {
  filteredVistorias: VistoriaData[];
  users: UserData[];
  loading: boolean;
  handleOpenDetails: (vistoria: VistoriaData) => void;
  handleOpenEdit: (vistoria: VistoriaData) => void;
}

const VistoriaTable: React.FC<VistoriaTableProps> = React.memo(({
  filteredVistorias,
  users,
  loading,
  handleOpenDetails,
  handleOpenEdit
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
    <div className="rounded-md border border-slate-200 dark:border-slate-800 overflow-x-auto w-full">
      <Table>
        <TableHeader className="bg-slate-50 dark:bg-slate-900">
          <TableRow>
            <TableHead className="w-[150px]">Dispositivo</TableHead>
            <TableHead>Processo / Requerente</TableHead>
            <TableHead>Técnico</TableHead>
            <TableHead>Tipo de Vistoria</TableHead>
            <TableHead>Município</TableHead>
            <TableHead>Coordenadas</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Criado Em</TableHead>
            <TableHead className="text-right">Ações</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {loading ? (
            Array.from({ length: 5 }).map((_, i) => (
              <TableRow key={i}>
                <TableCell><Skeleton className="h-4 w-20" /></TableCell>
                <TableCell>
                  <div className="space-y-1">
                    <Skeleton className="h-4 w-32" />
                    <Skeleton className="h-3 w-48" />
                  </div>
                </TableCell>
                <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                <TableCell><Skeleton className="h-5 w-28 rounded-full" /></TableCell>
                <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                <TableCell><Skeleton className="h-4 w-36" /></TableCell>
                <TableCell><Skeleton className="h-4 w-16" /></TableCell>
                <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                <TableCell className="text-right"><Skeleton className="h-8 w-8 ml-auto rounded-full" /></TableCell>
              </TableRow>
            ))
          ) : filteredVistorias.length > 0 ? (
            filteredVistorias.map((v) => {
              const type = getVistoriaType(v);
              const isDraft = (v.data.status || '').toLowerCase() === 'rascunho';
              return (
                <TableRow key={v.local_id} className="hover:bg-slate-50/50 dark:hover:bg-slate-900/50 transition-colors">
                  <TableCell>
                    <div className="flex items-center gap-1.5 text-xs text-slate-600 dark:text-slate-300 font-medium">
                      <Smartphone className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                      <span>{v.data.dispositivo || 'Não informado'}</span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex flex-col">
                      <span className="font-bold text-sm text-slate-900 dark:text-slate-100">
                        {v.data.processo_n || 'N/A'}
                      </span>
                      <span className="text-xs text-muted-foreground truncate max-w-[200px]">
                        {v.data.requerente || 'Não informado'}
                      </span>
                    </div>
                  </TableCell>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 rounded-full bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                        <UserIcon className="w-3.5 h-3.5 text-slate-500" />
                      </div>
                      <span className="text-xs">{getUserName(v.user)}</span>
                    </div>
                  </TableCell>
                  <TableCell>{getTypeBadge(type)}</TableCell>
                  <TableCell>
                    <span className="text-xs font-semibold text-slate-700 dark:text-slate-300">
                      {v.data.municipio_nome || v.data.municipio || '-'}
                    </span>
                  </TableCell>
                  <TableCell>
                    {v.data.latitude && v.data.longitude ? (
                      <div className="flex items-center gap-1 font-mono text-[11px] text-slate-500">
                        <MapPin className="w-3.5 h-3.5 text-red-500 shrink-0" />
                        <span>{v.data.latitude.toFixed(4)}, {v.data.longitude.toFixed(4)}</span>
                      </div>
                    ) : (
                      <span className="text-xs text-muted-foreground">-</span>
                    )}
                  </TableCell>
                  <TableCell>
                    {isDraft ? (
                      <span className="inline-flex items-center gap-1 text-amber-600 text-xs">
                        <XCircle className="w-3.5 h-3.5" />
                        Rascunho
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1 text-emerald-600 text-xs">
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        Sincronizado
                      </span>
                    )}
                  </TableCell>
                  <TableCell className="text-xs text-slate-500">
                    <div className="flex items-center gap-1">
                      <Calendar className="w-3.5 h-3.5 text-slate-400" />
                      <span>{formatDate(v.created_at)}</span>
                    </div>
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-1">
                      <Button 
                        variant="ghost" 
                        size="icon" 
                        className="h-8 w-8 hover:bg-slate-200 dark:hover:bg-slate-800"
                        onClick={() => handleOpenDetails(v)}
                        title="Visualizar"
                      >
                        <Eye className="h-4 w-4 text-slate-600 dark:text-slate-400" />
                      </Button>
                      <Button 
                        variant="ghost" 
                        size="icon" 
                        className="h-8 w-8 hover:bg-slate-200 dark:hover:bg-slate-800"
                        onClick={() => handleOpenEdit(v)}
                        title="Editar"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="h-4 w-4 text-slate-600 dark:text-slate-400"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              );
            })
          ) : (
            <TableRow>
              <TableCell colSpan={9} className="h-24 text-center text-muted-foreground">
                Nenhuma vistoria encontrada com os filtros aplicados.
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
});

VistoriaTable.displayName = 'VistoriaTable';

export default VistoriaTable;
