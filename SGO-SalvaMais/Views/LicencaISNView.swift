import SwiftUI

// MARK: - Licença ISN

struct LicencaISNView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Header
                        VStack(spacing: 10) {
                            Text("🏅")
                                .font(.system(size: 44))
                            Text("Licença ISN")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.sgoTextPrimary)
                            Text("Instituto de Socorros a Náufragos")
                                .font(.system(size: 12))
                                .foregroundColor(.sgoTextMuted)
                        }
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)

                        // User cert info
                        if let user = authVM.user {
                            VStack(spacing: 0) {
                                Text("CÉDULA PROFISSIONAL")
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(2)
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 12)

                                infoRow(icon: "person.fill", label: "Nome", value: user.name)
                                Divider().opacity(0.2)
                                infoRow(icon: "number", label: "Nº Cédula", value: user.certNumber ?? "—")
                                Divider().opacity(0.2)
                                infoRow(icon: "calendar", label: "Emissão", value: user.certIssueDate ?? "—")
                                Divider().opacity(0.2)
                                infoRow(icon: "calendar.badge.exclamationmark", label: "Validade", value: user.certExpiryDate ?? "—")
                            }
                            .padding(16)
                            .sgoGlassCard(cornerRadius: 20)

                            if user.isCertExpiringSoon {
                                HStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.sgoRed)
                                    Text("Cédula a expirar brevemente — renove em breve")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.sgoRed)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.sgoRed.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }

                        // ISN links
                        Text("LINKS ÚTEIS")
                            .font(.system(size: 9, weight: .black))
                            .tracking(2)
                            .foregroundColor(.sgoTextMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)

                        linkRow(icon: "🏛️", title: "Portal ISN — AMN", subtitle: "Renovação e exames", url: "https://www.amn.pt/ISN")
                        linkRow(icon: "📋", title: "Regulamento Nadadores-Salvadores", subtitle: "Decreto-Lei e normas", url: "https://www.amn.pt/ISN")
                        linkRow(icon: "✉️", title: "Contacto ISN", subtitle: "isn@amn.pt", url: "mailto:isn@amn.pt")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Licença ISN")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
    }

    @ViewBuilder
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.sgoTextMuted)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.sgoTextMuted)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.sgoTextPrimary)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func linkRow(icon: String, title: String, subtitle: String, url: String) -> some View {
        Button {
            if let u = URL(string: url) { UIApplication.shared.open(u) }
        } label: {
            HStack(spacing: 14) {
                Text(icon).font(.system(size: 24))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.sgoTextPrimary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.sgoTextMuted)
                }
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 13))
                    .foregroundColor(.sgoRed)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .sgoGlassCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}
