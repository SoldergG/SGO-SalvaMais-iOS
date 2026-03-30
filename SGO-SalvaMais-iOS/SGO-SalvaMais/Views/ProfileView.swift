import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showLogoutConfirm = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Avatar + Name
                        profileHeader
                        
                        // Info Section
                        if let user = authVM.user {
                            infoSection(user)
                        }
                        
                        // Cert Section (NS only)
                        if let user = authVM.user, user.role == .nadadorSalvador {
                            certSection(user)
                        }
                        
                        // App Info
                        appInfoSection
                        
                        // Logout
                        Button {
                            showLogoutConfirm = true
                        } label: {
                            Text("Encerrar Sessão")
                                .frame(maxWidth: .infinity)
                                .sgoGlassButton()
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
            .alert("Encerrar Sessão?", isPresented: $showLogoutConfirm) {
                Button("Cancelar", role: .cancel) {}
                Button("Sair", role: .destructive) { authVM.logout() }
            } message: {
                Text("Será desconectado do sistema S+GO.")
            }
        }
    }
    
    // MARK: - Header
    
    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.sgoBlack)
                    .frame(width: 90, height: 90)
                
                Text(authVM.user?.name.prefix(1).uppercased() ?? "S")
                    .font(.system(size: 36, weight: .ultraLight))
                    .foregroundColor(.white)
            }
            
            Text(authVM.user?.name ?? "—")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.sgoTextPrimary)
            
            if let role = authVM.user?.role {
                HStack(spacing: 6) {
                    Image(systemName: role.icon)
                        .font(.system(size: 12))
                    Text(role.displayName)
                        .font(.system(size: 10, weight: .black))
                        .tracking(3)
                }
                .foregroundColor(.sgoRed)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(Color.sgoRed.opacity(0.08))
                )
            }
        }
    }
    
    // MARK: - Info Section
    
    private func infoSection(_ user: User) -> some View {
        VStack(spacing: 10) {
            SGOSectionHeader(title: "Informações Pessoais", subtitle: nil)
            
            VStack(spacing: 0) {
                ProfileRow(icon: "envelope.fill", label: "Email", value: user.email)
                Divider().padding(.leading, 50)
                ProfileRow(icon: "phone.fill", label: "Telefone", value: user.phone.isEmpty ? "—" : user.phone)
                if let nac = user.nacionalidade {
                    Divider().padding(.leading, 50)
                    ProfileRow(icon: "globe.europe.africa.fill", label: "Nacionalidade", value: nac)
                }
                if let nif = user.nif {
                    Divider().padding(.leading, 50)
                    ProfileRow(icon: "doc.text.fill", label: "NIF", value: nif)
                }
            }
            .padding(.vertical, 4)
            .sgoGlassCard(cornerRadius: 20)
        }
    }
    
    // MARK: - Cert Section
    
    private func certSection(_ user: User) -> some View {
        VStack(spacing: 10) {
            SGOSectionHeader(title: "Certificação ISN", subtitle: nil, color: user.isCertExpiringSoon ? .sgoRed : .sgoGreen)
            
            VStack(spacing: 0) {
                ProfileRow(icon: "checkmark.seal.fill", label: "N° Cartão", value: user.certNumber ?? "—")
                Divider().padding(.leading, 50)
                ProfileRow(icon: "calendar", label: "Emissão", value: user.certIssueDate ?? "—")
                Divider().padding(.leading, 50)
                ProfileRow(icon: "calendar.badge.exclamationmark", label: "Validade", value: user.certExpiryDate ?? "—")
            }
            .padding(.vertical, 4)
            .sgoGlassCard(cornerRadius: 20)
            
            if user.isCertExpiringSoon {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                    Text("Certificação a expirar em breve!")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.sgoRed)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.sgoRed.opacity(0.08))
                )
            }
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(spacing: 10) {
            SGOSectionHeader(title: "Aplicação", subtitle: nil, color: .sgoTextMuted)
            
            VStack(spacing: 0) {
                ProfileRow(icon: "app.badge.fill", label: "Versão", value: "1.0.0")
                Divider().padding(.leading, 50)
                ProfileRow(icon: "server.rack", label: "API", value: authVM.isOnline ? "Online" : "Offline")
                Divider().padding(.leading, 50)
                ProfileRow(icon: "shield.checkered", label: "Segurança", value: "Token Auth")
            }
            .padding(.vertical, 4)
            .sgoGlassCard(cornerRadius: 20)
        }
    }
}

// MARK: - Profile Row

struct ProfileRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.sgoRed)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.sgoRed.opacity(0.06))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 9, weight: .black))
                    .tracking(2)
                    .foregroundColor(.sgoTextMuted)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.sgoTextPrimary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
