import SwiftUI

// MARK: - Administração do Sistema

struct AdministracaoSistemaView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    enum Tab: String, CaseIterable {
        case smtp       = "SMTP"
        case automacoes = "AUTOMAÇÕES"
        case permissoes = "PERMISSÕES"
        case logsEmail  = "LOGS E-MAIL"
        case auditoria  = "AUDITORIA"
        case saude      = "SAÚDE"
        case backup     = "BACK-UP"
    }

    @State private var selectedTab: Tab = .smtp

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Tab bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(Tab.allCases, id: \.self) { tab in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                                } label: {
                                    Text(tab.rawValue)
                                        .font(.system(size: 11, weight: .black))
                                        .tracking(0.5)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 9)
                                        .background(
                                            Capsule()
                                                .fill(selectedTab == tab ? Color.sgoBlack : Color.white.opacity(0.5))
                                        )
                                        .foregroundColor(selectedTab == tab ? .white : .sgoTextSecondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .background(Color.sgoAmber)

                    // Content
                    ScrollView(.vertical, showsIndicators: false) {
                        Group {
                            switch selectedTab {
                            case .smtp:       SMTPTabView()
                            case .automacoes: AutomacoesTabView()
                            case .permissoes: PermissoesTabView()
                            case .logsEmail:  LogsEmailTabView()
                            case .auditoria:  AuditoriaTabView()
                            case .saude:      SaudeTabView()
                            case .backup:     BackupTabView()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Administração do Sistema")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
    }
}

// MARK: - SMTP Tab

private struct SMTPTabView: View {
    @State private var host = ""
    @State private var port = "465"
    @State private var user = ""
    @State private var pass = ""
    @State private var testRecipient = ""
    @State private var isLoading = false
    @State private var isTesting = false
    @State private var isOnline = false
    @State private var toast: String?
    @State private var toastSuccess = true

    var body: some View {
        VStack(spacing: 14) {
            // Header card
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MOTOR SMTP V6")
                            .font(.system(size: 13, weight: .black))
                            .tracking(1)
                        Text("Configuração de correio eletrónico")
                            .font(.system(size: 10))
                            .foregroundColor(.sgoTextMuted)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Circle().fill(isOnline ? Color.sgoGreen : Color.sgoRed).frame(width: 7, height: 7)
                        Text(isOnline ? "ONLINE" : "OFFLINE")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(isOnline ? .sgoGreen : .sgoRed)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill((isOnline ? Color.sgoGreen : Color.sgoRed).opacity(0.1)))
                }

                adminField(label: "HOST SMTP", placeholder: "smtp.hostinger.com", text: $host)
                adminField(label: "PORTA", placeholder: "465", text: $port, keyboard: .numberPad)
                adminField(label: "UTILIZADOR", placeholder: "noreply@salvamais.pt", text: $user, keyboard: .emailAddress)
                adminSecureField(label: "PASSWORD", placeholder: "••••••••••", text: $pass)

                // Test section
                VStack(alignment: .leading, spacing: 8) {
                    Text("TESTE DE LIGAÇÃO (SÍNCRONO)")
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.5)
                        .foregroundColor(.sgoTextMuted)
                    HStack(spacing: 10) {
                        HStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 13))
                                .foregroundColor(.sgoTextMuted)
                            TextField("E-mail de teste", text: $testRecipient)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(.system(size: 13))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))

                        Button {
                            Task { await runSMTPTest() }
                        } label: {
                            Group {
                                if isTesting { ProgressView().tint(.white).scaleEffect(0.8) }
                                else { Text("ENVIAR\nTESTE").font(.system(size: 10, weight: .black)).multilineTextAlignment(.center) }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.sgoBlack))
                        }
                        .disabled(testRecipient.isEmpty || isTesting)
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.sgoPurple.opacity(0.06)))

                if let toast {
                    Label(toast, systemImage: toastSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(toastSuccess ? .sgoGreen : .sgoRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task { await saveConfig() }
                } label: {
                    Group {
                        if isLoading { ProgressView().tint(.white).scaleEffect(0.8) }
                        else { Text("GUARDAR CONFIGURAÇÕES").font(.system(size: 12, weight: .black)).tracking(1) }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.sgoBlack))
                }
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 24)
        }
        .task { await loadConfig() }
    }

    private func loadConfig() async {
        isOnline = await APIService.shared.pingAPI()
        if let cfg = try? await APIService.shared.getConfig("app_config") {
            host = cfg["smtpHost"] as? String ?? ""
            port = cfg["smtpPort"] as? String ?? "465"
            user = cfg["smtpUser"] as? String ?? ""
            pass = cfg["smtpPass"] as? String ?? ""
        }
    }

    private func saveConfig() async {
        isLoading = true
        do {
            try await APIService.shared.saveConfig("app_config", value: [
                "smtpHost": host, "smtpPort": port, "smtpUser": user, "smtpPass": pass
            ])
            toast = "Configurações guardadas com sucesso."
            toastSuccess = true
        } catch {
            toast = error.localizedDescription
            toastSuccess = false
        }
        isLoading = false
    }

    private func runSMTPTest() async {
        isTesting = true
        do {
            let ok = try await APIService.shared.testSMTP(host: host, port: port, user: user, pass: pass, recipient: testRecipient)
            toast = ok ? "E-mail de teste enviado com sucesso!" : "Falha no envio do teste."
            toastSuccess = ok
        } catch {
            toast = error.localizedDescription
            toastSuccess = false
        }
        isTesting = false
    }

    @ViewBuilder
    private func adminField(label: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 9, weight: .black)).tracking(1.5).foregroundColor(.sgoTextMuted)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocapitalization(.none)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))
        }
    }

    @ViewBuilder
    private func adminSecureField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 9, weight: .black)).tracking(1.5).foregroundColor(.sgoTextMuted)
            SecureField(placeholder, text: text)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))
        }
    }
}

