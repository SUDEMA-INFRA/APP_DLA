import React, { useEffect, useState, useMemo } from 'react';
import api from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { 
  Users, 
  MapPin, 
  Smartphone, 
  Trees, 
  Egg, 
  Activity, 
  Beef, 
  Fish, 
  Factory, 
  Sprout, 
  ClipboardCheck,
  TrendingUp,
  LayoutDashboard,
  ShieldAlert,
  Clock
} from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';

interface VistoriaData {
  id: string;
  user: number;
  data: {
    processo_n?: string;
    requerente?: string;
    latitude?: string;
    longitude?: string;
    tipo?: string;
    status?: string;
    municipio?: number | string;
    dispositivo?: string;
  };
  created_at?: string;
}

interface UserData {
  id: number;
  username: string;
  email: string;
  is_active: boolean;
  is_staff: boolean;
  first_name?: string;
  last_name?: string;
}

const Dashboard: React.FC = () => {
  const { user: currentUser } = useAuth();
  const [vistorias, setVistorias] = useState<VistoriaData[]>([]);
  const [users, setUsers] = useState<UserData[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        if (currentUser?.is_staff) {
          const [vistoriasRes, usersRes] = await Promise.all([
            api.get('/vistorias/'),
            api.get('/auth/users/')
          ]);
          setVistorias(vistoriasRes.data || []);
          setUsers(usersRes.data || []);
        } else {
          const vistoriasRes = await api.get('/vistorias/');
          setVistorias(vistoriasRes.data || []);
          if (currentUser) {
            setUsers([{
              id: currentUser.id,
              username: currentUser.username,
              email: currentUser.email || '',
              is_active: true,
              is_staff: false,
              first_name: currentUser.first_name || '',
              last_name: currentUser.last_name || ''
            }]);
          }
        }
      } catch (err) {
        console.error('Failed to load dashboard data', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [currentUser]);

  // Dynamic greeting based on hour
  const timeGreeting = useMemo(() => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }, []);

  const activeTechniciansCount = users.filter(u => u.is_active).length;
  const syncedVistoriasCount = vistorias.length;

  const uniqueMunicipiosCount = useMemo(() => {
    const set = new Set();
    vistorias.forEach(v => {
      if (v.data?.municipio) {
        set.add(v.data.municipio);
      }
    });
    return set.size;
  }, [vistorias]);

  const uniqueDevicesCount = useMemo(() => {
    const set = new Set();
    vistorias.forEach(v => {
      if (v.data?.dispositivo) {
        set.add(v.data.dispositivo);
      }
    });
    return set.size;
  }, [vistorias]);

  const getVistoriaType = (v: VistoriaData) => {
    if (v.data?.tipo) {
      if (v.data.tipo === 'Sucroalcooleiro' || v.data.tipo === 'Agroindustrial') return 'Atividades Agroindustriais';
      return v.data.tipo;
    }
    if ((v.data as any)?.supressao) return 'Supressão Vegetal';
    if ((v.data as any)?.avicultura) return 'Avicultura';
    if ((v.data as any)?.suinocultura) return 'Suinocultura';
    if ((v.data as any)?.bovinocultura) return 'Bovinocultura';
    if ((v.data as any)?.aquicultura) return 'Aquicultura';
    if ((v.data as any)?.agroindustrial || (v.data as any)?.sucroalcooleiro) return 'Atividades Agroindustriais';
    if ((v.data as any)?.agricultura) return 'Agricultura';
    return 'Geral';
  };

  const supressaoCount = vistorias.filter(v => getVistoriaType(v) === 'Supressão Vegetal').length;
  const aviculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Avicultura').length;
  const suinoculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Suinocultura').length;
  const bovinoculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Bovinocultura').length;
  const aquiculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Aquicultura').length;
  const agroindustrialCount = vistorias.filter(v => getVistoriaType(v) === 'Atividades Agroindustriais').length;
  const agriculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Agricultura').length;

  const categories = useMemo(() => {
    return [
      { name: 'Supressão Vegetal', count: supressaoCount, icon: Trees, color: 'bg-emerald-500 dark:bg-emerald-400', textColor: 'text-emerald-500 dark:text-emerald-400', glow: 'shadow-emerald-500/10 dark:shadow-emerald-400/5' },
      { name: 'Avicultura', count: aviculturaCount, icon: Egg, color: 'bg-amber-500 dark:bg-amber-400', textColor: 'text-amber-500 dark:text-amber-400', glow: 'shadow-amber-500/10 dark:shadow-amber-400/5' },
      { name: 'Suinocultura', count: suinoculturaCount, icon: Activity, color: 'bg-pink-500 dark:bg-pink-400', textColor: 'text-pink-500 dark:text-pink-400', glow: 'shadow-pink-500/10 dark:shadow-pink-400/5' },
      { name: 'Bovinocultura', count: bovinoculturaCount, icon: Beef, color: 'bg-indigo-500 dark:bg-indigo-400', textColor: 'text-indigo-500 dark:text-indigo-400', glow: 'shadow-indigo-500/10 dark:shadow-indigo-400/5' },
      { name: 'Aquicultura', count: aquiculturaCount, icon: Fish, color: 'bg-blue-500 dark:bg-blue-400', textColor: 'text-blue-500 dark:text-blue-400', glow: 'shadow-blue-500/10 dark:shadow-blue-400/5' },
      { name: 'Atividades Agroindustriais', count: agroindustrialCount, icon: Factory, color: 'bg-purple-500 dark:bg-purple-400', textColor: 'text-purple-500 dark:text-purple-400', glow: 'shadow-purple-500/10 dark:shadow-purple-400/5' },
      { name: 'Agricultura', count: agriculturaCount, icon: Sprout, color: 'bg-lime-500 dark:bg-lime-400', textColor: 'text-lime-500 dark:text-lime-400', glow: 'shadow-lime-500/10 dark:shadow-lime-400/5' },
    ].sort((a, b) => b.count - a.count);
  }, [supressaoCount, aviculturaCount, suinoculturaCount, bovinoculturaCount, aquiculturaCount, agroindustrialCount, agriculturaCount]);

  const recentVistorias = useMemo(() => {
    return [...vistorias]
      .sort((a, b) => new Date(b.created_at || 0).getTime() - new Date(a.created_at || 0).getTime())
      .slice(0, 5);
  }, [vistorias]);

  const lastSyncDate = useMemo(() => {
    if (vistorias.length === 0) return 'Nenhuma ainda';
    const sorted = [...vistorias].sort((a, b) => new Date(b.created_at || 0).getTime() - new Date(a.created_at || 0).getTime());
    const latest = sorted[0];
    if (!latest?.created_at) return 'Nenhuma ainda';
    return new Date(latest.created_at).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  }, [vistorias]);

  const favoriteCategory = useMemo(() => {
    if (vistorias.length === 0) return 'Nenhuma';
    const counts: Record<string, number> = {};
    vistorias.forEach(v => {
      const type = getVistoriaType(v);
      counts[type] = (counts[type] || 0) + 1;
    });
    const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1]);
    return sorted[0]?.[0] || 'Nenhuma';
  }, [vistorias]);

  const stats = useMemo(() => {
    return currentUser?.is_staff ? [
      { title: 'Técnicos Ativos', value: loading ? null : activeTechniciansCount.toString(), icon: Users, description: 'Profissionais cadastrados', style: 'border-t-4 border-t-blue-500 dark:border-t-blue-400 shadow-sm hover:shadow-blue-500/10 hover:-translate-y-0.5' },
      { title: 'Total de Vistorias', value: loading ? null : syncedVistoriasCount.toString(), icon: ClipboardCheck, description: 'Registros salvos no banco', style: 'border-t-4 border-t-emerald-500 dark:border-t-emerald-400 shadow-sm hover:shadow-emerald-500/10 hover:-translate-y-0.5' },
      { title: 'Municípios Atendidos', value: loading ? null : uniqueMunicipiosCount.toString(), icon: MapPin, description: 'Cidades da Paraíba', style: 'border-t-4 border-t-amber-500 dark:border-t-amber-400 shadow-sm hover:shadow-amber-500/10 hover:-translate-y-0.5' },
      { title: 'Dispositivos em Campo', value: loading ? null : uniqueDevicesCount.toString(), icon: Smartphone, description: 'Aparelhos ativos', style: 'border-t-4 border-t-purple-500 dark:border-t-purple-400 shadow-sm hover:shadow-purple-500/10 hover:-translate-y-0.5' },
    ] : [
      { title: 'Minhas Vistorias', value: loading ? null : syncedVistoriasCount.toString(), icon: ClipboardCheck, description: 'Sincronizadas por você', style: 'border-t-4 border-t-emerald-500 dark:border-t-emerald-400 shadow-sm hover:shadow-emerald-500/10 hover:-translate-y-0.5' },
      { title: 'Municípios Atendidos', value: loading ? null : uniqueMunicipiosCount.toString(), icon: MapPin, description: 'Cidades visitadas', style: 'border-t-4 border-t-amber-500 dark:border-t-amber-400 shadow-sm hover:shadow-amber-500/10 hover:-translate-y-0.5' },
      { title: 'Última Sincronização', value: loading ? null : lastSyncDate, icon: Smartphone, description: 'Data do último envio', style: 'border-t-4 border-t-purple-500 dark:border-t-purple-400 shadow-sm hover:shadow-purple-500/10 hover:-translate-y-0.5' },
      { title: 'Sua Maior Demanda', value: loading ? null : favoriteCategory, icon: Sprout, description: 'Categoria mais visitada', style: 'border-t-4 border-t-blue-500 dark:border-t-blue-400 shadow-sm hover:shadow-blue-500/10 hover:-translate-y-0.5' },
    ];
  }, [currentUser, loading, activeTechniciansCount, syncedVistoriasCount, uniqueMunicipiosCount, uniqueDevicesCount, lastSyncDate, favoriteCategory]);

  return (
    <div className="relative space-y-8 animate-in fade-in slide-in-from-bottom-2 duration-500">
      {/* Soft Ambient Light Orbs for Depth */}
      <div className="absolute inset-0 -z-10 overflow-hidden pointer-events-none">
        <div className="absolute top-[-5%] left-[5%] w-80 h-80 bg-emerald-500/5 rounded-full blur-3xl" />
        <div className="absolute top-[20%] right-[10%] w-96 h-96 bg-amber-500/5 rounded-full blur-3xl" />
      </div>

      {/* Modern Greeting Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 p-6 bg-white/70 dark:bg-slate-900/40 border border-slate-100 dark:border-slate-800/80 backdrop-blur-md rounded-2xl shadow-sm">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <h2 className="text-3xl font-black tracking-tight text-slate-800 dark:text-slate-100">
              {timeGreeting}, <span className="bg-gradient-to-r from-emerald-600 to-teal-500 bg-clip-text text-transparent">{currentUser?.first_name || currentUser?.username}</span>!
            </h2>
            <div className="animate-bounce mt-1">👋</div>
          </div>
          <p className="text-muted-foreground text-sm font-medium">
            Aqui está um resumo em tempo real do sistema de vistorias técnicas (DIFLOR).
          </p>
        </div>
        <div className="flex items-center gap-2 shrink-0 bg-slate-50 dark:bg-slate-900 px-4 py-2 rounded-xl border border-slate-200/45 dark:border-slate-800">
          <Clock className="w-4 h-4 text-emerald-500" />
          <span className="text-xs font-bold text-slate-600 dark:text-slate-400">
            {currentUser?.is_staff ? "Modo Administrador" : "Modo Técnico de Campo"}
          </span>
        </div>
      </div>

      {/* Glassmorphic Stats Cards Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.title} className={`group relative overflow-hidden transition-all duration-300 bg-white/60 dark:bg-slate-950/60 backdrop-blur-sm ${stat.style}`}>
            {/* Thematic Floating background icon */}
            <div className="absolute right-[-10px] bottom-[-10px] opacity-[0.03] dark:opacity-[0.05] group-hover:opacity-[0.08] group-hover:scale-110 transition-all duration-500 pointer-events-none">
              <stat.icon className="w-32 h-32 text-slate-500" />
            </div>
            
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-[11px] uppercase tracking-wider font-extrabold text-slate-400 dark:text-slate-500">{stat.title}</CardTitle>
              <div className="p-1.5 bg-slate-50 dark:bg-slate-900 rounded-lg group-hover:bg-slate-100 dark:group-hover:bg-slate-800 transition-colors">
                <stat.icon className="h-4 w-4 text-slate-500" />
              </div>
            </CardHeader>
            <CardContent className="space-y-1">
              <div className="text-3xl font-black text-slate-800 dark:text-slate-100">
                {stat.value === null ? <Skeleton className="h-9 w-20" /> : stat.value}
              </div>
              <p className="text-xs font-medium text-slate-450 dark:text-slate-400">
                {stat.description}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Main Sections Grid */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
        
        {/* Category distribution chart card */}
        <Card className="col-span-1 md:col-span-2 lg:col-span-4 hover:shadow-md transition-shadow bg-white/70 dark:bg-slate-950/70 border-slate-150/60 dark:border-slate-850/60 backdrop-blur-sm rounded-2xl">
          <CardHeader className="pb-4">
            <CardTitle className="flex items-center gap-2.5 text-lg font-bold text-slate-850 dark:text-slate-100">
              <LayoutDashboard className="w-5 h-5 text-emerald-500" />
              Volume por Categoria
            </CardTitle>
            <CardDescription className="text-xs font-medium text-slate-400">
              Distribuição proporcional das vistorias entre as 7 modalidades técnicas.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {loading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="space-y-2">
                  <Skeleton className="h-4 w-1/3" />
                  <Skeleton className="h-2 w-full" />
                </div>
              ))
            ) : (
              <div className="space-y-3.5">
                {categories.map((cat) => {
                  const percentage = vistorias.length > 0 ? (cat.count / vistorias.length) * 100 : 0;
                  return (
                    <div key={cat.name} className="group/item space-y-1.5 transition-all">
                      <div className="flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <div className={`p-1 bg-slate-50 dark:bg-slate-900 rounded-md group-hover/item:scale-105 transition-transform`}>
                            <cat.icon className={`w-3.5 h-3.5 ${cat.textColor}`} />
                          </div>
                          <span className="font-bold text-slate-700 dark:text-slate-350">{cat.name}</span>
                        </div>
                        <span className="font-extrabold text-slate-650 dark:text-slate-300">
                          {cat.count} <span className="text-[10px] text-muted-foreground font-semibold">({percentage.toFixed(0)}%)</span>
                        </span>
                      </div>
                      <div className="h-2.5 w-full bg-slate-50 dark:bg-slate-900/60 rounded-full overflow-hidden border border-slate-100/50 dark:border-slate-850/40">
                        <div 
                          className={`h-full ${cat.color} ${cat.glow} shadow-[0_0_8px_rgba(16,185,129,0)] group-hover/item:shadow-[0_0_10px_rgba(16,185,129,0.15)] transition-all duration-700 rounded-full`}
                          style={{ width: `${percentage}%` }}
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </CardContent>
        </Card>
        
        {/* Recent synchronized inspections card */}
        <Card className="col-span-1 md:col-span-2 lg:col-span-3 hover:shadow-md transition-shadow bg-white/70 dark:bg-slate-950/70 border-slate-150/60 dark:border-slate-850/60 backdrop-blur-sm rounded-2xl">
          <CardHeader className="pb-4">
            <CardTitle className="flex items-center gap-2.5 text-lg font-bold text-slate-850 dark:text-slate-100">
              <TrendingUp className="w-5 h-5 text-emerald-500 animate-pulse" />
              Atividades Recentes
            </CardTitle>
            <CardDescription className="text-xs font-medium text-slate-400">
              {currentUser?.is_staff 
                ? "Últimas vistorias sincronizadas pelos técnicos em campo."
                : "Suas últimas vistorias sincronizadas no servidor."}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="space-y-3">
                {Array.from({ length: 3 }).map((_, i) => (
                  <Skeleton key={i} className="h-16 w-full rounded-xl" />
                ))}
              </div>
            ) : recentVistorias.length === 0 ? (
              <div className="h-[250px] flex flex-col items-center justify-center border border-dashed rounded-2xl bg-slate-50/50 dark:bg-slate-900/50">
                <ShieldAlert className="w-8 h-8 text-slate-300 mb-2" />
                <p className="text-xs text-muted-foreground font-semibold">Nenhuma vistoria sincronizada ainda.</p>
              </div>
            ) : (
              <div className="space-y-3 max-h-[360px] overflow-y-auto pr-1">
                {recentVistorias.map((v) => {
                  const dateStr = v.created_at ? new Date(v.created_at).toLocaleDateString('pt-BR', {
                    day: '2-digit',
                    month: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                  }) : '-';
                  const userObj = users.find(u => u.id === v.user);
                  const technician = userObj 
                    ? `${userObj.first_name || ''} ${userObj.last_name || ''}`.trim() || userObj.username
                    : `ID: ${v.user}`;
                  const type = getVistoriaType(v);

                  return (
                    <div key={v.id} className="group/item flex items-center justify-between gap-3 p-3.5 rounded-xl border border-slate-100/80 dark:border-slate-900/80 bg-slate-50/20 dark:bg-slate-950/20 hover:bg-slate-100/40 dark:hover:bg-slate-900/40 hover:border-slate-200/50 transition-all duration-350">
                      <div className="flex items-center gap-3 overflow-hidden">
                        <div className="bg-emerald-50 dark:bg-emerald-950/40 rounded-xl p-2 text-emerald-600 dark:text-emerald-400 border border-emerald-100/20 shrink-0">
                          <ClipboardCheck className="w-4 h-4" />
                        </div>
                        <div className="flex flex-col overflow-hidden">
                          <span className="text-xs font-black truncate text-slate-800 dark:text-slate-100 group-hover/item:text-emerald-600 dark:group-hover/item:text-emerald-400 transition-colors">
                            {v.data?.requerente || 'Sem Requerente'}
                          </span>
                          <span className="text-[10px] text-muted-foreground truncate font-semibold">
                            {type} • Processo: {v.data?.processo_n || '-'}
                          </span>
                        </div>
                      </div>
                      <div className="flex flex-col items-end shrink-0 text-[10px] font-semibold text-slate-650 dark:text-slate-400">
                        <span className="font-bold text-slate-700 dark:text-slate-350">Téc: {technician}</span>
                        <span className="flex items-center gap-0.5 mt-0.5 text-muted-foreground text-[9px]">
                          <Smartphone className="w-2.5 h-2.5" />
                          {v.data?.dispositivo || 'N/I'}
                        </span>
                        <span className="text-muted-foreground text-[9px] mt-0.5">{dateStr}</span>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default Dashboard;
