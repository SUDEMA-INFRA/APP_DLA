import React, { useEffect, useState, useMemo } from 'react';
import api from '@/lib/api';
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { 
  Card, 
  CardContent, 
  CardHeader, 
  CardTitle,
  CardDescription 
} from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { 
  ClipboardCheck, 
  Search, 
  User as UserIcon, 
  MapPin, 
  Calendar, 
  CheckCircle2, 
  XCircle, 
  Eye, 
  Download, 
  Activity,
  Trees,
  Egg,
  Maximize2,
  Smartphone,
  Beef,
  Fish,
  Factory,
  Sprout
} from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";


interface UserData {
  id: number;
  cpf: string;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
}

interface VistoriaData {
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
      tipo_criacao?: string;
      qtd_animais?: number;
      qtd_galpoes?: number;
      qtd_modulos?: number;
      qtd_gaiolas_modulo?: number;
      aves_gaiola?: number;
      gera_residuos?: boolean;
      residuos_desc?: string;
    };
    suinocultura?: {
      qtd_galpoes?: number;
      qtd_animais?: number;
      fase_producao?: string;
      dejetos_destinacao?: string;
      conformidade?: boolean;
    };
    bovinocultura?: {
      modelo?: string;
      area_ha?: number;
      dessedentacao?: string;
    };
    aquicultura?: {
      qtd_tanques?: number;
      hidrometro?: boolean;
      outorga?: boolean;
      fonte_agua?: string;
    };
    sucroalcooleiro?: {
      residuos_solidos?: string;
      bagaco?: string;
      equipamentos_conformes?: boolean;
      armazenamento_ok?: boolean;
    };
    agricultura?: {
      cultivo?: string;
      cursos_hidricos_entorno?: string;
      agrotoxicos?: string;
    };
  };
  created_at?: string;
  synced_at?: string;
  updated_at?: string;
}