// MARK: - Automações Tab

private struct AutomacoesTabView: View {
    struct AutoEvent: Identifiable {
        let id: String
        let label: String
        var enabled: Bool
    }

    @State private var events: [AutoEvent] = [
        AutoEvent(id: "isn_report",           label: "Registo de Salvamento (ISN)",           enabled: true),
        AutoEvent(id: "internal_occurrence",  label: "Ocorrências Internas",                   enabled: true),
        AutoEvent(id: "user_credentials",     label: "Envio User e Password para Utilizador",  enabled: true),
        AutoEvent(id: "custom_report",        label: "Relatório à Medida",                     enabled: false),
        AutoEvent(id: "equipment_alert",      label: "Alerta de Material",                     enabled: true),
        AutoEvent(id: "client_activation",    label: "Ativação de Cliente",                    enabled: true),
    ]
    @State private var isSaving = false
    @State private var toast: String?

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MATRIZ DE").font(.system(size: 11, weight: .black)).tracking(1).foregroundColor(.sgoTextSecondary)
                        Text("AUTOMAÇÃO").font(.system(size: 18, weight: .black)).foregroundColor(.sgoRed)
                    }
                    Spacer()
                    Button {
                        Task { await saveAutomations() }
                    } label: {
                        Group {
                            if isSaving { ProgressView().tint(.white).scaleEffect(0.8) }
                            else { Text("GRAVAR\nREGRAS").font(.system(size: 9, weight: .black)).multilineTextAlignment(.center) }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.sgoBlack))
                    }
                }
                .padding(.bottom, 14)

                // Header row
                HStack {
                    Text("EVENTO OPERACIONAL")
                        .font(.system(size: 8, weight: .black))
                        .tracking(0.5)
                        .foregroundColor(.sgoTextMuted)
                    Spacer()
                    Text("ATIVO")
                        .font(.system(size: 8, weight: .black))
                        .tracking(0.5)
                        .foregroundColor(.sgoTextMuted)
                        .frame(width: 48, alignment: .center)
                    Text("RELATANT")
                        .font(.system(size: 8, weight: .black))
                        .tracking(0.5)
                        .foregroundColor(.sgoTextMuted)
                        .frame(width: 56, alignment: .center)
                }
                .padding(.bottom, 8)
                Divider().opacity(0.3)

                ForEach($events) { $event in
                    HStack {
                        Text(event.label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.sgoTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        // Ativo – always active indicator
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.sgoGreen)
                            .frame(width: 48)
                        // Relatant – user toggle
                        Toggle("", isOn: $event.enabled)
                            .labelsHidden()
                            .tint(.sgoRed)
                            .frame(width: 56)
                    }
                    .padding(.vertical, 10)
                    Divider().opacity(0.2)
                }

                if let toast {
                    Label(toast, systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.sgoGreen)
                        .padding(.top, 8)
                }
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 24)
        }
        .task { await loadAutomations() }
    }

    private func loadAutomations() async {
        guard let cfg = try? await APIService.shared.getConfig("automation_config") else { return }
        for i in events.indices {
            if let sub = cfg[events[i].id] as? [String: Any] {
                events[i].enabled = sub["enabled"] as? Bool ?? events[i].enabled
            }
        }
    }

    private func saveAutomations() async {
        isSaving = true
        var value: [String: Any] = [:]
        for event in events {
            value[event.id] = ["enabled": event.enabled]
        }
        _ = try? await APIService.shared.saveConfig("automation_config", value: value)
        toast = "Regras de automação guardadas."
        isSaving = false
    }
}

