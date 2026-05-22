import React from 'react';
import { 
  Card, 
  CardContent, 
  CardDescription, 
  CardHeader, 
  CardTitle 
} from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Search } from 'lucide-react';
import type { UserData } from './types';

interface VistoriaFiltersProps {
  search: string;
  setSearch: (val: string) => void;
  selectedType: string;
  setSelectedType: (val: string) => void;
  selectedUser: string;
  setSelectedUser: (val: string) => void;
  selectedMunicipio: string;
  setSelectedMunicipio: (val: string) => void;
  selectedDevice: string;
  setSelectedDevice: (val: string) => void;
  users: UserData[];
  uniqueMunicipios: { id: string; nome: string }[];
  uniqueDevices: string[];
}

const VistoriaFilters: React.FC<VistoriaFiltersProps> = React.memo(({
  search,
  setSearch,
  selectedType,
  setSelectedType,
  selectedUser,
  setSelectedUser,
  selectedMunicipio,
  setSelectedMunicipio,
  selectedDevice,
  setSelectedDevice,
  users,
  uniqueMunicipios,
  uniqueDevices
}) => {
  return (
    <Card className="shadow-sm">
      <CardHeader className="pb-3">
        <CardTitle className="text-lg font-bold">Filtrar e Buscar</CardTitle>
        <CardDescription className="text-xs">
          Use os filtros abaixo para encontrar vistorias específicas por técnico, tipo ou município.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5">
          {/* Search Input */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input 
              placeholder="Nº Processo, Requerente ou ID..." 
              className="pl-10 text-sm bg-white dark:bg-slate-950 border-slate-200 dark:border-slate-800"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          {/* Type Filter */}
          <select
            value={selectedType}
            onChange={(e) => setSelectedType(e.target.value)}
            className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200"
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
            className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200"
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
            className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200"
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
            className="flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-950 dark:border-slate-800 dark:bg-slate-950 dark:text-slate-200"
          >
            <option value="todos">Todos os Dispositivos</option>
            {uniqueDevices.map(d => (
              <option key={d} value={d}>{d}</option>
            ))}
          </select>
        </div>
      </CardContent>
    </Card>
  );
});

VistoriaFilters.displayName = 'VistoriaFilters';

export default VistoriaFilters;
