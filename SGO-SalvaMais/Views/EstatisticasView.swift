import SwiftUI

// MARK: - Estatísticas Globais View

struct EstatisticasView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    private var reportsByType: [(String, Int)] {
        var counts: [String: Int] = [:]
        for report in dashboardVM.reports {
            let key = report.type.displayName
            counts[key, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Top stats grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            statCard(value: "\(dashboardVM.servicos.count)", label: "Total Postos", icon: "🏢")
                            statCard(value: "\(dashboardVM.activeServicos.count)", label: "Postos Ativos", icon: "✅")
                            statCard(value: "\(dashboardVM.lifeguardCount)", label: "Nadadores Salvadores", icon: "🛟")
                            statCard(value: "\(dashboardVM.reports.count)", label: "Total Relatórios", icon: "📋")
                        }

                        // Compliance alert banner
                        if !dashboardVM.complianceAlerts.isEmpty {
                            HStack(spacing: 10) {
                                Text("🛡️").font(.system(size: 18))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("ALERTAS DE COMPLIANCE")
                                        .font(.system(size: 9, weight: .black))
                                        .tracking(1.5)
                                        .foregroundColor(.sgoRed)
                                    Text("\(dashboardVM.complianceAlerts.count) certificação(ões) a expirar")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.sgoTextPrimary)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.sgoRed.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.sgoRed.opacity(0.25), lineWidth: 1)
                                    )
                            )
                        }

                        // Reports by type
                        if !reportsByType.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("RELATÓRIOS POR TIPO")
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(2)
                                    .foregroundColor(.sgoTextMuted)

                                VStack(spacing: 8) {
                                    ForEach(reportsByType, id: \.0) { typeName, count in
                                        HStack {
                                            Text(typeName)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(.sgoTextPrimary)
                                            Spacer()
                                            Text("\(count)")
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundColor(.sgoRed)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .sgoGlassCard(cornerRadius: 16)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Estatísticas Globais")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }
                        .foregroundColor(.sgoRed)
                }
            }
        }
    }

    @ViewBuilder
    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Text(icon).font(.system(size: 26))
            Text(value)
                .font(.system(size: 34, weight: .ultraLight))
                .tracking(-1)
                .foregroundColor(.sgoTextPrimary)
            Text(label)
                .font(.system(size: 9, weight: .black))
                .tracking(1)
                .foregroundColor(.sgoTextMuted)
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .sgoGlassCard(cornerRadius: 24)
    }
}