// MARK: - Permissões Tab

private struct PermissoesTabView: View {
    struct Module: Identifiable {
        let id = UUID()
        let label: String
        var adminEnabled: Bool
    }

    @State private var modules: [Module] = [
        Module(label: "Mapa de Vigilância",                            adminEnabled: true),
        Module(label: "Calendário Operacional",                        adminEnabled: true),
        Module(label: "Gestão de Inventário",                          adminEnabled: true),
        Module(label: "Compliance RH",                                 adminEnabled: true),
        Module(label: "Licença ISN Salva Mais",                        adminEnabled: true),
        Module(label: "Registo Ocorrências Salvamento",                 adminEnabled: true),
        Module(label: "Registo Outras Ocorrências",                     adminEnabled: true),
        Module(label: "Informação de Praias",                          adminEnabled: true),
        Module(label: "Gestão de Postos",                              adminEnabled: true),
        Module(label: "Todos os Postos em Operação",                   adminEnabled: true),
        Module(label: "Gestão de Utilizadores",                        adminEnabled: true),
        Module(label: "Gestão de Entidades",                           adminEnabled: true),
        Module(label: "Estatísticas Globais",                          adminEnabled: true),
        Module(label: "Configuração de Relatório à Medida",            adminEnabled: true),
        Module(label: "Histórico Relatórios ISN",                      adminEnabled: true),
        Module(label: "Histórico Relatórios Internos",                  adminEnabled: true),
        Module(label: "Escalas e Agenda",                              adminEnabled: true),
        Module(label: "Instruções S+GO",                               adminEnabled: true),
        Module(label: "Cronograma Ativo",                              adminEnabled: true),
        Module(label: "Avaliação de Serviço",                          adminEnabled: true),
        Module(label: "Adicionar Kits de Material e 1ª Socorros",      adminEnabled: true),
        Module(label: "Acesso ao Cartão Formação e Desenvolvimento",   adminEnabled: true),
        Module(label: "Criar Notificações para Utilizadores",          adminEnabled: true),
        Module(label: "Definições do Sistema",                         adminEnabled: true),
    ]
    @State private var isSaving = false
    @State private var toast: String?

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ZONAS DE").font(.system(size: 11, weight: .black)).tracking(1).foregroundColor(.sgoTextSecondary)
                        Text("ACESSO").font(.system(size: 18, weight: .black)).foregroundColor(.sgoRed)
                    }
                    Spacer()
                    Button {
                        Task { await savePermissions() }
                    } label: {
                        Group {
                            if isSaving { ProgressView().tint(.white).scaleEffect(0.8) }
                            else { Text("GRAVAR\nMATRIZ").font(.system(size: 9, weight: .black)).multilineTextAlignment(.center) }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.sgoBlack))
                    }
                }
                .padding(.bottom, 14)

                HStack {
                    Text("MÓDULO").font(.system(size: 8, weight: .black)).tracking(0.5).foregroundColor(.sgoTextMuted)
                    Spacer()
                    Text("ADMINISTRADOR").font(.system(size: 8, weight: .black)).tracking(0.5).foregroundColor(.sgoTextMuted).frame(width: 90, alignment: .center)
                }
                .padding(.bottom, 8)
                Divider().opacity(0.3)

                ForEach($modules) { $mod in
                    HStack {
                        Text(mod.label)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.sgoTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Toggle("", isOn: $mod.adminEnabled)
                            .labelsHidden()
                            .tint(.sgoRed)
                            .frame(width: 90)
                    }
                    .padding(.vertical, 8)
                    Divider().opacity(0.2)
                }

                if let toast {
                    Label(toast, systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.sgoGreen)
                        .padding(.top, 8)
                }
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 24)
        }
        .task { await loadPermissions() }
    }

    private func loadPermissions() async {
        guard let cfg = try? await APIService.shared.getConfig("permissions_config"),
              let matrix = cfg["admin"] as? [String: Bool] else { return }
        for i in modules.indices {
            let key = modules[i].label.lowercased().replacingOccurrences(of: " ", with: "_")
            if let val = matrix[key] { modules[i].adminEnabled = val }
        }
    }

    private func savePermissions() async {
        isSaving = true
        var matrix: [String: Bool] = [:]
        for mod in modules {
            let key = mod.label.lowercased().replacingOccurrences(of: " ", with: "_")
            matrix[key] = mod.adminEnabled
        }
        _ = try? await APIService.shared.saveConfig("permissions_config", value: ["admin": matrix])
        toast = "Matriz de acesso guardada."
        isSaving = false
    }
}

