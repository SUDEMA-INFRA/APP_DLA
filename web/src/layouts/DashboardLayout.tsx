import React from 'react';
import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { 
  Sidebar, 
  SidebarContent, 
  SidebarFooter, 
  SidebarHeader, 
  SidebarProvider, 
  SidebarTrigger,
  SidebarInset,
  SidebarMenu,
  SidebarMenuItem,
  SidebarMenuButton,
  SidebarGroup,
  SidebarGroupLabel,
  SidebarGroupContent
} from '@/components/ui/sidebar';
import { LayoutDashboard, Users, LogOut, Shield, User as UserIcon, ClipboardCheck } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';

const DashboardLayout: React.FC = () => {
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  const menuItems = [
    { title: 'Dashboard', icon: LayoutDashboard, path: '/' },
    { title: 'Usuários', icon: Users, path: '/users' },
    { title: 'Vistorias', icon: ClipboardCheck, path: '/vistorias' },
  ];

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <SidebarProvider>
      <Sidebar collapsible="icon" className="border-r border-slate-200 dark:border-slate-800">
        <SidebarHeader className="p-4 group-data-[collapsible=icon]:p-2">
          <div className="flex items-center gap-3 px-2 py-1 group-data-[collapsible=icon]:justify-center group-data-[collapsible=icon]:px-0">
            <div className="bg-primary rounded-lg p-1.5 text-primary-foreground shrink-0">
              <Shield className="w-5 h-5" />
            </div>
            <span className="font-bold text-lg tracking-tight group-data-[collapsible=icon]:hidden">
              SUDEMA DLA
            </span>
          </div>
        </SidebarHeader>
        <SidebarContent>
          <SidebarGroup>
            <SidebarGroupLabel>Menu Principal</SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu>
                {menuItems.map((item) => (
                  <SidebarMenuItem key={item.path}>
                    <SidebarMenuButton 
                      render={<Link to={item.path} />}
                      isActive={location.pathname === item.path}
                      tooltip={item.title}
                    >
                      <item.icon />
                      <span>{item.title}</span>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                ))}
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>
        </SidebarContent>
        <SidebarFooter className="p-4 border-t border-slate-200 dark:border-slate-800">
          <div className="flex items-center gap-3 px-2 py-2 mb-2 group-data-[collapsible=icon]:hidden">
            <div className="bg-slate-200 dark:bg-slate-800 rounded-full p-2 shrink-0">
              <UserIcon className="w-4 h-4" />
            </div>
            <div className="flex flex-col overflow-hidden">
              <span className="text-sm font-medium truncate">{user?.username}</span>
              <span className="text-xs text-muted-foreground truncate">{user?.email}</span>
            </div>
          </div>
          <Button 
            variant="ghost" 
            className="w-full justify-start text-destructive hover:text-destructive hover:bg-destructive/10 group-data-[collapsible=icon]:justify-center group-data-[collapsible=icon]:px-2"
            onClick={handleLogout}
          >
            <LogOut className="h-4 w-4 group-data-[collapsible=icon]:mr-0 mr-2" />
            <span className="group-data-[collapsible=icon]:hidden">Sair</span>
          </Button>
        </SidebarFooter>
      </Sidebar>

      <SidebarInset>
        <header className="h-16 flex items-center gap-4 px-4 sm:px-6 border-b border-slate-200 dark:border-slate-800 bg-white/50 dark:bg-slate-950/50 backdrop-blur-sm sticky top-0 z-20">
          <SidebarTrigger />
          <Separator orientation="vertical" className="h-4" />
          <div className="flex-1">
            <h1 className="text-sm font-semibold text-muted-foreground">
              {menuItems.find(i => i.path === location.pathname)?.title || 'Dashboard'}
            </h1>
          </div>
        </header>
        <main className="flex-1 p-4 sm:p-6 overflow-auto bg-slate-50/50 dark:bg-slate-950/50">
          <div className="space-y-6">
            <Outlet />
          </div>
        </main>
      </SidebarInset>
    </SidebarProvider>
  );
};

export default DashboardLayout;
