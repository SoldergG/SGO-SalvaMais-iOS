import React, { useEffect, useState } from 'react';
import { supabase } from '../services/supabase';
import { UserProfile } from '../types';
import { Check, X, Shield, Users, Activity, Lock, Trash2, Plus } from 'lucide-react';

interface AdminDashboardProps {
  currentUser: UserProfile;
  onClose: () => void;
}

const AdminDashboard: React.FC<AdminDashboardProps> = ({ currentUser, onClose }) => {
  const [activeTab, setActiveTab] = useState<'users' | 'approvals' | 'teams'>('users');
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      setUsers(data as UserProfile[]);
    } catch (error) {
      console.error("Error fetching users:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleApproveUser = async (userId: string, approve: boolean) => {
    try {
      if (!approve) {
        // Technically just leave false or delete, let's keep false so they can't re-register
        await supabase.from('profiles').update({ is_approved: false }).eq('id', userId);
      } else {
        await supabase.from('profiles').update({ is_approved: true }).eq('id', userId);
      }
      fetchUsers();
    } catch (e) {
      console.error(e);
      alert("Erro ao atualizar status");
    }
  };

  const handleChangeRole = async (userId: string, newRole: string) => {
    if (currentUser.role !== 'super_admin') return alert("Apenas Admin+ pode mudar cargos.");
    try {
      await supabase.from('profiles').update({ role: newRole }).eq('id', userId);
      fetchUsers();
    } catch (e) {
      alert("Erro ao mudar cargo");
    }
  };

  const handleUpdateLimit = async (userId: string, newLimit: number) => {
     if (currentUser.role !== 'super_admin') return;
     try {
       await supabase.from('profiles').update({ max_usage_limit: newLimit }).eq('id', userId);
       fetchUsers();
     } catch (e) {
       console.error(e);
     }
  };

  const pendingUsers = users.filter(u => !u.is_approved);
  const approvedUsers = users.filter(u => u.is_approved);

  return (
    <div className="fixed inset-0 z-50 bg-gray-100 dark:bg-gray-950 flex flex-col animate-fade-in overflow-hidden">
      {/* Header */}
      <div className="bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 p-4 flex justify-between items-center shadow-sm">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 rounded-lg">
            <Shield size={24} />
          </div>
          <div>
            <h1 className="text-xl font-bold text-gray-900 dark:text-white">Painel Administrativo</h1>
            <p className="text-xs text-gray-500">
              Logado como: <span className="font-semibold text-indigo-500">{currentUser.email}</span> ({currentUser.role === 'super_admin' ? 'Admin+' : 'Admin'})
            </p>
          </div>
        </div>
        <button onClick={onClose} className="px-4 py-2 text-sm bg-gray-200 dark:bg-gray-800 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-700 transition-colors">
          Fechar
        </button>
      </div>

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar */}
        <div className="w-64 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-800 flex flex-col p-4 gap-2">
          <button 
            onClick={() => setActiveTab('users')}
            className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all ${activeTab === 'users' ? 'bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800'}`}
          >
            <Users size={18} /> Usuários Ativos
          </button>
          
          <button 
            onClick={() => setActiveTab('approvals')}
            className={`flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium transition-all ${activeTab === 'approvals' ? 'bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800'}`}
          >
            <div className="flex items-center gap-3">
              <Lock size={18} /> Aprovações
            </div>
            {pendingUsers.length > 0 && <span className="bg-red-500 text-white text-[10px] px-2 py-0.5 rounded-full">{pendingUsers.length}</span>}
          </button>

          {currentUser.role === 'super_admin' && (
            <button 
              onClick={() => setActiveTab('teams')}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all ${activeTab === 'teams' ? 'bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800'}`}
            >
              <Activity size={18} /> Equipes & Limites
            </button>
          )}
        </div>

        {/* Content */}
        <div className="flex-1 p-8 overflow-y-auto">
          {loading ? (
            <div className="flex items-center justify-center h-full text-gray-500">Carregando dados...</div>
          ) : (
            <>
              {/* USERS TAB */}
              {activeTab === 'users' && (
                <div className="space-y-6">
                  <h2 className="text-2xl font-bold">Gestão de Usuários</h2>
                  <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-800 overflow-hidden">
                    <table className="w-full text-sm text-left">
                      <thead className="bg-gray-50 dark:bg-gray-800/50 text-gray-500 uppercase text-xs">
                        <tr>
                          <th className="px-6 py-4">Usuário</th>
                          <th className="px-6 py-4">Cargo</th>
                          <th className="px-6 py-4">Uso (min)</th>
                          <th className="px-6 py-4 text-right">Ações</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
                        {approvedUsers.map(user => (
                          <tr key={user.id} className="hover:bg-gray-50 dark:hover:bg-gray-800/30">
                            <td className="px-6 py-4">
                              <div className="font-medium text-gray-900 dark:text-white">{user.email}</div>
                              <div className="text-xs text-gray-500">ID: {user.id.slice(0, 8)}...</div>
                            </td>
                            <td className="px-6 py-4">
                              {currentUser.role === 'super_admin' ? (
                                <select 
                                  value={user.role} 
                                  onChange={(e) => handleChangeRole(user.id, e.target.value)}
                                  className="bg-gray-100 dark:bg-gray-800 border-none rounded px-2 py-1 text-xs"
                                >
                                  <option value="free">Free</option>
                                  <option value="admin">Admin</option>
                                  <option value="super_admin">Admin+</option>
                                </select>
                              ) : (
                                <span className={`px-2 py-1 rounded text-xs ${user.role === 'super_admin' ? 'bg-purple-100 text-purple-600' : user.role === 'admin' ? 'bg-blue-100 text-blue-600' : 'bg-gray-100 text-gray-600'}`}>
                                  {user.role === 'super_admin' ? 'Admin+' : user.role === 'admin' ? 'Admin' : 'Free'}
                                </span>
                              )}
                            </td>
                            <td className="px-6 py-4">
                               <div className="flex items-center gap-2">
                                  <span>{user.usage_count} / {user.max_usage_limit}</span>
                                  {currentUser.role === 'super_admin' && (
                                    <button 
                                      onClick={() => {
                                        const val = prompt("Novo limite de uso (count):", user.max_usage_limit.toString());
                                        if (val) handleUpdateLimit(user.id, parseInt(val));
                                      }}
                                      className="p-1 hover:bg-gray-200 dark:hover:bg-gray-700 rounded"
                                    >
                                      <Activity size={12} />
                                    </button>
                                  )}
                               </div>
                               <div className="w-24 h-1.5 bg-gray-200 rounded-full mt-1 overflow-hidden">
                                 <div className="h-full bg-indigo-500" style={{ width: `${Math.min((user.usage_count / user.max_usage_limit) * 100, 100)}%` }}></div>
                               </div>
                            </td>
                            <td className="px-6 py-4 text-right">
                              {currentUser.role === 'super_admin' && user.email !== currentUser.email && (
                                <button onClick={() => handleApproveUser(user.id, false)} className="text-red-500 hover:text-red-700 text-xs font-medium">
                                  Revogar Acesso
                                </button>
                              )}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* APPROVALS TAB */}
              {activeTab === 'approvals' && (
                <div className="space-y-6">
                  <h2 className="text-2xl font-bold flex items-center gap-2">
                    Aprovações Pendentes <span className="text-base font-normal text-gray-500">({pendingUsers.length})</span>
                  </h2>
                  
                  {pendingUsers.length === 0 ? (
                    <div className="p-10 text-center bg-gray-50 dark:bg-gray-900 border border-dashed border-gray-200 dark:border-gray-800 rounded-xl">
                      <Check className="mx-auto text-emerald-500 mb-2" size={32} />
                      <p className="text-gray-500">Todos os usuários foram processados.</p>
                    </div>
                  ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                      {pendingUsers.map(user => (
                        <div key={user.id} className="bg-white dark:bg-gray-900 p-6 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm">
                          <div className="flex justify-between items-start mb-4">
                             <div>
                               <h3 className="font-bold">{user.email}</h3>
                               <p className="text-xs text-gray-500">Registrado em: {new Date(user.created_at).toLocaleDateString()}</p>
                             </div>
                             <span className="bg-yellow-100 text-yellow-700 text-[10px] px-2 py-1 rounded-full uppercase font-bold">Pendente</span>
                          </div>
                          <div className="flex gap-2 mt-4">
                            <button 
                              onClick={() => handleApproveUser(user.id, true)}
                              className="flex-1 bg-emerald-500 hover:bg-emerald-600 text-white py-2 rounded-lg text-sm font-medium transition-colors"
                            >
                              Aprovar
                            </button>
                            <button 
                              onClick={() => handleApproveUser(user.id, false)} // Actually deny effectively keeps them locked out
                              className="flex-1 bg-gray-100 dark:bg-gray-800 hover:bg-red-50 dark:hover:bg-red-900/20 text-gray-600 dark:text-gray-400 hover:text-red-600 transition-colors py-2 rounded-lg text-sm font-medium"
                            >
                              Ignorar
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* TEAMS TAB */}
              {activeTab === 'teams' && currentUser.role === 'super_admin' && (
                <div className="space-y-6">
                   <div className="flex justify-between items-center">
                    <h2 className="text-2xl font-bold">Equipes e Configurações Globais</h2>
                    <button className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-indigo-700">
                      <Plus size={16} /> Nova Equipe
                    </button>
                   </div>
                   
                   <div className="p-6 bg-indigo-50 dark:bg-indigo-900/10 rounded-xl border border-indigo-100 dark:border-indigo-500/20">
                     <h3 className="font-bold text-indigo-900 dark:text-indigo-200 mb-2">Painel Admin+ (Super Admin)</h3>
                     <p className="text-sm text-indigo-700 dark:text-indigo-300">
                       Como Admin+, você tem controle total. As equipes permitem agrupar usuários Free sob supervisão de um Admin.
                       (Funcionalidade de criação de equipes em desenvolvimento no frontend, mas ativa no banco de dados).
                     </p>
                   </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;
