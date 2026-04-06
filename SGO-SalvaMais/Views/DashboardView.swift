import SwiftUI

// MARK: - Dashboard View

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @EnvironmentObject var servicosVM: ServicosViewModel
    @State private var showNotifications = false
    @State private var showReportSheet = false
    @State private var selectedReportType: ReportType?
    @State private var selectedISNReportType: ReportType?
    @State private var animateStats = false

    // Tool sheet states
    @State private var showGestaoPostos = false
    @State private var showEscalas = false
    @State private var showInventario = false
    @State private var showEstatisticas = false
    @State private var showCompliance = false
    @State private var showMapa = false
    @State private var showCronograma = false
    @State private var showFormacao = false
    @State private var showUtilizadores = false
    @State private var showEntidades = false
    @State private var showLicenca = false
    @State private var showInstrucoes = false
    @State private var showAvaliacao = false
    @State private var showDefinicoes = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                Circle()
                    .fill(Color.sgoRed.opacity(0.04))
                    .blur(radius: 80)
                    .frame(width: 250, height: 250)
                    .offset(x: -100, y: -200)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        if authVM.isManager || authVM.isCliente {
                            statsSection
                        }
                        if !authVM.isCliente {
                            isnReportsSection
                        }
                        if !authVM.isCliente {
                            internalSection
                        }
                        toolsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                    .padding(.top, 10)
                }
                .refreshable {
                    if let user = authVM.user {
                        await dashboardVM.fetchAll(for: user)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("S+GO")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.sgoBlack)
                        Text("SALVA MAIS")
                            .font(.system(size: 7, weight: .black))
                            .tracking(3)
                            .foregroundColor(.sgoRed)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(authVM.isOnline ? Color.sgoGreen : Color.sgoRed)
                            .frame(width: 6, height: 6)
                        Button {
                            showNotifications = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.sgoBlack)
                                if dashboardVM.unreadNotifications > 0 {
                                    Circle()
                                        .fill(Color.sgoRed)
                                        .frame(width: 14, height: 14)
                                        .overlay(
                                            Text("\(dashboardVM.unreadNotifications)")
                                                .font(.system(size: 8, weight: .black))
                                                .foregroundColor(.white)
                                        )
                                        .offset(x: 6, y: -6)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
                    .environmentObject(dashboardVM)
                    .environmentObject(authVM)
            }
            .sheet(item: $selectedReportType) { type in
                ReportFormView(reportType: type)
                    .environmentObject(authVM)
                    .environmentObject(dashboardVM)
            }
            .sheet(item: $selectedISNReportType) { type in
                ISNReportFormView(reportType: type)
                    .environmentObject(authVM)
                    .environmentObject(dashboardVM)
            }
            .sheet(isPresented: $showGestaoPostos) {
                ServicosListView()
                    .environmentObject(servicosVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showEscalas) {
                CalendarView()
                    .environmentObject(servicosVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showInventario) {
                InventoryOverviewView()
                    .environmentObject(servicosVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showEstatisticas) {
                EstatisticasView()
                    .environmentObject(dashboardVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showCompliance) {
                ComplianceView()
                    .environmentObject(dashboardVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showMapa) {
                MapaVigilanciaView()
                    .environmentObject(servicosVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showCronograma) {
                CronogramaView()
                    .environmentObject(servicosVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showFormacao) {
                FormacaoView()
            }
            .sheet(isPresented: $showUtilizadores) {
                UtilizadoresView()
                    .environmentObject(dashboardVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showEntidades) {
                EntidadesView()
            }
            .sheet(isPresented: $showLicenca) {
                LicencaISNView()
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showInstrucoes) {
                InstrucoesView()
            }
            .sheet(isPresented: $showAvaliacao) {
                AvaliacaoServicoView()
                    .environmentObject(dashboardVM)
            }
            .sheet(isPresented: $showDefinicoes) {
                DefinicoesView()
                    .environmentObject(authVM)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                    animateStats = true
                }
                Task { await authVM.checkConnection() }
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: 10) {
            Button {
                showGestaoPostos = true
            } label: {
                VStack(spacing: 8) {
                    Text("🏢")
                        .font(.system(size: 22))
                    Text("\(dashboardVM.activeServicos.count)")
                        .font(.system(size: 42, weight: .ultraLight))
                        .tracking(-2)
                        .foregroundColor(.white)
                    Text("Postos Ativos")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.sgoRed)
                        .textCase(.uppercase)
                        .tracking(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.sgoBlack)
                        .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
                )
            }
            .buttonStyle(.plain)
            .scaleEffect(animateStats ? 1 : 0.85)
            .opacity(animateStats ? 1 : 0)

            SGOStatCard(
                value: "\(authVM.isHighLevel ? dashboardVM.lifeguardCount : dashboardVM.activeServicos.flatMap { $0.lifeguardIds }.count)",
                label: "Profissionais",
                icon: "🛟",
                color: .sgoBlack
            )
            .scaleEffect(animateStats ? 1 : 0.85)
            .opacity(animateStats ? 1 : 0)

            SGOStatCard(
                value: "\(dashboardVM.reports.count)",
                label: "Total Registos",
                icon: "📊",
                color: .sgoBlack
            )
            .scaleEffect(animateStats ? 1 : 0.85)
            .opacity(animateStats ? 1 : 0)
        }
    }

    // MARK: - ISN Reports

    private var isnReportsSection: some View {
        VStack(spacing: 14) {
            SGOSectionHeader(title: "Registo de Salvamento", subtitle: "Submissão Oficial ISN")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(ReportType.isnTypes, id: \.self) { type in
                    Button {
                        selectedISNReportType = type
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(type.icon)
                                .font(.system(size: 28))
                            Text(type.displayName)
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.sgoTextPrimary)
                                .textCase(.uppercase)
                                .tracking(1)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Internal Section

    private var internalSection: some View {
        VStack(spacing: 14) {
            SGOSectionHeader(title: "Ocorrências Internas", subtitle: "Procedimentos de Posto", color: .sgoBlack)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(ReportType.internalTypes, id: \.self) { type in
                    Button {
                        selectedReportType = type
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(type.icon)
                                .font(.system(size: 28))
                            Text(type.displayName)
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.sgoTextPrimary)
                                .textCase(.uppercase)
                                .tracking(1)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Tools Section

    private var toolsSection: some View {
        VStack(spacing: 14) {
            SGOSectionHeader(title: "Ferramentas e Gestão", subtitle: nil, color: .sgoTextMuted)

            VStack(spacing: 10) {
                SGOToolCard(title: "Site Institucional", subtitle: "Portal Salva Mais", icon: "🌐") {
                    if let url = URL(string: "https://www.salvamais.pt") {
                        UIApplication.shared.open(url)
                    }
                }

                SGOToolCard(title: "Site ISN", subtitle: "Regras & Exames", icon: "🏖️") {
                    if let url = URL(string: "https://www.amn.pt/ISN") {
                        UIApplication.shared.open(url)
                    }
                }

                SGOToolCard(title: "Mapa de Vigilância", subtitle: "Localização dos Postos", icon: "🗺️") {
                    showMapa = true
                }

                SGOToolCard(title: "Cronograma Ativo", subtitle: "Timeline da Época", icon: "📅") {
                    showCronograma = true
                }

                SGOToolCard(title: "Escalas & Agenda", subtitle: "Planeamento Mensal", icon: "🗓️") {
                    showEscalas = true
                }

                SGOToolCard(title: "Estado Inventário", subtitle: "Equipamento Ativo", icon: "📦") {
                    showInventario = true
                }

                if authVM.isHighLevel || authVM.isCliente {
                    SGOToolCard(title: "Estatísticas Globais", subtitle: "Análise de Época", icon: "📊") {
                        showEstatisticas = true
                    }
                }

                if authVM.isManager {
                    SGOToolCard(
                        title: "Compliance RH",
                        subtitle: "Certificações",
                        icon: "🛡️",
                        statusLabel: dashboardVM.complianceAlerts.isEmpty ? "OK" : "\(dashboardVM.complianceAlerts.count) Alertas",
                        statusColor: dashboardVM.complianceAlerts.isEmpty ? .sgoGreen : .sgoRed
                    ) {
                        showCompliance = true
                    }
                }

                if authVM.isManager {
                    SGOToolCard(title: "Gestão de Postos", subtitle: "Unidades Salva+", icon: "🏢") {
                        showGestaoPostos = true
                    }
                }

                if authVM.isHighLevel {
                    SGOToolCard(title: "Utilizadores", subtitle: "Equipa Registada", icon: "👥") {
                        showUtilizadores = true
                    }

                    SGOToolCard(title: "Entidades — Clientes Ativos", subtitle: "Clientes e Parceiros", icon: "🏛️") {
                        showEntidades = true
                    }

                    SGOToolCard(title: "Avaliação do Serviço", subtitle: "Feedback dos Clientes", icon: "⭐") {
                        showAvaliacao = true
                    }
                }

                SGOToolCard(title: "Formação e Desenvolvimento", subtitle: "Recursos ISN", icon: "🎓") {
                    showFormacao = true
                }

                SGOToolCard(title: "Licença ISN", subtitle: "Cédula Profissional", icon: "🏅") {
                    showLicenca = true
                }

                SGOToolCard(title: "Instruções S+Go", subtitle: "Guia de Utilização", icon: "📖") {
                    showInstrucoes = true
                }

                SGOToolCard(title: "Definições", subtitle: "Configurações da App", icon: "⚙️") {
                    showDefinicoes = true
                }
            }
        }
    }
}

// MARK: - ReportType Identifiable conformance

extension ReportType: Identifiable {
    var id: String { rawValue }
}