// MARK: - Logs E-Mail Tab

private struct LogsEmailTabView: View {
    @State private var logs: [EmailLog] = []
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 10) {
            if isLoading {
                ProgressView("A carregar logs...").tint(.sgoRed).padding()
            } else if logs.isEmpty {
                emptyState(icon: "envelope.badge.shield.half.filled", message: "Sem logs de e-mail")
            } else {
                ForEach(logs) { log in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(log.status == "Sucesso" ? Color.sgoGreen.opacity(0.12) : Color.sgoRed.opacity(0.12))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: log.status == "Sucesso" ? "envelope.fill" : "envelope.badge.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(log.status == "Sucesso" ? .sgoGreen : .sgoRed)
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(log.subject)
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                            Text(log.recipient)
                                .font(.system(size: 10))
                                .foregroundColor(.sgoTextMuted)
                                .lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(log.status)
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(log.status == "Sucesso" ? .sgoGreen : .sgoRed)
                            Text(shortDate(log.timestamp))
                                .font(.system(size: 9))
                                .foregroundColor(.sgoTextMuted)
                        }
                    }
                    .padding(12)
                    .sgoGlassCard(cornerRadius: 14)
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        logs = (try? await APIService.shared.getEmailLogs()) ?? []
        isLoading = false
    }

    private func shortDate(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        guard let d = f.date(from: iso) else { return iso.prefix(10).description }
        let out = DateFormatter(); out.dateFormat = "dd/MM HH:mm"
        return out.string(from: d)
    }
}

// MARK: - Auditoria Tab

private struct AuditoriaTabView: View {
    @State private var logs: [AccessLog] = []
    @State private var isLoading = false
    @State private var search = ""

    var filtered: [AccessLog] {
        guard !search.isEmpty else { return logs }
        return logs.filter {
            $0.userName.localizedCaseInsensitiveContains(search) ||
            $0.lastIp.contains(search)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AUDITORIA DE").font(.system(size: 11, weight: .black)).tracking(1).foregroundColor(.sgoTextSecondary)
                        Text("ACESSOS").font(.system(size: 18, weight: .black)).foregroundColor(.sgoRed)
                        Text("SUMÁRIO DE SESSÕES AGREGADAS POR UTILIZADOR").font(.system(size: 8, weight: .bold)).foregroundColor(.sgoTextMuted)
                    }
                    Spacer()
                    Button { Task { await load() } } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                            .foregroundColor(.sgoTextSecondary)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.6)))
                    }
                }
                .padding(.bottom, 12)

                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.sgoTextMuted)
                    TextField("Procurar utilizador ou IP...", text: $search)
                        .font(.system(size: 13))
                        .autocapitalization(.none)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemGray6)))
                .padding(.bottom, 12)

                if isLoading {
                    ProgressView().tint(.sgoRed).padding()
                } else if filtered.isEmpty {
                    emptyState(icon: "person.crop.circle.badge.questionmark", message: "Sem registos de auditoria")
                } else {
                    // Header
                    HStack {
                        Text("UTILIZADOR").font(.system(size: 8, weight: .black)).tracking(0.5).foregroundColor(.sgoTextMuted)
                        Spacer()
                        Text("PERFIL").font(.system(size: 8, weight: .black)).tracking(0.5).foregroundColor(.sgoTextMuted)
                    }
                    .padding(.bottom, 6)
                    Divider().opacity(0.3)

                    ForEach(filtered) { log in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color.sgoBlack)
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Text(String(log.userName.prefix(1)).uppercased())
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.userName)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.sgoTextPrimary)
                                Text("\(log.totalSessions) sessões · \(log.lastIp)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.sgoTextMuted)
                            }
                            Spacer()
                            Text(log.userRole)
                                .font(.system(size: 8, weight: .black))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.sgoRed.opacity(0.1)))
                                .foregroundColor(.sgoRed)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        Divider().opacity(0.2)
                    }
                }
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 24)
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        logs = (try? await APIService.shared.getAccessLogs()) ?? []
        isLoading = false
    }
}

// MARK: - Saúde Tab

