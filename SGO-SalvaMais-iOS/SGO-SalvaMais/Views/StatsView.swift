import SwiftUI

// MARK: - Stats View

struct StatsView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    private var isnReports: [Report] {
        dashboardVM.reports.filter { $0.type.isISN }
    }

    private var internalReports: [Report] {
        dashboardVM.reports.filter { !$0.type.isISN }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Overview Cards
                        overviewSection

                        // Reports by Type
                        reportsByTypeSection

                        // Services Status
                        servicesStatusSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Estatisticas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.sgoRed)
                }
            }
        }
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        VStack(spacing: 14) {
            SGOSectionHeader(title: "Resumo Geral", subtitle: "Epoca Atual")

            HStack(spacing: 10) {
                statCard(value: "\(dashboardVM.activeServicos.count)", label: "Postos Ativos", icon: "🏢")
                statCard(value: "\(dashboardVM.lifeguardCount)", label: "Profissionais", icon: "🛟")
                statCard(value: "\(dashboardVM.reports.count)", label: "Total Registos", icon: "📊")
            }
        }
    }

    // MARK: - Reports by Type

    private var reportsByTypeSection: some View {
        VStack(spacing: 14) {
            SGOSectionHeader(title: "Registos por Tipo", subtitle: nil, color: .sgoBlack)

            VStack(spacing: 8) {
                reportTypeRow(label: "Relatorios ISN", count: isnReports.count, color: .sgoRed)
                reportTypeRow(label: "Ocorrencias Internas", count: internalReports.count, color: .sgoBlack)

                Divider().padding(.vertical, 4)

                ForEach(ReportType.allCases, id: \.self) { type in
                    let count = dashboardVM.reports.filter { $0.type == type }.count
                    if count > 0 {
                        reportTypeRow(label: "\(type.icon) \(type.displayName)", count: count, color: .sgoTextMuted)
                    }
                }
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 24)
        }
    }

    // MARK: - Services Status

    private var servicesStatusSection: some View {
        VStack(spacing: 14) {
            SGOSectionHeader(title: "Estado dos Servicos", subtitle: nil, color: .sgoTextMuted)

            VStack(spacing: 8) {
                let active = dashboardVM.servicos.filter { $0.status == .ativo }.count
                let inactive = dashboardVM.servicos.filter { $0.status == .inativo }.count
                let completed = dashboardVM.servicos.filter { $0.status == .concluido }.count

                reportTypeRow(label: "Ativos", count: active, color: .sgoGreen)
                reportTypeRow(label: "Inativos", count: inactive, color: .sgoOrange)
                reportTypeRow(label: "Concluidos", count: completed, color: .sgoTextMuted)
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 24)
        }
    }

    // MARK: - Helpers

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 22))
            Text(value)
                .font(.system(size: 32, weight: .ultraLight))
                .tracking(-1)
                .foregroundColor(.sgoTextPrimary)
            Text(label)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.sgoRed)
                .textCase(.uppercase)
                .tracking(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .sgoGlassCard(cornerRadius: 24)
    }

    private func reportTypeRow(label: String, count: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.sgoTextPrimary)
            Spacer()
            Text("\(count)")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(color)
        }
    }
}
