import React, { useEffect, useState } from 'react';
import api from '@/lib/api';
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
  LayoutDashboard
} from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';

interface VistoriaData {
  id: string;
  user: number; // Linked as 'user' in the database/API model
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
  const [vistorias, setVistorias] = useState<VistoriaData[]>([]);
  const [users, setUsers] = useState<UserData[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const [vistoriasRes, usersRes] = await Promise.all([
          api.get('/vistorias/'),
          api.get('/auth/users/')
        ]);
        setVistorias(vistoriasRes.data || []);
        setUsers(usersRes.data || []);
      } catch (err) {
        console.error('Failed to load dashboard data', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Stats calculations
  const activeTechniciansCount = users.filter(u => u.is_active).length;
  const syncedVistoriasCount = vistorias.length;

  // Unique municipios
  const uniqueMunicipiosCount = React.useMemo(() => {
    const set = new Set();
    vistorias.forEach(v => {
      if (v.data?.municipio) {
        set.add(v.data.municipio);
      }
    });
    return set.size;
  }, [vistorias]);

  // Unique devices
  const uniqueDevicesCount = React.useMemo(() => {
    const set = new Set();
    vistorias.forEach(v => {
      if (v.data?.dispositivo) {
        set.add(v.data.dispositivo);
      }
    });
    return set.size;
  }, [vistorias]);

  // Helper to determine the actual type of a vistoria (identical to Vistorias.tsx)
  const getVistoriaType = (v: VistoriaData) => {
    if (v.data?.tipo) return v.data.tipo;
    if ((v.data as any)?.supressao) return 'Supressão Vegetal';
    if ((v.data as any)?.avicultura) return 'Avicultura';
    if ((v.data as any)?.suinocultura) return 'Suinocultura';
    if ((v.data as any)?.bovinocultura) return 'Bovinocultura';
    if ((v.data as any)?.aquicultura) return 'Aquicultura';
    if ((v.data as any)?.sucroalcooleiro) return 'Sucroalcooleiro';
    if ((v.data as any)?.agricultura) return 'Agricultura';
    return 'Geral';
  };

  // Accurately count based on sub-key presence matching Vistorias.tsx
  const supressaoCount = vistorias.filter(v => getVistoriaType(v) === 'Supressão Vegetal').length;
  const aviculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Avicultura').length;
  const suinoculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Suinocultura').length;
  const bovinoculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Bovinocultura').length;
  const aquiculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Aquicultura').length;
  const sucroalcooleiroCount = vistorias.filter(v => getVistoriaType(v) === 'Sucroalcooleiro').length;
  const agriculturaCount = vistorias.filter(v => getVistoriaType(v) === 'Agricultura').length;

  const categories = [
    { name: 'Supressão Vegetal', count: supressaoCount, icon: Trees, color: 'bg-emerald-500', textColor: 'text-emerald-500' },
    { name: 'Avicultura', count: aviculturaCount, icon: Egg, color: 'bg-amber-500', textColor: 'text-amber-500' },
    { name: 'Suinocultura', count: suinoculturaCount, icon: Activity, color: 'bg-pink-500', textColor: 'text-pink-500' },
    { name: 'Bovinocultura', count: bovinoculturaCount, icon: Beef, color: 'bg-indigo-500', textColor: 'text-indigo-500' },
    { name: 'Aquicultura', count: aquiculturaCount, icon: Fish, color: 'bg-blue-500', textColor: 'text-blue-500' },
    { name: 'Sucroalcooleiro', count: sucroalcooleiroCount, icon: Factory, color: 'bg-purple-500', textColor: 'text-purple-500' },
    { name: 'Agricultura', count: agriculturaCount, icon: Sprout, color: 'bg-lime-500', textColor: 'text-lime-500' },
  ].sort((a, b) => b.count - a.count); // Sorted by most active for rich visuals

  // Sort and select last 5 synchronized vistorias
  const recentVistorias = React.useMemo(() => {
    return [...vistorias]
      .sort((a, b) => new Date(b.created_at || 0).getTime() - new Date(a.created_at || 0).getTime())
      .slice(0, 5);
  }, [vistorias]);

  const stats = [
    { title: 'Técnicos Ativos', value: loading ? null : activeTechniciansCount.toString(), icon: Users, description: 'Profissionais cadastrados', color: 'text-blue-500 border-l-4 border-l-blue-500' },
    { title: 'Vistorias Sincronizadas', value: loading ? null : syncedVistoriasCount.toString(), icon: ClipboardCheck, description: 'Registros salvos no banco', color: 'text-emerald-500 border-l-4 border-l-emerald-500' },
    { title: 'Municípios Atendidos', value: loading ? null : uniqueMunicipiosCount.toString(), icon: MapPin, description: 'Cidades da Paraíba', color: 'text-amber-500 border-l-4 border-l-amber-500' },
    { title: 'Dispositivos em Campo', value: loading ? null : uniqueDevicesCount.toString(), icon: Smartphone, description: 'Aparelhos ativos', color: 'text-purple-500 border-l-4 border-l-purple-500' },
  ];

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-500">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Bem-vindo de volta!</h2>
        <p className="text-muted-foreground">Aqui está um resumo em tempo real do sistema de vistorias técnicas (DIFLOR).</p>
      </div>

      {/* Stats Cards Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.title} className={`hover:shadow-md transition-shadow bg-white dark:bg-slate-950 ${stat.color}`}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">{stat.title}</CardTitle>
              <stat.icon className="h-5 w-5 text-slate-400" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-black">
                {stat.value === null ? <Skeleton className="h-9 w-20" /> : stat.value}
              </div>
              <p className="text-xs text-muted-foreground mt-1">
                {stat.description}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Main Sections Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        
        {/* Category distribution chart card */}
        <Card className="col-span-1 md:col-span-2 lg:col-span-4 hover:shadow-md transition-shadow bg-white dark:bg-slate-950">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <LayoutDashboard className="w-5 h-5 text-primary" />
              Volume por Categoria
            </CardTitle>
            <CardDescription>
              Distribuição proporcional das vistorias entre as 7 modalidades.
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
              <div className="space-y-3">
                {categories.map((cat) => {
                  const percentage = vistorias.length > 0 ? (cat.count / vistorias.length) * 100 : 0;
                  return (
                    <div key={cat.name} className="space-y-1">
                      <div className="flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <cat.icon className={`w-4 h-4 ${cat.textColor}`} />
                          <span className="font-semibold text-slate-700 dark:text-slate-300">{cat.name}</span>
                        </div>
                        <span className="text-muted-foreground font-bold">{cat.count} ({percentage.toFixed(0)}%)</span>
                      </div>
                      <div className="h-2 w-full bg-slate-100 dark:bg-slate-900 rounded-full overflow-hidden">
                        <div 
                          className={`h-full ${cat.color} transition-all duration-500 rounded-full`}
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
        <Card className="col-span-1 md:col-span-2 lg:col-span-3 hover:shadow-md transition-shadow bg-white dark:bg-slate-950">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-emerald-500" />
              Atividades Recentes
            </CardTitle>
            <CardDescription>
              Últimas vistorias sincronizadas pelos técnicos em campo.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="space-y-3">
                {Array.from({ length: 3 }).map((_, i) => (
                  <Skeleton key={i} className="h-16 w-full" />
                ))}
              </div>
            ) : recentVistorias.length === 0 ? (
              <div className="h-[250px] flex flex-col items-center justify-center border-2 border-dashed rounded-lg bg-slate-50/50 dark:bg-slate-900/50">
                <p className="text-sm text-muted-foreground">Nenhuma vistoria sincronizada ainda.</p>
              </div>
            ) : (
              <div className="space-y-3 max-h-[350px] overflow-auto">
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
                    <div key={v.id} className="flex items-center justify-between gap-4 p-3 rounded-lg border border-slate-100 dark:border-slate-900 bg-slate-50/30 dark:bg-slate-950/30 hover:bg-slate-50/80 dark:hover:bg-slate-900/50 transition-colors">
                      <div className="flex items-center gap-3 overflow-hidden">
                        <div className="bg-emerald-100 dark:bg-emerald-950/40 rounded-full p-2 text-emerald-600 shrink-0">
                          <ClipboardCheck className="w-4 h-4" />
                        </div>
                        <div className="flex flex-col overflow-hidden">
                          <span className="text-sm font-semibold truncate text-slate-800 dark:text-slate-100">{v.data?.requerente || 'Sem Requerente'}</span>
                          <span className="text-xs text-muted-foreground truncate">{type} • Processo: {v.data?.processo_n || '-'}</span>
                        </div>
                      </div>
                      <div className="flex flex-col items-end shrink-0">
                        <span className="text-xs font-semibold text-slate-700 dark:text-slate-300">Téc: {technician}</span>
                        <span className="text-[10px] text-muted-foreground flex items-center gap-0.5 mt-0.5">
                          <Smartphone className="w-3 h-3 text-slate-400" />
                          {v.data?.dispositivo || 'Não informado'}
                        </span>
                        <span className="text-[10px] text-muted-foreground mt-0.5">{dateStr}</span>
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