private struct SaudeTabView: View {
    @State private var health: HealthStatus?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 14) {
                Text("SAÚDE DO SISTEMA")
                    .font(.system(size: 11, weight: .black))
                    .tracking(2)
                    .foregroundColor(.sgoRed)

                if isLoading {
                    ProgressView().tint(.sgoRed).frame(maxWidth: .infinity)
                } else if let h = health {
                    // Estado da infraestrutura
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ESTADO DA INFRAESTRUTURA")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(.sgoTextMuted)
                        healthRow(label: "Servidor API", value: h.status == "ok" ? "OPERACIONAL" : "ERRO", ok: h.status == "ok")
                        Divider().opacity(0.2)
                        healthRow(label: "Base de Dados", value: h.database.uppercased(), ok: h.database == "online")
                        Divider().opacity(0.2)
                        healthRow(label: "Ambiente", value: h.environment.uppercased(), ok: true)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(UIColor.systemGray6).opacity(0.7)))

                    // Endpoints
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ENDPOINTS ATUAIS")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(Color.white.opacity(0.5))
                        VStack(alignment: .leading, spacing: 6) {
                            Text("API ROOT URL")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(Color.white.opacity(0.4))
                            Text("https://api.salvamais.pt")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Divider().opacity(0.2)
                            Text("MODO DE OPERAÇÃO")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(Color.white.opacity(0.4))
                            Text(h.environment.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.sgoBlack))
                } else {
                    emptyState(icon: "server.rack", message: "Não foi possível obter o estado do sistema")
                }
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 24)
        }
        .task { await load() }
    }

    @ViewBuilder
    private func healthRow(label: String, value: String, ok: Bool) -> some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundColor(.sgoTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(ok ? .sgoGreen : .sgoRed)
        }
    }

    private func load() async {
        isLoading = true
        health = try? await APIService.shared.getHealth()
        isLoading = false
    }
}

// MARK: - Back-Up Tab

private struct BackupTabView: View {
    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("REGRAS DE").font(.system(size: 11, weight: .black)).tracking(1).foregroundColor(.sgoTextSecondary)
                        Text("BACK-UP").font(.system(size: 18, weight: .black)).foregroundColor(.sgoRed)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(Color.sgoGreen).frame(width: 7, height: 7)
                        Text("SISTEMA PROTEGIDO").font(.system(size: 8, weight: .black)).foregroundColor(.sgoGreen)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.sgoGreen.opacity(0.1)))
                }

                ForEach(backupCards, id: \.title) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.emoji).font(.system(size: 28))
                        Text(card.title).font(.system(size: 11, weight: .black)).tracking(0.5).foregroundColor(.sgoTextPrimary)
                        Text(card.description).font(.system(size: 11)).foregroundColor(.sgoTextSecondary).lineSpacing(3)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(UIColor.systemGray6).opacity(0.7)))
                }

                // Security protocols
                VStack(alignment: .leading, spacing: 10) {
                    Text("PROTOCOLOS DE SEGURANÇA IMPLEMENTADOS")
                        .font(.system(size: 9, weight: .black))
                        .tracking(0.5)
                        .foregroundColor(Color.sgoRed)

                    ForEach(securityProtocols, id: \.title) { proto in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(proto.title).font(.system(size: 10, weight: .black)).foregroundColor(.white)
                            Text(proto.description).font(.system(size: 10)).foregroundColor(Color.white.opacity(0.6)).lineSpacing(2)
                        }
                        Divider().opacity(0.2)
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.sgoBlack))
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 24)
        }
    }

    private var backupCards: [(emoji: String, title: String, description: String)] {[
        ("🔄", "FREQUÊNCIA DIÁRIA", "Back-ups à Base de Dados, automáticos realizados todos os dias de 60 em 60 minutos. Garante que nenhuma alteração diária seja perdida."),
        ("🗄️", "RETENÇÃO DE 30 DIAS", "Mantemos um histórico completo à Base de Dados durante 48 horas. Possibilidade de restauro ponto-a-ponto em caso de erro crítico."),
        ("☁️", "CLOUD OFF-SITE", "Não aplicável nesta fase de implementação."),
    ]}

    private var securityProtocols: [(title: String, description: String)] {[
        ("ENCRIPTAÇÃO AES-256", "Não aplicável nesta fase."),
        ("VERIFICAÇÃO DE INTEGRIDADE", "Não aplicável nesta fase."),
        ("RESTAURO RÁPIDO (< 15 MIN)", "Não aplicável nesta fase."),
        ("ACESSO RESTRITO", "O acesso aos volumes de back-up é limitado aos administradores de sistema com autenticação no telemóvel."),
    ]}
}

// MARK: - Helpers

@ViewBuilder
private func emptyState(icon: String, message: String) -> some View {
    VStack(spacing: 10) {
        Image(systemName: icon).font(.system(size: 32)).foregroundColor(.sgoTextMuted)
        Text(message).font(.system(size: 12)).foregroundColor(.sgoTextMuted).multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(30)
    .sgoGlassCard(cornerRadius: 18)
}
