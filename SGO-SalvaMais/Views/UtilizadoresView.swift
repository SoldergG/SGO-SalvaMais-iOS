import SwiftUI

// MARK: - Utilizadores View

struct UtilizadoresView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var roleFilter: Role? = nil

    private var filtered: [User] {
        var users = dashboardVM.users
        if let r = roleFilter { users = users.filter { $0.role == r } }
        if !searchText.isEmpty {
            users = users.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        return users.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.sgoTextMuted)
                        TextField("Pesquisar utilizador...", text: $searchText)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    // Role filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterPill("Todos", nil)
                            ForEach(Role.allCases, id: \.self) { r in
                                filterPill(r.displayName, r)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    // Stats row
                    HStack(spacing: 0) {
                        statBadge("\(dashboardVM.users.count)", "Total")
                        statBadge("\(dashboardVM.users.filter { $0.role == .nadadorSalvador }.count)", "Salvadores")
                        statBadge("\(dashboardVM.complianceAlerts.count)", "Alertas")
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                    if filtered.isEmpty {
                        Spacer()
                        Text("Nenhum utilizador encontrado")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.sgoTextMuted)
                        Spacer()
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 8) {
                                ForEach(filtered) { user in
                                    userRow(user)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("Utilizadores")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
    }

    @ViewBuilder
    private func filterPill(_ label: String, _ role: Role?) -> some View {
        Button { roleFilter = role } label: {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(roleFilter == role ? Color.sgoRed : Color.white.opacity(0.7))
                .foregroundColor(roleFilter == role ? .white : .sgoTextPrimary)
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private func statBadge(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundColor(.sgoTextPrimary)
            Text(label)
                .font(.system(size: 8, weight: .black))
                .tracking(1)
                .foregroundColor(.sgoTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 3)
    }

    @ViewBuilder
    private func userRow(_ user: User) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(roleColor(user.role).opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(user.name.prefix(1)))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(roleColor(user.role))
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(user.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.sgoTextPrimary)
                Text(user.email)
                    .font(.system(size: 11))
                    .foregroundColor(.sgoTextMuted)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(user.role.displayName)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(roleColor(user.role).opacity(0.12))
                    .foregroundColor(roleColor(user.role))
                    .clipShape(Capsule())
                if user.isCertExpiringSoon {
                    Text("⚠️ Cert.")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.sgoRed)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .sgoGlassCard(cornerRadius: 16)
    }

    private func roleColor(_ role: Role) -> Color {
        switch role {
        case .nadadorSalvador: return .blue
        case .coordenador: return .sgoOrange
        case .administrador: return .sgoRed
        case .cliente: return .sgoPurple
        case .gestor: return .sgoGreen
        }
    }
}
