import SwiftUI
import UserNotifications
import CoreLocation
import AVFoundation
import Photos

// MARK: - Definições

struct DefinicoesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var dashboardVM: DashboardViewModel

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("autoRefresh") private var autoRefresh = true
    @State private var showLogoutConfirm = false

    // Permission states
    @State private var notifStatus: UNAuthorizationStatus = .notDetermined
    @State private var locationStatus: CLAuthorizationStatus = .notDetermined
    @State private var cameraStatus: AVAuthorizationStatus = .notDetermined
    @State private var photoStatus: PHAuthorizationStatus = .notDetermined

    // Admin sheets
    @State private var showUtilizadores = false
    @State private var showEntidades = false
    @State private var showCompliance = false
    @State private var showEstatisticas = false

    private var pendingCount: Int {
        dashboardVM.users.filter { $0.isPending == true && $0.isArchived != true }.count
    }

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

                        // MARK: Admin Section
                        if authVM.isManager {
                            settingsGroup("ADMINISTRAÇÃO") {
                                adminRow(
                                    icon: "person.crop.circle.badge.clock.fill",
                                    title: "Utilizadores Pendentes",
                                    subtitle: pendingCount > 0 ? "\(pendingCount) aguardam aprovação" : "Nenhum pendente",
                                    badge: pendingCount > 0 ? "\(pendingCount)" : nil,
                                    color: .sgoOrange
                                ) { showUtilizadores = true }

                                Divider().opacity(0.2)

                                adminRow(
                                    icon: "person.3.fill",
                                    title: "Gestão de Utilizadores",
                                    subtitle: "\(dashboardVM.users.count) utilizadores registados",
                                    color: .sgoRed
                                ) { showUtilizadores = true }

                                if authVM.isHighLevel {
                                    Divider().opacity(0.2)

                                    adminRow(
                                        icon: "building.2.fill",
                                        title: "Entidades",
                                        subtitle: "Gerir entidades e clientes",
                                        color: .sgoPurple
                                    ) { showEntidades = true }

                                    Divider().opacity(0.2)

                                    adminRow(
                                        icon: "checkmark.shield.fill",
                                        title: "Compliance & Segurança",
                                        subtitle: "Verificação de conformidade",
                                        color: .sgoGreen
                                    ) { showCompliance = true }

                                    Divider().opacity(0.2)

                                    adminRow(
                                        icon: "chart.bar.fill",
                                        title: "Estatísticas Globais",
                                        subtitle: "Relatórios e métricas do sistema",
                                        color: .blue
                                    ) { showEstatisticas = true }
                                }
                            }
                        }

                        // MARK: Preferences
                        settingsGroup("PREFERÊNCIAS") {
                            toggleRow(icon: "bell.fill", title: "Notificações Push", subtitle: "Receber alertas da app", value: $notificationsEnabled)
                            Divider().opacity(0.2)
                            toggleRow(icon: "arrow.clockwise", title: "Atualização Automática", subtitle: "Sincronizar ao abrir a app", value: $autoRefresh)
                        }

                        // MARK: Permissions
                        settingsGroup("PERMISSÕES DA APP") {
                            permissionRow(
                                icon: "bell.badge.fill",
                                title: "Notificações",
                                granted: notifStatus == .authorized,
                                denied: notifStatus == .denied
                            )
                            Divider().opacity(0.2)
                            permissionRow(
                                icon: "camera.fill",
                                title: "Câmera",
                                granted: cameraStatus == .authorized,
                                denied: cameraStatus == .denied
                            )
                            Divider().opacity(0.2)
                            permissionRow(
                                icon: "photo.fill",
                                title: "Galeria de Fotos",
                                granted: photoStatus == .authorized || photoStatus == .limited,
                                denied: photoStatus == .denied
                            )
                            Divider().opacity(0.2)
                            permissionRow(
                                icon: "location.fill",
                                title: "Localização",
                                granted: locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways,
                                denied: locationStatus == .denied || locationStatus == .restricted
                            )
                        }

                        // MARK: App Info
                        settingsGroup("INFORMAÇÃO") {
                            infoRow(icon: "info.circle", title: "Versão da App", value: "1.0.0")
                            Divider().opacity(0.2)
                            infoRow(icon: "server.rack", title: "API", value: "api.salvamais.pt")
                            Divider().opacity(0.2)
                            infoRow(icon: "network", title: "Ligação", value: authVM.isOnline ? "Online" : "Offline")
                        }

                        // MARK: Logout
                        Button { showLogoutConfirm = true } label: {
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
                            Button("Sair", role: .destructive) { authVM.logout() }
                        } message: {
                            Text("Tens a certeza que queres sair da conta?")
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Definições")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
            .sheet(isPresented: $showUtilizadores) {
                UtilizadoresView()
                    .environmentObject(dashboardVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showEntidades) {
                EntidadesView()
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showCompliance) {
                ComplianceView()
                    .environmentObject(dashboardVM)
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showEstatisticas) {
                EstatisticasView()
                    .environmentObject(dashboardVM)
                    .environmentObject(authVM)
            }
        }
        .task { await loadPermissions() }
    }

    // MARK: - Load Permission States

    private func loadPermissions() async {
        let notifSettings = await UNUserNotificationCenter.current().notificationSettings()
        notifStatus = notifSettings.authorizationStatus
        locationStatus = CLLocationManager().authorizationStatus
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    // MARK: - Builders

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
    private func adminRow(icon: String, title: String, subtitle: String, badge: String? = nil, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.sgoTextPrimary)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.sgoTextMuted)
                }
                Spacer()
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(color))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.sgoTextMuted)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func permissionRow(icon: String, title: String, granted: Bool, denied: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(granted ? .sgoGreen : denied ? .sgoRed : .sgoTextMuted)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.sgoTextPrimary)
            Spacer()
            if granted {
                Label("Permitido", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.sgoGreen)
                    .labelStyle(.titleAndIcon)
            } else if denied {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Abrir Definições", systemImage: "xmark.circle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.sgoRed)
                        .labelStyle(.titleAndIcon)
                }
            } else {
                Text("Não pedido")
                    .font(.system(size: 11))
                    .foregroundColor(.sgoTextMuted)
            }
        }
        .padding(.vertical, 6)
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
