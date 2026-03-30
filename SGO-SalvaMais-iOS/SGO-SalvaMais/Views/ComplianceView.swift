import SwiftUI

// MARK: - Compliance View

struct ComplianceView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        if dashboardVM.complianceAlerts.isEmpty {
                            emptyState
                        } else {
                            SGOSectionHeader(
                                title: "Certificacoes a Expirar",
                                subtitle: "\(dashboardVM.complianceAlerts.count) alerta(s)",
                                color: .sgoRed
                            )

                            ForEach(dashboardVM.complianceAlerts) { user in
                                complianceCard(user)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Compliance RH")
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

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🛡️")
                .font(.system(size: 48))
            Text("Todas as certificacoes em dia")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.sgoGreen)
                .textCase(.uppercase)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    // MARK: - Compliance Card

    private func complianceCard(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.sgoTextPrimary)

                    Text(user.email)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.sgoTextMuted)
                }

                Spacer()

                daysRemainingBadge(user)
            }

            Divider()

            HStack(spacing: 16) {
                infoItem(label: "Certificado", value: user.certNumber ?? "N/A")
                infoItem(label: "Expira", value: user.certExpiryDate ?? "N/A")
            }

            if let phone = user.phone as String?, !phone.isEmpty {
                infoItem(label: "Contacto", value: phone)
            }
        }
        .padding(20)
        .sgoGlassCard(cornerRadius: 24)
    }

    // MARK: - Days Remaining Badge

    private func daysRemainingBadge(_ user: User) -> some View {
        let days = daysUntilExpiry(user.certExpiryDate)
        let color: Color = days <= 30 ? .sgoRed : .sgoOrange

        return Text("\(days)d")
            .font(.system(size: 11, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }

    private func daysUntilExpiry(_ dateStr: String?) -> Int {
        guard let dateStr = dateStr else { return 0 }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0)
    }

    // MARK: - Info Item

    private func infoItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.sgoTextMuted)
                .textCase(.uppercase)
                .tracking(1)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.sgoTextPrimary)
        }
    }
}