const VistoriasPage: React.FC = () => {
  const [vistorias, setVistorias] = useState<VistoriaData[]>([]);
  const [users, setUsers] = useState<UserData[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Search & Filter state
  const [search, setSearch] = useState('');
  const [selectedType, setSelectedType] = useState('todos');
  const [selectedUser, setSelectedUser] = useState('todos');
  const [selectedMunicipio, setSelectedMunicipio] = useState('todos');
  const [selectedDevice, setSelectedDevice] = useState('todos');
  const selectedStatus = 'todos';

  // Extract unique municipios present in current vistorias list
  const uniqueMunicipios = useMemo(() => {
    const map = new Map<number | string, string>();
    vistorias.forEach(v => {
      if (v.data.municipio) {
        map.set(v.data.municipio, v.data.municipio_nome || `Município: ${v.data.municipio}`);
      }
    });
    return Array.from(map.entries()).map(([id, nome]) => ({ id: id.toString(), nome }));
  }, [vistorias]);

  // Extract unique devices present in current vistorias list
  const uniqueDevices = useMemo(() => {
    const set = new Set<string>();
    vistorias.forEach(v => {
      if (v.data.dispositivo) {
        set.add(v.data.dispositivo);
      }
    });
    return Array.from(set).sort();
  }, [vistorias]);

  // Detail Dialog state
  const [isOpen, setIsOpen] = useState(false);
  const [selectedVistoria, setSelectedVistoria] = useState<VistoriaData | null>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      // Fetch vistorias and users in parallel
      const [vistoriasRes, usersRes] = await Promise.all([
        api.get('/vistorias/'),
        api.get('/auth/users/')
      ]);
      // Only keep vistorias that have been officially synchronized
      const syncedVistorias = (vistoriasRes.data || []).filter((v: any) => 
        (v.data?.status || 'sincronizada').toLowerCase() === 'sincronizada'
      );
      setVistorias(syncedVistorias);
      setUsers(usersRes.data);
    } catch (error) {
      console.error('Failed to fetch vistorias data', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  // Helper to resolve user name from id
  const getUserName = (userId: number) => {
    const user = users.find(u => u.id === userId);
    return user ? user.username : `ID: ${userId}`;
  };

  // Helper to determine the actual type of a vistoria
  const getVistoriaType = (v: VistoriaData) => {
    if (v.data.tipo) return v.data.tipo;
    if (v.data.supressao) return 'Supressão Vegetal';
    if (v.data.avicultura) return 'Avicultura';
    if (v.data.suinocultura) return 'Suinocultura';
    if (v.data.bovinocultura) return 'Bovinocultura';
    if (v.data.aquicultura) return 'Aquicultura';
    if (v.data.sucroalcooleiro) return 'Sucroalcooleiro';
    if (v.data.agricultura) return 'Agricultura';
    return 'Geral';
  };

  // Filter logic
  const filteredVistorias = vistorias.filter(v => {
    const matchesSearch = 
      (v.data.processo_n?.toLowerCase().includes(search.toLowerCase()) || '') ||
      (v.data.requerente?.toLowerCase().includes(search.toLowerCase()) || '') ||
      v.local_id.toLowerCase().includes(search.toLowerCase());

    const type = getVistoriaType(v).toLowerCase();
    const matchesType = selectedType === 'todos' || type.includes(selectedType.toLowerCase());

    const matchesUser = selectedUser === 'todos' || v.user.toString() === selectedUser;

    const matchesMunicipio = selectedMunicipio === 'todos' || v.data.municipio?.toString() === selectedMunicipio;

    const matchesDevice = selectedDevice === 'todos' || v.data.dispositivo === selectedDevice;

    const status = (v.data.status || 'sincronizada').toLowerCase();
    const matchesStatus = selectedStatus === 'todos' || status === selectedStatus;

    return matchesSearch && matchesType && matchesUser && matchesMunicipio && matchesDevice && matchesStatus;
  });

  const handleOpenDetails = (vistoria: VistoriaData) => {
    setSelectedVistoria(vistoria);
    setIsOpen(true);
  };

  // Stylized Type Badge mapping
  const getTypeBadge = (type: string) => {
    const lowerType = type.toLowerCase();
    if (lowerType.includes('supressão') || lowerType.includes('ambiental')) {
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

  // Helper to format date
  const formatDate = (dateStr?: string) => {
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

  // Stats calculation
  const totalCount = vistorias.length;
  const supressaoCount = vistorias.filter(v => {
    const t = getVistoriaType(v).toLowerCase();
    return t.includes('supressão') || t.includes('supressao');
  }).length;
  const aviculturaCount = vistorias.filter(v => getVistoriaType(v).toLowerCase().includes('avicultura')).length;
  const suinoculturaCount = vistorias.filter(v => getVistoriaType(v).toLowerCase().includes('suinocultura')).length;
  const bovinoculturaCount = vistorias.filter(v => getVistoriaType(v).toLowerCase().includes('bovinocultura')).length;
  const aquiculturaCount = vistorias.filter(v => getVistoriaType(v).toLowerCase().includes('aquicultura')).length;
  const sucroalcooleiroCount = vistorias.filter(v => getVistoriaType(v).toLowerCase().includes('sucroalcooleiro')).length;
  const agriculturaCount = vistorias.filter(v => getVistoriaType(v).toLowerCase().includes('agricultura')).length;

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-500">
      
      {/* Page Header */}
      <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Vistorias Realizadas</h2>
          <p className="text-muted-foreground">Monitore e analise as vistorias de campo e os formulários técnicos.</p>
        </div>
        <Button onClick={fetchData} variant="outline" className="w-full md:w-auto">
          <Activity className="mr-2 h-4 w-4" />
          Sincronizar Dados
        </Button>
      </div>

      {/* Metrics Row */}
      <div className="grid gap-3 grid-cols-2 sm:grid-cols-4 lg:grid-cols-8">
        
        {/* Card: Total Geral */}
        <Card className="relative overflow-hidden transition-all hover:shadow-md p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
          <div>
            <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-slate-500">Total</CardDescription>
            <CardTitle className="text-xl font-black mt-1 text-slate-800 dark:text-slate-100">{loading ? <Skeleton className="h-7 w-12" /> : totalCount}</CardTitle>
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
            <CardTitle className="text-xl font-black text-emerald-700 dark:text-emerald-400 mt-1">{loading ? <Skeleton className="h-7 w-12" /> : supressaoCount}</CardTitle>
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
            <CardTitle className="text-xl font-black text-amber-700 dark:text-amber-400 mt-1">{loading ? <Skeleton className="h-7 w-12" /> : aviculturaCount}</CardTitle>
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
            <CardTitle className="text-xl font-black text-pink-700 dark:text-pink-400 mt-1">{loading ? <Skeleton className="h-7 w-12" /> : suinoculturaCount}</CardTitle>
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
            <CardTitle className="text-xl font-black text-indigo-700 dark:text-indigo-400 mt-1">{loading ? <Skeleton className="h-7 w-12" /> : bovinoculturaCount}</CardTitle>
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
            <CardTitle className="text-xl font-black text-blue-700 dark:text-blue-400 mt-1">{loading ? <Skeleton className="h-7 w-12" /> : aquiculturaCount}</CardTitle>
          </div>
          <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
            <span className="text-[10px] text-muted-foreground">Peixes</span>
            <Fish className="w-4 h-4 text-blue-500 stroke-[2]" />
          </div>
        </Card>

        {/* Card: Sucroalcooleiro */}
        <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-purple-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
          <div>
            <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-purple-600 dark:text-purple-400">Usinas</CardDescription>
            <CardTitle className="text-xl font-black text-purple-700 dark:text-purple-400 mt-1">{loading ? <Skeleton className="h-7 w-12" /> : sucroalcooleiroCount}</CardTitle>
          </div>
          <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
            <span className="text-[10px] text-muted-foreground">Usinas</span>
            <Factory className="w-4 h-4 text-purple-500 stroke-[2]" />
          </div>
        </Card>

        {/* Card: Agricultura */}
        <Card className="relative overflow-hidden transition-all hover:shadow-md border-l-2 border-l-lime-500 p-3 flex flex-col justify-between bg-white dark:bg-slate-950">
          <div>
            <CardDescription className="text-[10px] uppercase font-bold tracking-wider text-lime-600 dark:text-lime-400">Lavoura</CardDescription>
            <CardTitle className="text-xl font-black text-lime-700 dark:text-lime-400 mt-1">{loading ? <Skeleton className="h-7 w-12" /> : agriculturaCount}</CardTitle>
          </div>
          <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100 dark:border-slate-900">
            <span className="text-[10px] text-muted-foreground">Cultivo</span>
            <Sprout className="w-4 h-4 text-lime-500 stroke-[2]" />
          </div>
        </Card>

      </div>

      {/* Filters Card */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle>Filtrar e Buscar</CardTitle>
          <CardDescription>Use os filtros abaixo para encontrar vistorias específicas por técnico, tipo ou status.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5">
            
            {/* Search Input */}
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input 
                placeholder="Nº Processo, Requerente ou ID..." 
                className="pl-10"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>

            {/* Type Filter */}
            <select
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value)}
              className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm ring-offset-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-950 focus-visible:ring-offset-2 dark:border-slate-800 dark:bg-slate-950 dark:ring-offset-slate-950 dark:focus-visible:ring-slate-300"
            >
              <option value="todos">Todos os Tipos</option>
              <option value="supressao">Supressão Vegetal</option>
              <option value="avicultura">Avicultura</option>
              <option value="suinocultura">Suinocultura</option>
              <option value="bovinocultura">Bovinocultura</option>
              <option value="aquicultura">Aquicultura</option>
              <option value="sucroalcooleiro">Sucroalcooleiro</option>
              <option value="agricultura">Agricultura</option>
            </select>

            {/* User Filter */}
            <select
              value={selectedUser}
              onChange={(e) => setSelectedUser(e.target.value)}
              className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm ring-offset-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-950 focus-visible:ring-offset-2 dark:border-slate-800 dark:bg-slate-950 dark:ring-offset-slate-950 dark:focus-visible:ring-slate-300"
            >
              <option value="todos">Todos os Técnicos</option>
              {users.map(u => (
                <option key={u.id} value={u.id.toString()}>{u.username}</option>
              ))}
            </select>

            {/* Município Filter */}
            <select
              value={selectedMunicipio}
              onChange={(e) => setSelectedMunicipio(e.target.value)}
              className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm ring-offset-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-950 focus-visible:ring-offset-2 dark:border-slate-800 dark:bg-slate-950 dark:ring-offset-slate-950 dark:focus-visible:ring-slate-300"
            >
              <option value="todos">Todos os Municípios</option>
              {uniqueMunicipios.map(m => (
                <option key={m.id} value={m.id}>{m.nome}</option>
              ))}
            </select>

            {/* Dispositivo Filter */}
            <select
              value={selectedDevice}
              onChange={(e) => setSelectedDevice(e.target.value)}
              className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm ring-offset-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-950 focus-visible:ring-offset-2 dark:border-slate-800 dark:bg-slate-950 dark:ring-offset-slate-950 dark:focus-visible:ring-slate-300"
            >
              <option value="todos">Todos os Dispositivos</option>
              {uniqueDevices.map(d => (
                <option key={d} value={d}>{d}</option>
              ))}
            </select>

          </div>
        </CardContent>
      </Card>

      {/* Main List */}
      <Card>
        <CardContent className="pt-6">
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
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="h-8 w-8 hover:bg-slate-200 dark:hover:bg-slate-800"
                            onClick={() => handleOpenDetails(v)}
                          >
                            <Eye className="h-4 w-4 text-slate-600 dark:text-slate-400" />
                          </Button>
                        </TableCell>
                      </TableRow>
                    );
                  })
                ) : (
                  <TableRow>
                    <TableCell colSpan={8} className="h-24 text-center text-muted-foreground">
                      Nenhuma vistoria encontrada com os filtros aplicados.
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      {/* Detailed Modal Dialog */}
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-w-[90vw] md:max-w-5xl lg:max-w-6xl xl:max-w-7xl max-h-[90vh] overflow-y-auto">
          {selectedVistoria && (
            <>
              <DialogHeader className="border-b border-slate-100 dark:border-slate-800 pb-4">
                <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                  <div className="flex items-center gap-2">
                    <ClipboardCheck className="w-6 h-6 text-primary shrink-0" />
                    <DialogTitle className="text-xl font-bold">
                      Processo {selectedVistoria.data.processo_n || 'N/A'}
                    </DialogTitle>
                  </div>
                  <div className="flex items-center gap-2">
                    {getTypeBadge(getVistoriaType(selectedVistoria))}
                    <span className="text-xs font-mono text-muted-foreground bg-slate-100 dark:bg-slate-800 px-2 py-0.5 rounded">
                      ID: {selectedVistoria.local_id}
                    </span>
                  </div>
                </div>
                <DialogDescription className="pt-2">
                  Dados completos e preenchimento de campo do requerente <strong>{selectedVistoria.data.requerente || 'Não informado'}</strong>.
                </DialogDescription>
              </DialogHeader>

              {/* Grid content of Vistoria */}
              <div className="grid md:grid-cols-3 gap-6 py-4">
                
                {/* Left Side: General Info */}
                <div className="md:col-span-1 space-y-4">
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
                      <span className="text-muted-foreground block">Local UUID (Celular)</span>
                      <span className="font-mono text-[10px] text-slate-600 dark:text-slate-400">{selectedVistoria.local_id}</span>
                    </div>
                    <div>
                      <span className="text-muted-foreground block">Município</span>
                      <span className="font-semibold text-slate-800 dark:text-slate-200">
                        {selectedVistoria.data.municipio_nome 
                          ? `${selectedVistoria.data.municipio_nome} (${selectedVistoria.data.municipio})`
                          : selectedVistoria.data.municipio || '-'}
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

                  {/* Mock Coordinate Viewer Map */}
                  {selectedVistoria.data.latitude && selectedVistoria.data.longitude && (
                    <div className="bg-slate-100 dark:bg-slate-900 rounded-lg p-3 text-center border space-y-2">
                      <div className="text-[10px] uppercase font-bold text-muted-foreground tracking-wider">Localização do Relatório</div>
                      <div className="bg-slate-200 dark:bg-slate-800 h-24 rounded flex items-center justify-center border border-slate-300 dark:border-slate-700 relative overflow-hidden">
                        <div className="absolute inset-0 opacity-20 bg-[radial-gradient(#000_1px,transparent_1px)] [background-size:16px_16px]"></div>
                        <MapPin className="w-8 h-8 text-red-500 animate-bounce" />
                      </div>
                      <a 
                        href={`https://www.google.com/maps/search/?api=1&query=${selectedVistoria.data.latitude},${selectedVistoria.data.longitude}`}
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="text-[11px] text-blue-500 hover:underline block font-semibold"
                      >
                        Ver no Google Maps →
                      </a>
                    </div>
                  )}
                </div>

                {/* Right Side: Specific Sub-model Form Details */}
                <div className="md:col-span-2 space-y-4">
                  <h4 className="font-bold text-sm text-slate-900 dark:text-slate-100 border-b pb-2 uppercase tracking-wide">Ficha Técnica do Formulário</h4>

                  {/* SUPRESSÃO VEGETAL UI */}
                  {selectedVistoria.data.supressao && (
                    <div className="space-y-4 bg-emerald-50/30 dark:bg-emerald-950/10 p-4 rounded-lg border border-emerald-100 dark:border-emerald-950/30">
                      <div className="grid grid-cols-2 gap-4 text-xs">
                        <div className="flex items-center gap-2">
                          {selectedVistoria.data.supressao.tem_curso_dagua ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span>Curso d'água presente</span>
                        </div>
                        <div className="flex items-center gap-2">
                          {selectedVistoria.data.supressao.app_preservada ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span>APP Preservada</span>
                        </div>
                        <div className="flex items-center gap-2">
                          {selectedVistoria.data.supressao.indicios_uso_app ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span>Indícios de uso da APP</span>
                        </div>
                        <div className="flex items-center gap-2">
                          {selectedVistoria.data.supressao.rl_isolada ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span>Reserva Legal Isolada</span>
                        </div>
                      </div>

                      <div className="border-t pt-3 mt-3 grid grid-cols-2 gap-4 text-xs">
                        <div>
                          <span className="text-muted-foreground block">Bioma Dominante</span>
                          <span className="font-bold">{selectedVistoria.data.supressao.bioma || 'Mata Atlântica'}</span>
                        </div>
                        <div>
                          <span className="text-muted-foreground block">Infracção Constatada</span>
                          <span className="font-bold text-red-600 dark:text-red-400">{selectedVistoria.data.supressao.infracao || 'Nenhuma'}</span>
                        </div>
                      </div>

                      {selectedVistoria.data.supressao.observacoes && (
                        <div className="border-t pt-3 mt-3 text-xs">
                          <span className="text-muted-foreground block">Observações Técnicas</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed">
                            {selectedVistoria.data.supressao.observacoes}
                          </p>
                        </div>
                      )}
                    </div>
                  )}

                  {/* AVICULTURA UI */}
                  {selectedVistoria.data.avicultura && (
                    <div className="space-y-4 bg-amber-50/30 dark:bg-amber-950/10 p-4 rounded-lg border border-amber-100 dark:border-amber-950/30">
                      <div className="grid grid-cols-2 gap-4 text-xs">
                        <div>
                          <span className="text-muted-foreground block">Modelo de Operação</span>
                          <span className="font-bold text-sm uppercase">{selectedVistoria.data.avicultura.modelo || '-'}</span>
                        </div>
                        <div>
                          <span className="text-muted-foreground block">Tipo de Criação</span>
                          <span className="font-bold text-sm uppercase">{selectedVistoria.data.avicultura.tipo_criacao || '-'}</span>
                        </div>
                        <div>
                          <span className="text-muted-foreground block">Quantidade de Animais</span>
                          <span className="font-bold text-base text-amber-700 dark:text-amber-400">{selectedVistoria.data.avicultura.qtd_animais || '0'}</span>
                        </div>
                        <div>
                          <span className="text-muted-foreground block">Quantidade de Galpões</span>
                          <span className="font-bold text-sm">{selectedVistoria.data.avicultura.qtd_galpoes || '0'}</span>
                        </div>
                      </div>

                      {selectedVistoria.data.avicultura.gera_residuos && (
                        <div className="border-t pt-3 mt-3 text-xs">
                          <span className="text-amber-700 font-bold block mb-1">Geração de Resíduos</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed">
                            {selectedVistoria.data.avicultura.residuos_desc || 'Gera resíduos mas não detalhado.'}
                          </p>
                        </div>
                      )}
                    </div>
                  )}

                  {/* SUINOCULTURA UI */}
                  {selectedVistoria.data.suinocultura && (
                    <div className="space-y-4 bg-pink-50/30 dark:bg-pink-950/10 p-4 rounded-lg border border-pink-100 dark:border-pink-950/30">
                      <div className="grid grid-cols-2 gap-4 text-xs">
                        <div>
                          <span className="text-muted-foreground block">Quantidade de Animais</span>
                          <span className="font-bold text-base text-pink-700 dark:text-pink-400">{selectedVistoria.data.suinocultura.qtd_animais || '0'}</span>
                        </div>
                        <div>
                          <span className="text-muted-foreground block">Fase de Produção</span>
                          <span className="font-bold text-sm">{selectedVistoria.data.suinocultura.fase_producao || '-'}</span>
                        </div>
                        <div className="flex items-center gap-2 pt-2">
                          {selectedVistoria.data.suinocultura.conformidade ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span className="font-bold">Em Conformidade</span>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* BOVINOCULTURA UI */}
                  {selectedVistoria.data.bovinocultura && (
                    <div className="space-y-4 bg-indigo-50/30 dark:bg-indigo-950/10 p-4 rounded-lg border border-indigo-100 dark:border-indigo-950/30">
                      <div className="grid grid-cols-2 gap-4 text-xs">
                        <div>
                          <span className="text-muted-foreground block">Modelo de Criação</span>
                          <span className="font-bold text-sm uppercase">{selectedVistoria.data.bovinocultura.modelo || '-'}</span>
                        </div>
                        <div>
                          <span className="text-muted-foreground block">Área de Pastagem (hectares)</span>
                          <span className="font-bold text-sm">{selectedVistoria.data.bovinocultura.area_ha ? `${selectedVistoria.data.bovinocultura.area_ha} ha` : '-'}</span>
                        </div>
                      </div>
                      {selectedVistoria.data.bovinocultura.dessedentacao && (
                        <div className="border-t pt-3 mt-3 text-xs">
                          <span className="text-muted-foreground block">Dessedentação Animal</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed">
                            {selectedVistoria.data.bovinocultura.dessedentacao}
                          </p>
                        </div>
                      )}
                    </div>
                  )}

                  {/* AQUICULTURA UI */}
                  {selectedVistoria.data.aquicultura && (
                    <div className="space-y-4 bg-blue-50/30 dark:bg-blue-950/10 p-4 rounded-lg border border-blue-100 dark:border-blue-950/30">
                      <div className="grid grid-cols-2 gap-4 text-xs">
                        <div>
                          <span className="text-muted-foreground block">Quantidade de Tanques</span>
                          <span className="font-bold text-base text-blue-700 dark:text-blue-400">{selectedVistoria.data.aquicultura.qtd_tanques || '0'}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          {selectedVistoria.data.aquicultura.hidrometro ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span className="font-bold">Possui Hidrômetro</span>
                        </div>
                        <div className="flex items-center gap-2">
                          {selectedVistoria.data.aquicultura.outorga ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span className="font-bold">Possui Outorga</span>
                        </div>
                      </div>
                      {selectedVistoria.data.aquicultura.fonte_agua && (
                        <div className="border-t pt-3 mt-3 text-xs">
                          <span className="text-muted-foreground block">Fonte de Abastecimento de Água</span>
                          <p className="bg-white dark:bg-slate-900 p-2.5 rounded border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-300 mt-1 leading-relaxed">
                            {selectedVistoria.data.aquicultura.fonte_agua}
                          </p>
                        </div>
                      )}
                    </div>
                  )}

                  {/* SUCROALCOOLEIRO UI */}
                  {selectedVistoria.data.sucroalcooleiro && (
                    <div className="space-y-4 bg-purple-50/30 dark:bg-purple-950/10 p-4 rounded-lg border border-purple-100 dark:border-purple-950/30">
                      <div className="grid grid-cols-2 gap-4 text-xs">
                        <div className="flex items-center gap-2">
                          {selectedVistoria.data.sucroalcooleiro.equipamentos_conformes ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span className="font-bold">Equipamentos Conformes</span>
                        </div>
                        <div className="flex items-center gap-2">
                          {selectedVistoria.data.sucroalcooleiro.armazenamento_ok ? <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" /> : <XCircle className="w-4 h-4 text-red-500 shrink-0" />}
                          <span className="font-bold">Armazenamento Correto</span>
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

              <DialogFooter className="border-t border-slate-100 dark:border-slate-800 pt-4 mt-4">
                <Button variant="outline" onClick={() => setIsOpen(false)}>
                  Fechar Detalhes
                </Button>
                <Button className="gap-2" onClick={() => window.print()}>
                  <Download className="w-4 h-4" />
                  Exportar PDF / Imprimir
                </Button>
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default VistoriasPage;
