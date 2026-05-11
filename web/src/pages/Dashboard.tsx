import React from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Users, FileText, CheckCircle2, AlertCircle, TrendingUp } from 'lucide-react';

const Dashboard: React.FC = () => {
  const stats = [
    { title: 'Total de Usuários', value: '128', icon: Users, description: '+4 no último mês', color: 'text-blue-500' },
    { title: 'Vistorias Pendentes', value: '42', icon: FileText, description: '-2 desde ontem', color: 'text-amber-500' },
    { title: 'Vistorias Concluídas', value: '856', icon: CheckCircle2, description: '+12 esta semana', color: 'text-emerald-500' },
    { title: 'Alertas Ativos', value: '3', icon: AlertCircle, description: 'Requer atenção', color: 'text-rose-500' },
  ];

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-500">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Bem-vindo de volta!</h2>
        <p className="text-muted-foreground">Aqui está um resumo do que está acontecendo no sistema.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.title} className="hover:shadow-md transition-shadow">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{stat.title}</CardTitle>
              <stat.icon className={`h-4 w-4 ${stat.color}`} />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stat.value}</div>
              <p className="text-xs text-muted-foreground mt-1">
                {stat.description}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="col-span-1 md:col-span-2 lg:col-span-4 hover:shadow-md transition-shadow">
          <CardHeader>
            <CardTitle>Visão Geral de Vistorias</CardTitle>
            <CardDescription>
              Volume de vistorias processadas nos últimos 6 meses.
            </CardDescription>
          </CardHeader>
          <CardContent className="h-[300px] flex items-center justify-center border-2 border-dashed rounded-lg bg-slate-50/50 dark:bg-slate-900/50">
            <div className="text-center space-y-2">
              <TrendingUp className="w-8 h-8 text-muted-foreground mx-auto opacity-20" />
              <p className="text-sm text-muted-foreground">Gráfico de desempenho será exibido aqui.</p>
            </div>
          </CardContent>
        </Card>
        
        <Card className="col-span-1 md:col-span-2 lg:col-span-3 hover:shadow-md transition-shadow">
          <CardHeader>
            <CardTitle>Atividades Recentes</CardTitle>
            <CardDescription>
              Últimas ações realizadas no sistema.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {[1, 2, 3, 4, 5].map((i) => (
                <div key={i} className="flex items-center gap-4">
                  <div className="w-2 h-2 rounded-full bg-primary" />
                  <div className="flex-1 space-y-1">
                    <p className="text-sm font-medium leading-none">Novo usuário registrado</p>
                    <p className="text-xs text-muted-foreground">Há {i * 10} minutos</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default Dashboard;
