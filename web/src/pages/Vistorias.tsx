import React, { useEffect, useState, useMemo, useCallback } from 'react';
import api from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Activity } from 'lucide-react';

// Imported Modular Subcomponents and Typings
import { type VistoriaData, type UserData, getVistoriaType } from '@/components/vistorias/types';
import VistoriaMetrics from '@/components/vistorias/VistoriaMetrics';
import VistoriaFilters from '@/components/vistorias/VistoriaFilters';
import VistoriaTable from '@/components/vistorias/VistoriaTable';
import VistoriaDetailsDialog from '@/components/vistorias/VistoriaDetailsDialog';
import VistoriaEditDialog from '@/components/vistorias/VistoriaEditDialog';

const VistoriasPage: React.FC = () => {
  const { user: currentUser } = useAuth();
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

  // Detail Dialog state
  const [isOpen, setIsOpen] = useState(false);
  const [selectedVistoria, setSelectedVistoria] = useState<VistoriaData | null>(null);

  // Edit Dialog state
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [editingVistoria, setEditingVistoria] = useState<VistoriaData | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  // Fetch vistorias and users
  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      
      // Fetch vistorias
      let vistoriasList: any[] = [];
      try {
        const vRes = await api.get('/vistorias/');
        vistoriasList = vRes.data || [];
      } catch (err) {
        console.error("Erro ao buscar vistorias:", err);
      }

      // Fetch users (only if current user is admin/staff)
      let usersList: any[] = [];
      if (currentUser?.is_staff) {
        try {
          const uRes = await api.get('/auth/users/');
          usersList = uRes.data || [];
        } catch (err) {
          console.error("Erro ao buscar usuários:", err);
          usersList = currentUser ? [currentUser] : [];
        }
      } else {
        // Fallback for technicians: they can only see/reference themselves
        usersList = currentUser ? [currentUser] : [];
      }

      // Only keep vistorias that have been officially synchronized
      const syncedVistorias = vistoriasList.filter((v: any) => 
        (v.data?.status || 'sincronizada').toLowerCase() === 'sincronizada'
      );
      
      // Sort vistorias from newest to oldest (by created_at)
      syncedVistorias.sort((a, b) => {
        const timeA = a.created_at ? new Date(a.created_at).getTime() : 0;
        const timeB = b.created_at ? new Date(b.created_at).getTime() : 0;
        return timeB - timeA;
      });
      
      setVistorias(syncedVistorias);
      setUsers(usersList);
    } catch (error) {
      console.error('Failed to fetch vistorias data', error);
    } finally {
      setLoading(false);
    }
  }, [currentUser]);

  useEffect(() => {
    if (currentUser) {
      fetchData();
    }
  }, [currentUser, fetchData]);

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

  // Filter logic
  const filteredVistorias = useMemo(() => {
    return vistorias.filter(v => {
      const matchesSearch = 
        (v.data.processo_n?.toLowerCase().includes(search.toLowerCase()) || false) ||
        (v.data.requerente?.toLowerCase().includes(search.toLowerCase()) || false) ||
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
  }, [vistorias, search, selectedType, selectedUser, selectedMunicipio, selectedDevice, selectedStatus]);

  // Open Details sheet
  const handleOpenDetails = useCallback(async (vistoria: VistoriaData) => {
    try {
      const detailRes = await api.get(`/vistorias/${vistoria.local_id}/`);
      setSelectedVistoria(detailRes.data);
    } catch (error) {
      console.error("Erro ao carregar detalhes da vistoria:", error);
      setSelectedVistoria(vistoria);
    }
    setIsOpen(true);
  }, []);

  // Open Edit sheet
  const handleOpenEdit = useCallback(async (vistoria: VistoriaData) => {
    try {
      const detailRes = await api.get(`/vistorias/${vistoria.local_id}/`);
      setEditingVistoria(detailRes.data);
    } catch (error) {
      console.error("Erro ao carregar dados para edição:", error);
      setEditingVistoria(JSON.parse(JSON.stringify(vistoria))); // fallback
    }
    setIsEditOpen(true);
  }, []);

  // Save Edit changes
  const handleSaveEdit = useCallback(async () => {
    if (!editingVistoria) return;
    setIsSaving(true);
    try {
      await api.put(`/vistorias/${editingVistoria.local_id}/`, editingVistoria);
      setIsEditOpen(false);
      fetchData(); // refresh list
    } catch (error) {
      console.error("Erro ao salvar vistoria:", error);
      throw error; // Propagate error so dialog can catch and show standard alert
    } finally {
      setIsSaving(false);
    }
  }, [editingVistoria, fetchData]);

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-500">
      {/* Page Header */}
      <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight text-slate-900 dark:text-slate-100">Vistorias Realizadas</h2>
          <p className="text-muted-foreground text-sm">Monitore e analise as vistorias de campo e os formulários técnicos.</p>
        </div>
        <Button onClick={fetchData} variant="outline" className="w-full md:w-auto hover:bg-slate-100 dark:hover:bg-slate-800">
          <Activity className="mr-2 h-4 w-4" />
          Sincronizar Dados
        </Button>
      </div>

      {/* Metrics Row */}
      <VistoriaMetrics vistorias={vistorias} loading={loading} />

      {/* Filter Row */}
      <VistoriaFilters 
        search={search}
        setSearch={setSearch}
        selectedType={selectedType}
        setSelectedType={setSelectedType}
        selectedUser={selectedUser}
        setSelectedUser={setSelectedUser}
        selectedMunicipio={selectedMunicipio}
        setSelectedMunicipio={setSelectedMunicipio}
        selectedDevice={selectedDevice}
        setSelectedDevice={setSelectedDevice}
        users={users}
        uniqueMunicipios={uniqueMunicipios}
        uniqueDevices={uniqueDevices}
      />

      {/* Main List Table */}
      <Card className="shadow-sm">
        <CardContent className="pt-6">
          <VistoriaTable 
            filteredVistorias={filteredVistorias}
            users={users}
            loading={loading}
            handleOpenDetails={handleOpenDetails}
            handleOpenEdit={handleOpenEdit}
          />
        </CardContent>
      </Card>

      {/* Details Sheet Modal */}
      <VistoriaDetailsDialog 
        isOpen={isOpen}
        setIsOpen={setIsOpen}
        selectedVistoria={selectedVistoria}
        users={users}
      />

      {/* Edit Form Dialog Modal */}
      <VistoriaEditDialog 
        isOpen={isEditOpen}
        setIsOpen={setIsEditOpen}
        editingVistoria={editingVistoria}
        setEditingVistoria={setEditingVistoria}
        onSave={handleSaveEdit}
        isSaving={isSaving}
      />
    </div>
  );
};

export default VistoriasPage;
