import SwiftUI

// MARK: - Definições

struct DefinicoesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("autoRefresh") private var autoRefresh = true
    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Profile card
                        if let user = authVM.user {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Color.sgoRed.opacity(0.12))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(String(user.name.prefix(1)))
                                            .font(.system(size: 26, weight: .semibold))
                                            .foregroundColor(.sgoRed)
                                    )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.sgoTextPrimary)
                                    Text(user.email)
                                        .font(.system(size: 12))
                                        .foregroundColor(.sgoTextMuted)
                                    Text(user.role.displayName)
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.sgoRed.opacity(0.1))
                                        .foregroundColor(.sgoRed)
                                        .clipShape(Capsule())
                                }
                                Spacer()
                            }
                            .padding(16)
                            .sgoGlassCard(cornerRadius: 20)
                        }

                        // Notifications & display
                        settingsGroup("PREFERÊNCIAS") {
                            toggleRow(icon: "bell.fill", title: "Notificações Push", subtitle: "Receber alertas da app", value: $notificationsEnabled)
                            Divider().opacity(0.2)
                            toggleRow(icon: "arrow.clockwise", title: "Atualização Automática", subtitle: "Sincronizar ao abrir a app", value: $autoRefresh)
                        }

                        // App info
                        settingsGroup("INFORMAÇÃO") {
                            infoRow(icon: "info.circle", title: "Versão da App", value: "1.0.0")
                            Divider().opacity(0.2)
                            infoRow(icon: "server.rack", title: "API", value: "api.salvamais.pt")
                            Divider().opacity(0.2)
                            infoRow(icon: "network", title: "Ligação", value: authVM.isOnline ? "Online" : "Offline")
                        }

                        // Logout
                        Button {
                            showLogoutConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.sgoRed)
                                Text("Terminar Sessão")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.sgoRed)
                                Spacer()
                            }
                            .padding(16)
                            .sgoGlassCard(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                        .alert("Terminar Sessão", isPresented: $showLogoutConfirm) {
                            Button("Cancelar", role: .cancel) {}
                            Button("Sair", role: .destructive) {
                                authVM.logout()
                            }
                        } message: {
                            Text("Tens a certeza que queres sair da conta?")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Definições")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
    }

    @ViewBuilder
    private func settingsGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 9, weight: .black))
                .tracking(2)
                .foregroundColor(.sgoTextMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .sgoGlassCard(cornerRadius: 18)
        }
    }

    @ViewBuilder
    private func toggleRow(icon: String, title: String, subtitle: String, value: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.sgoRed)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.sgoTextPrimary)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.sgoTextMuted)
            }
            Spacer()
            Toggle("", isOn: value).labelsHidden().tint(.sgoRed)
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.sgoTextMuted)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.sgoTextPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.sgoTextMuted)
        }
        .padding(.vertical, 6)
    }
}
