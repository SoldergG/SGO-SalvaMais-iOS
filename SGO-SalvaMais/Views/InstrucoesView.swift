import SwiftUI

// MARK: - Instruções S+Go

struct InstrucoesView: View {
    @Environment(\.dismiss) var dismiss

    private let sections: [(String, String, [(String, String)])] = [
        ("📊", "Dashboard", [
            ("Estatísticas em tempo real", "Vê o número de postos ativos, profissionais e registos na tela principal."),
            ("Pull-to-refresh", "Arrasta para baixo para atualizar todos os dados do servidor."),
            ("Indicador de ligação", "O ponto verde/vermelho no topo mostra o estado da ligação à API."),
        ]),
        ("📝", "Relatórios ISN", [
            ("Registo de Salvamento", "Usa os botões ISN para submeter relatórios oficiais obrigatórios."),
            ("Ocorrências Internas", "Registos de posto: incidentes, prevenção, anomalias técnicas, etc."),
            ("Assinatura Digital", "Alguns relatórios requerem assinatura — usa o dedo no ecrã."),
        ]),
        ("🏢", "Serviços", [
            ("Lista de Postos", "No separador Serviços vês todos os postos que te estão atribuídos."),
            ("Detalhe do Posto", "Toca num posto para ver equipa, escalas e inventário."),
            ("Escalas", "Adiciona ou remove turnos diretamente no detalhe do posto."),
        ]),
        ("🛠️", "Ferramentas", [
            ("Mapa de Vigilância", "Visualiza a localização geográfica de todos os postos ativos."),
            ("Cronograma Ativo", "Timeline com início e fim de cada serviço da época."),
            ("Compliance RH", "Alertas de certificações a expirar — gestores devem verificar regularmente."),
        ]),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Header
                        VStack(spacing: 10) {
                            Text("📖")
                                .font(.system(size: 44))
                            Text("Instruções S+Go")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.sgoTextPrimary)
                            Text("Guia rápido de utilização da aplicação")
                                .font(.system(size: 12))
                                .foregroundColor(.sgoTextMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)

                        ForEach(sections, id: \.1) { sectionIcon, sectionTitle, items in
                            VStack(spacing: 0) {
                                HStack(spacing: 10) {
                                    Text(sectionIcon).font(.system(size: 20))
                                    Text(sectionTitle)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.sgoTextPrimary)
                                    Spacer()
                                }
                                .padding(.bottom, 12)

                                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                                    if idx > 0 { Divider().opacity(0.2) }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.0)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.sgoTextPrimary)
                                        Text(item.1)
                                            .font(.system(size: 11))
                                            .foregroundColor(.sgoTextMuted)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding(16)
                            .sgoGlassCard(cornerRadius: 20)
                        }

                        // Version / support
                        VStack(spacing: 6) {
                            Text("S+Go • Salva Mais")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.sgoTextMuted)
                            Text("Versão 1.0 • api.salvamais.pt")
                                .font(.system(size: 10))
                                .foregroundColor(.sgoTextMuted.opacity(0.7))
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .sgoGlassCard(cornerRadius: 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Instruções")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
    }
}
