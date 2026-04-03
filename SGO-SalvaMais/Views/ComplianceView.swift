import SwiftUI

// MARK: - Compliance RH View

struct ComplianceView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                if dashboardVM.complianceAlerts.isEmpty {
                    VStack(spacing: 16) {
                        Text("✅")
                            .font(.system(size: 52))
                        Text("Compliance em Dia")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.sgoTextPrimary)
                        Text("Todas as certificações estão válidas")
                            .font(.system(size: 12))
                            .foregroundColor(.sgoTextMuted)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 14) {
                            // Alert banner
                            HStack(spacing: 10) {
                                Text("⚠️").font(.system(size: 18))
                                Text("\(dashboardVM.complianceAlerts.count) certificação(ões) a expirar em breve")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.sgoRed)
                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.sgoRed.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.sgoRed.opacity(0.2), lineWidth: 1)
                                    )
                            )

                            // User list
                            ForEach(dashboardVM.complianceAlerts) { user in
                                HStack(spacing: 14) {
                                    Circle()
                                        .fill(Color.sgoRed.opacity(0.1))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Text("🛡️").font(.system(size: 22))
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.name)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.sgoTextPrimary)
                                        if let expiry = user.certExpiryDate, !expiry.isEmpty {
                                            Text("Validade: \(expiry)")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.sgoRed)
                                        }
                                        Text(user.role.displayName)
                                            .font(.system(size: 10))
                                            .foregroundColor(.sgoTextMuted)
                                    }
                                    Spacer()

                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.sgoRed)
                                        .font(.system(size: 16))
                                }
                                .padding(16)
                                .sgoGlassCard(cornerRadius: 20)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Compliance RH")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }
                        .foregroundColor(.sgoRed)
                }
            }
        }
    }
}
