import React, { useEffect, useState } from 'react';
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
import { UserPlus, Search, MoreHorizontal, ShieldCheck, User, Trash2, Edit2, CheckCircle2, XCircle } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator, 
  DropdownMenuTrigger,
  DropdownMenuGroup 
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Label } from '@/components/ui/label';

interface UserData {
  id: number;
  cpf: string;
  username: string;
  email: string;
  first_name: string;
  last_name: string;
  is_staff: boolean;
  is_active: boolean;
}

const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<UserData[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  
  // Dialog state
  const [isOpen, setIsOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<UserData | null>(null);
  const [formData, setFormData] = useState({
    cpf: '',
    username: '',
    email: '',
    first_name: '',
    last_name: '',
    password: '',
    is_staff: false,
  });

  const fetchUsers = async () => {
    try {
      const response = await api.get('/auth/users/');
      setUsers(response.data);
    } catch (error) {
      console.error('Failed to fetch users', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleOpenCreate = () => {
    setEditingUser(null);
    setFormData({
      cpf: '',
      username: '',
      email: '',
      first_name: '',
      last_name: '',
      password: '',
      is_staff: false,
    });
    setIsOpen(true);
  };

  const handleOpenEdit = (user: UserData) => {
    setEditingUser(user);
    setFormData({
      cpf: user.cpf,
      username: user.username,
      email: user.email || '',
      first_name: user.first_name || '',
      last_name: user.last_name || '',
      password: '', // Password stays empty unless changing
      is_staff: user.is_staff,
    });
    setIsOpen(true);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingUser) {
        // Update - using PATCH for partial
        const dataToUpdate = { ...formData };
        if (!dataToUpdate.password) delete (dataToUpdate as any).password;
        await api.patch(`/auth/users/${editingUser.id}/`, dataToUpdate);
      } else {
        // Create - automatically set username equal to CPF
        const payload = {
          ...formData,
          username: formData.cpf
        };
        await api.post('/auth/register/', payload);
      }
      setIsOpen(false);
      fetchUsers();
    } catch (error) {
      console.error('Failed to save user', error);
      alert('Erro ao salvar usuário. Verifique os dados.');
    }
  };

  const handleDeactivate = async (user: UserData) => {
    if (window.confirm(`Deseja realmente desativar o usuário ${user.username}?`)) {
      try {
        await api.delete(`/auth/users/${user.id}/`);
        fetchUsers();
      } catch (error) {
        console.error('Failed to deactivate user', error);
      }
    }
  };

  const handleToggleStaff = async (user: UserData) => {
    try {
      await api.patch(`/auth/users/${user.id}/`, { is_staff: !user.is_staff });
      fetchUsers();
    } catch (error) {
      console.error('Failed to toggle staff status', error);
    }
  };

  const filteredUsers = users.filter(user => 
    user.username.toLowerCase().includes(search.toLowerCase()) ||
    user.cpf.includes(search) ||
    user.email?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-500">
      <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Gestão de Usuários</h2>
          <p className="text-muted-foreground">Gerencie os acessos e permissões dos usuários do sistema.</p>
        </div>
        <Button onClick={handleOpenCreate} className="w-full md:w-auto transition-all hover:scale-[1.02]">
          <UserPlus className="mr-2 h-4 w-4" />
          Novo Usuário
        </Button>
      </div>

      <Card>
        <CardHeader className="pb-3">
          <CardTitle>Listagem</CardTitle>
          <CardDescription>
            Total de {users.length} usuários cadastrados.
          </CardDescription>
          <div className="pt-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input 
                placeholder="Pesquisar por nome, CPF ou e-mail..." 
                className="pl-10 max-w-md"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="rounded-md border border-slate-200 dark:border-slate-800 overflow-x-auto w-full">
            <Table>
              <TableHeader className="bg-slate-50 dark:bg-slate-900">
                <TableRow>
                  <TableHead className="w-[80px]">ID</TableHead>
                  <TableHead>Nome de Usuário</TableHead>
                  <TableHead>CPF</TableHead>
                  <TableHead>E-mail</TableHead>
                  <TableHead>Cargo</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loading ? (
                  Array.from({ length: 5 }).map((_, i) => (
                    <TableRow key={i}>
                      <TableCell><Skeleton className="h-4 w-8" /></TableCell>
                      <TableCell><Skeleton className="h-4 w-32" /></TableCell>
                      <TableCell><Skeleton className="h-4 w-24" /></TableCell>
                      <TableCell><Skeleton className="h-4 w-40" /></TableCell>
                      <TableCell><Skeleton className="h-4 w-20" /></TableCell>
                      <TableCell><Skeleton className="h-4 w-16" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-8 w-8 ml-auto rounded-full" /></TableCell>
                    </TableRow>
                  ))
                ) : filteredUsers.length > 0 ? (
                  filteredUsers.map((user) => (
                    <TableRow key={user.id} className={`hover:bg-slate-50/50 dark:hover:bg-slate-900/50 transition-colors ${!user.is_active ? 'opacity-50' : ''}`}>
                      <TableCell className="font-mono text-xs">{user.id}</TableCell>
                      <TableCell className="font-medium">
                        <div className="flex items-center gap-2">
                          <div className={`w-8 h-8 rounded-full flex items-center justify-center ${user.is_active ? 'bg-slate-100 dark:bg-slate-800' : 'bg-red-100 dark:bg-red-900/30'}`}>
                            <User className={`w-4 h-4 ${user.is_active ? 'text-slate-500' : 'text-red-500'}`} />
                          </div>
                          <div className="flex flex-col">
                            <span>{user.username}</span>
                            <span className="text-[10px] text-muted-foreground uppercase">{user.first_name} {user.last_name}</span>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>{user.cpf}</TableCell>
                      <TableCell>{user.email || '-'}</TableCell>
                      <TableCell>
                        {user.is_staff ? (
                          <div className="inline-flex items-center gap-1 px-2 py-1 rounded-full bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400 text-[10px] font-bold uppercase tracking-wider">
                            <ShieldCheck className="w-3 h-3" />
                            Administrador
                          </div>
                        ) : (
                          <div className="inline-flex items-center gap-1 px-2 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 text-[10px] font-bold uppercase tracking-wider">
                            Usuário
                          </div>
                        )}
                      </TableCell>
                      <TableCell>
                        {user.is_active ? (
                          <div className="flex items-center gap-1 text-emerald-600 dark:text-emerald-400 text-xs">
                            <CheckCircle2 className="w-3.5 h-3.5" />
                            Ativo
                          </div>
                        ) : (
                          <div className="flex items-center gap-1 text-red-600 dark:text-red-400 text-xs">
                            <XCircle className="w-3.5 h-3.5" />
                            Inativo
                          </div>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger render={<Button variant="ghost" className="h-8 w-8 p-0 hover:bg-slate-200 dark:hover:bg-slate-800" />}>
                            <MoreHorizontal className="h-4 w-4" />
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuGroup>
                              <DropdownMenuLabel>Gerenciamento</DropdownMenuLabel>
                              <DropdownMenuItem onClick={() => handleOpenEdit(user)}>
                                <Edit2 className="mr-2 h-4 w-4" />
                                Editar
                              </DropdownMenuItem>
                              <DropdownMenuItem onClick={() => handleToggleStaff(user)}>
                                <ShieldCheck className="mr-2 h-4 w-4" />
                                {user.is_staff ? 'Remover Admin' : 'Tornar Admin'}
                              </DropdownMenuItem>
                            </DropdownMenuGroup>
                            <DropdownMenuSeparator />
                            <DropdownMenuGroup>
                              {user.is_active ? (
                                <DropdownMenuItem 
                                  className="text-destructive"
                                  onClick={() => handleDeactivate(user)}
                                >
                                  <Trash2 className="mr-2 h-4 w-4" />
                                  Desativar usuário
                                </DropdownMenuItem>
                              ) : (
                                <DropdownMenuItem 
                                  className="text-emerald-600"
                                  onClick={() => handleToggleStaff({ ...user, is_active: true } as any)} // Using patch normally
                                  disabled // Not implemented toggle active yet
                                >
                                  Ativar usuário
                                </DropdownMenuItem>
                              )}
                            </DropdownMenuGroup>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={7} className="h-24 text-center text-muted-foreground">
                      Nenhum usuário encontrado.
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      {/* Create/Edit Dialog */}
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>{editingUser ? 'Editar Usuário' : 'Novo Usuário'}</DialogTitle>
            <DialogDescription>
              {editingUser ? 'Atualize as informações do usuário abaixo.' : 'Preencha os dados para cadastrar um novo administrador ou usuário.'}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSave} className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="cpf">CPF</Label>
              <Input 
                id="cpf" 
                value={formData.cpf}
                onChange={(e) => setFormData({...formData, cpf: e.target.value})}
                maxLength={11}
                required 
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">E-mail</Label>
              <Input 
                id="email" 
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="first_name">Primeiro Nome</Label>
                <Input 
                  id="first_name" 
                  value={formData.first_name}
                  onChange={(e) => setFormData({...formData, first_name: e.target.value})}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="last_name">Sobrenome</Label>
                <Input 
                  id="last_name" 
                  value={formData.last_name}
                  onChange={(e) => setFormData({...formData, last_name: e.target.value})}
                />
              </div>
            </div>
            {!editingUser && (
              <div className="space-y-2">
                <Label htmlFor="password">Senha</Label>
                <Input 
                  id="password" 
                  type="password"
                  value={formData.password}
                  onChange={(e) => setFormData({...formData, password: e.target.value})}
                  required={!editingUser}
                />
              </div>
            )}
            <div className="flex items-center space-x-2 pt-2">
              <input 
                type="checkbox" 
                id="is_staff" 
                className="rounded border-slate-300"
                checked={formData.is_staff}
                onChange={(e) => setFormData({...formData, is_staff: e.target.checked})}
              />
              <Label htmlFor="is_staff">Acesso Administrativo (Staff)</Label>
            </div>
            <DialogFooter className="pt-4">
              <Button type="button" variant="outline" onClick={() => setIsOpen(false)}>Cancelar</Button>
              <Button type="submit">Salvar Alterações</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default UsersPage;
