import React, { useMemo } from 'react';
import { 
  Card, 
  CardDescription, 
  CardTitle 
} from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { 
  ClipboardCheck, 
  Trees, 
  Egg, 
  Activity, 
  Beef, 
  Fish, 
  Factory, 
  Sprout 
} from 'lucide-react';
import { type VistoriaData, getVistoriaType } from './types';

interface VistoriaMetricsProps {
  vistorias: VistoriaData[];
  loading: boolean;
}

const VistoriaMetrics: React.FC<VistoriaMetricsProps> = React.memo(({ vistorias, loading }) => {
  const stats = useMemo(() => {
    const total = vistorias.length;
    let supressao = 0;
    let avicultura = 0;
    let suinocultura = 0;
    let bovinocultura = 0;
    let aquicultura = 0;
    let sucroalcooleiro = 0;
    let agricultura = 0;

    vistorias.forEach(v => {
      const type = getVistoriaType(v).toLowerCase();
      if (type.includes('supressão') || type.includes('supressao')) supressao++;
      else if (type.includes('avicultura')) avicultura++;
      else if (type.includes('suinocultura')) suinocultura++;
      else if (type.includes('bovinocultura')) bovinocultura++;
      else if (type.includes('aquicultura')) aquicultura++;
      else if (type.includes('sucroalcooleiro') || type.includes('agroindustriais') || type.includes('agroindustrial')) sucroalcooleiro++;
      else if (type.includes('agricultura')) agricultura++;
    });

    return {
      total,
      supressao,
      avicultura,
      suinocultura,
      bovinocultura,
      aquicultura,
      sucroalcooleiro,
      agricultura
    };
  }, [vistorias]);

  return (
    <div className="grid gap-3 grid-cols-2 sm:grid-cols-4 lg:grid-cols-8">
      {/* Card: Total Geral */}
      <Card className="relative overflow-hidden transition-all hover:shadow-md p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
        <div>
          <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-slate-500">Total</CardDescription>
          <CardTitle className="text-xl font-black mt-1 text-slate-800 dark:text-slate-100">
            {loading ? <Skeleton className="h-7 w-12" /> : stats.total}
          </CardTitle>
        </div>
        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
          <span className="text-[10px] text-muted-foreground">Vistorias</span>
          <ClipboardCheck className="w-4 h-4 text-slate-400 stroke-[2]" />
        </div>
      </Card>

      {/* Card: Supressão Vegetal */}
      <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-emerald-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
        <div>
          <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-emerald-600 dark:text-emerald-400">Supressão</CardDescription>
          <CardTitle className="text-xl font-black text-emerald-700 dark:text-emerald-400 mt-1">
            {loading ? <Skeleton className="h-7 w-12" /> : stats.supressao}
          </CardTitle>
        </div>
        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
          <span className="text-[10px] text-muted-foreground">Florestal</span>
          <Trees className="w-4 h-4 text-emerald-500 stroke-[2]" />
        </div>
      </Card>

      {/* Card: Avicultura */}
      <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-amber-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
        <div>
          <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-amber-600 dark:text-amber-400">Avicultura</CardDescription>
          <CardTitle className="text-xl font-black text-amber-700 dark:text-amber-400 mt-1">
            {loading ? <Skeleton className="h-7 w-12" /> : stats.avicultura}
          </CardTitle>
        </div>
        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
          <span className="text-[10px] text-muted-foreground">Aves</span>
          <Egg className="w-4 h-4 text-amber-500 stroke-[2]" />
        </div>
      </Card>

      {/* Card: Suinocultura */}
      <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-pink-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
        <div>
          <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-pink-600 dark:text-pink-400">Suíno</CardDescription>
          <CardTitle className="text-xl font-black text-pink-700 dark:text-pink-400 mt-1">
            {loading ? <Skeleton className="h-7 w-12" /> : stats.suinocultura}
          </CardTitle>
        </div>
        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
          <span className="text-[10px] text-muted-foreground">Suínos</span>
          <Activity className="w-4 h-4 text-pink-500 stroke-[2]" />
        </div>
      </Card>

      {/* Card: Bovinocultura */}
      <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-indigo-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
        <div>
          <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-indigo-600 dark:text-indigo-400">Bovino</CardDescription>
          <CardTitle className="text-xl font-black text-indigo-700 dark:text-indigo-400 mt-1">
            {loading ? <Skeleton className="h-7 w-12" /> : stats.bovinocultura}
          </CardTitle>
        </div>
        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
          <span className="text-[10px] text-muted-foreground">Gado</span>
          <Beef className="w-4 h-4 text-indigo-500 stroke-[2]" />
        </div>
      </Card>

      {/* Card: Aquicultura */}
      <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-blue-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
        <div>
          <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-blue-600 dark:text-blue-400">Aquicultura</CardDescription>
          <CardTitle className="text-xl font-black text-blue-700 dark:text-blue-400 mt-1">
            {loading ? <Skeleton className="h-7 w-12" /> : stats.aquicultura}
          </CardTitle>
        </div>
        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
          <span className="text-[10px] text-muted-foreground">Peixes</span>
          <Fish className="w-4 h-4 text-blue-500 stroke-[2]" />
        </div>
      </Card>

      {/* Card: Atividades Agroindustriais */}
      <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-purple-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
        <div>
          <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-purple-600 dark:text-purple-400">Agroindústria</CardDescription>
          <CardTitle className="text-xl font-black text-purple-700 dark:text-purple-400 mt-1">
            {loading ? <Skeleton className="h-7 w-12" /> : stats.sucroalcooleiro}
          </CardTitle>
        </div>
        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
          <span className="text-[10px] text-muted-foreground">Agroindústrias</span>
          <Factory className="w-4 h-4 text-purple-500 stroke-[2]" />
        </div>
      </Card>

      {/* Card: Agricultura */}
      <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-lime-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
        <div>
          <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-lime-600 dark:text-lime-400">Lavoura</CardDescription>
          <CardTitle className="text-xl font-black text-lime-700 dark:text-lime-400 mt-1">
            {loading ? <Skeleton className="h-7 w-12" /> : stats.agricultura}
          </CardTitle>
        </div>
        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
          <span className="text-[10px] text-muted-foreground">Cultivo</span>
          <Sprout className="w-4 h-4 text-lime-500 stroke-[2]" />
        </div>
      </Card>
    </div>
  );
});

VistoriaMetrics.displayName = 'VistoriaMetrics';

export default VistoriaMetrics;
