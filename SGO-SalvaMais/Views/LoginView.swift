import SwiftUI

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var cardAppeared = false
    
    var body: some View {
        ZStack {
            // Amber background
            Color.sgoAmber.ignoresSafeArea()
            
            // Ambient glass blobs
            Circle()
                .fill(Color.sgoRed.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -250)
            
            Circle()
                .fill(Color.orange.opacity(0.06))
                .blur(radius: 80)
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 200)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer().frame(height: 60)
                    
                    // Logo
                    VStack(spacing: 4) {
                        Text("S+GO")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .tracking(-2)
                            .foregroundColor(.sgoBlack)
                        
                        Text("SALVA MAIS")
                            .font(.system(size: 11, weight: .black))
                            .tracking(6)
                            .foregroundColor(.sgoRed)
                    }
                    
                    // Login Card
                    VStack(spacing: 24) {
                        VStack(spacing: 6) {
                            Text("Bem-vindo")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.sgoTextPrimary)
                            
                            Text("ACESSO AO SISTEMA S+GO")
                                .font(.system(size: 9, weight: .black))
                                .tracking(4)
                                .foregroundColor(.sgoTextMuted)
                        }
                        
                        VStack(spacing: 14) {
                            // Email
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                
                                TextField("Email", text: $email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .sgoGlassField()
                            
                            // Password
                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                
                                SecureField("Palavra-passe", text: $password)
                                    .textContentType(.password)
                            }
                            .sgoGlassField()
                        }
                        
                        // Error
                        if let error = authVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12))
                                Text(error)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.sgoRed)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(Color.sgoRed.opacity(0.08))
                            )
                        }
                        
                        // Login Button
                        Button {
                            Task { await authVM.login(email: email, password: password) }
                        } label: {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Entrar")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .sgoGlassButton()
                        }
                        .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)
                        .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
                        
                        // Register link
                        Button {
                            showRegister = true
                        } label: {
                            Text("Criar Conta")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.sgoTextMuted)
                                .textCase(.uppercase)
                                .tracking(3)
                        }
                    }
                    .padding(32)
                    .sgoGlassCard(cornerRadius: 36)
                    .scaleEffect(cardAppeared ? 1 : 0.9)
                    .opacity(cardAppeared ? 1 : 0)
                    
                    // Footer
                    Text("© 2025 S+GO Salva Mais — Excelência em Vigilância Aquática")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.sgoTextMuted.opacity(0.5))
                        .textCase(.uppercase)
                        .tracking(3)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(authVM)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                cardAppeared = true
            }
        }
    }
}

// MARK: - Register View

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var selectedRole: Role = .nadadorSalvador
    @State private var isRegistering = false
    @State private var successMessage: String?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text("Novo Registo")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.sgoTextPrimary)
                            
                            Text("CRIAR CONTA S+GO")
                                .font(.system(size: 9, weight: .black))
                                .tracking(4)
                                .foregroundColor(.sgoTextMuted)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 14) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                TextField("Nome completo", text: $name)
                            }
                            .sgoGlassField()
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                TextField("Email", text: $email)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .sgoGlassField()
                            
                            HStack {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                TextField("Telefone", text: $phone)
                                    .keyboardType(.phonePad)
                            }
                            .sgoGlassField()
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                SecureField("Palavra-passe", text: $password)
                            }
                            .sgoGlassField()
                            
                            // Role picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("FUNÇÃO")
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(3)
                                    .foregroundColor(.sgoTextMuted)
                                
                                Picker("Função", selection: $selectedRole) {
                                    ForEach([Role.nadadorSalvador, .coordenador], id: \.self) { role in
                                        Text(role.displayName).tag(role)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.sgoRed)
                        }
                        
                        if let success = successMessage {
                            Text(success)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.sgoGreen)
                        }
                        
                        Button {
                            Task {
                                isRegistering = true
                                do {
                                    let _ = try await APIService.shared.register(userData: [
                                        "name": name, "email": email, "phone": phone,
                                        "password": password, "role": selectedRole.rawValue
                                    ])
                                    successMessage = "Conta criada! Pode fazer login."
                                    errorMessage = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { dismiss() }
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                                isRegistering = false
                            }
                        } label: {
                            HStack {
                                if isRegistering {
                                    ProgressView().tint(.white).scaleEffect(0.8)
                                } else {
                                    Text("Criar Conta")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .sgoGlassButton()
                        }
                        .disabled(name.isEmpty || email.isEmpty || password.isEmpty || isRegistering)
                    }
                    .padding(28)
                    .sgoGlassCard(cornerRadius: 36)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.sgoTextSecondary)
                }
            }
        }
    }
}
