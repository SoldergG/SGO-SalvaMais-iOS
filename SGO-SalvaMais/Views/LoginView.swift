import SwiftUI
import AVFoundation

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var cardAppeared = false

    var body: some View {
        ZStack {
            Color.sgoAmber.ignoresSafeArea()

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
                VStack(spacing: 28) {
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
                            .background(Capsule().fill(Color.sgoRed.opacity(0.08)))
                        }

                        Button {
                            Task { await authVM.login(email: email, password: password) }
                        } label: {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView().tint(.white).scaleEffect(0.8)
                                } else {
                                    Text("Entrar")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .sgoGlassButton()
                        }
                        .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)
                        .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
                    }
                    .padding(32)
                    .sgoGlassCard(cornerRadius: 36)
                    .scaleEffect(cardAppeared ? 1 : 0.9)
                    .opacity(cardAppeared ? 1 : 0)

                    // NOVO NADADOR-SALVADOR? CTA
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("NOVO NADADOR-SALVADOR?")
                                .font(.system(size: 13, weight: .black))
                                .tracking(1.5)
                                .foregroundColor(.sgoAmber)

                            Text("Se ainda não tem acesso, crie o seu registo para ativação pela coordenação.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }

                        Button {
                            showRegister = true
                        } label: {
                            Text("REGISTE-SE AQUI")
                                .font(.system(size: 12, weight: .black))
                                .tracking(2)
                                .foregroundColor(.sgoBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(Color.white))
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.sgoBlack)
                            .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
                    )

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

// MARK: - Register View (Nadador Salvador)

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    // Section 1 – Identificação Pessoal
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // Section 2 – Dados Pessoais
    @State private var dataNascimento = ""
    @State private var sexo = "Masculino"
    @State private var morada = ""
    @State private var nif = ""

    // Section 3 – Credenciais ISN
    @State private var certNumber = ""
    @State private var certIssueDate = ""
    @State private var certExpiryDate = ""
    @State private var certFrontImage: UIImage?
    @State private var certBackImage: UIImage?
    @State private var certPhotoUrl: String?
    @State private var certPhotoBackUrl: String?
    @State private var isUploadingFront = false
    @State private var isUploadingBack = false

    // Privacy
    @State private var privacyAccepted = false
    @State private var showPrivacyPolicy = false

    // State
    @State private var isRegistering = false
    @State private var successMessage: String?
    @State private var errorMessage: String?

    private let sexoOptions = ["Masculino", "Feminino", "Outro"]

    private var passwordsMatch: Bool { password == confirmPassword }

    private var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty &&
        password.count >= 8 && passwordsMatch && privacyAccepted && !isRegistering &&
        !dataNascimento.isEmpty && !morada.isEmpty && !nif.isEmpty &&
        !certNumber.isEmpty && !certIssueDate.isEmpty && !certExpiryDate.isEmpty &&
        certPhotoUrl != nil && certPhotoBackUrl != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                Circle()
                    .fill(Color.sgoRed.opacity(0.06))
                    .blur(radius: 80)
                    .frame(width: 350, height: 350)
                    .offset(x: 120, y: -180)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Header
                        VStack(spacing: 6) {
                            Text("REGISTO")
                                .font(.system(size: 10, weight: .black))
                                .tracking(5)
                                .foregroundColor(.sgoTextMuted)

                            Text("Nadador-Salvador")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.sgoRed)

                            Text("DADOS OFICIAIS PARA ATIVAÇÃO DE ACESSO")
                                .font(.system(size: 8, weight: .black))
                                .tracking(2.5)
                                .foregroundColor(.sgoTextMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 8)

                        // SECTION 1 – Identificação Pessoal
                        VStack(alignment: .leading, spacing: 14) {
                            SGOSectionHeader(title: "1. Identificação Pessoal", color: .sgoRed)

                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                TextField("Nome completo (conf. Cartão de Cidadão)", text: $name)
                            }
                            .sgoGlassField()

                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                TextField("E-mail profissional", text: $email)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                            }
                            .sgoGlassField()

                            // Telemóvel com prefixo PT
                            HStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Text("🇵🇹")
                                        .font(.system(size: 15))
                                    Text("+351")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.sgoTextSecondary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(UIColor.systemGray6).opacity(0.6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray.opacity(0.15), lineWidth: 1.5)
                                        )
                                )

                                HStack {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.sgoTextMuted)
                                        .frame(width: 20)
                                    TextField("9 dígitos", text: $phone)
                                        .keyboardType(.phonePad)
                                }
                                .sgoGlassField()
                            }

                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                SecureField("Password (mín. 8 caracteres)", text: $password)
                                    .textContentType(.newPassword)
                            }
                            .sgoGlassField()

                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                SecureField("Confirmar password", text: $confirmPassword)
                                    .textContentType(.newPassword)
                            }
                            .sgoGlassField()
                            .overlay(
                                !confirmPassword.isEmpty && !passwordsMatch
                                ? RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.sgoRed.opacity(0.5), lineWidth: 1.5)
                                : nil
                            )

                            if !confirmPassword.isEmpty && !passwordsMatch {
                                Label("As passwords não coincidem", systemImage: "exclamationmark.triangle.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.sgoRed)
                            }
                        }
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)

                        // SECTION 2 – Dados Pessoais
                        VStack(alignment: .leading, spacing: 14) {
                            SGOSectionHeader(title: "2. Dados Pessoais", color: .sgoOrange)

                            HStack(spacing: 10) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14))
                                        .foregroundColor(.sgoTextMuted)
                                        .frame(width: 20)
                                    TextField("Nasc. (dd/mm/aaaa)", text: $dataNascimento)
                                        .keyboardType(.numbersAndPunctuation)
                                }
                                .sgoGlassField()

                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.sgoTextMuted)
                                    Picker("Sexo", selection: $sexo) {
                                        ForEach(sexoOptions, id: \.self) { Text($0) }
                                    }
                                    .pickerStyle(.menu)
                                    .font(.system(size: 13, weight: .bold))
                                    .tint(.sgoTextPrimary)
                                }
                                .sgoGlassField()
                            }

                            HStack {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                TextField("Morada para contrato", text: $morada)
                            }
                            .sgoGlassField()

                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                TextField("NIF", text: $nif)
                                    .keyboardType(.numberPad)
                            }
                            .sgoGlassField()
                        }
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)

                        // SECTION 3 – Credenciais ISN
                        VStack(alignment: .leading, spacing: 14) {
                            SGOSectionHeader(title: "3. Credenciais ISN", color: .blue)

                            HStack {
                                Image(systemName: "doc.badge.checkmark")
                                    .font(.system(size: 14))
                                    .foregroundColor(.sgoTextMuted)
                                    .frame(width: 20)
                                TextField("N.° Cartão ISN", text: $certNumber)
                            }
                            .sgoGlassField()

                            HStack(spacing: 10) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 13))
                                        .foregroundColor(.sgoTextMuted)
                                        .frame(width: 20)
                                    TextField("Emissão (dd/mm/aaaa)", text: $certIssueDate)
                                        .keyboardType(.numbersAndPunctuation)
                                }
                                .sgoGlassField()

                                HStack {
                                    Image(systemName: "calendar.badge.exclamationmark")
                                        .font(.system(size: 13))
                                        .foregroundColor(.sgoTextMuted)
                                        .frame(width: 20)
                                    TextField("Validade (dd/mm/aaaa)", text: $certExpiryDate)
                                        .keyboardType(.numbersAndPunctuation)
                                }
                                .sgoGlassField()
                            }

                            // Fotos do Cartão ISN
                            VStack(alignment: .leading, spacing: 8) {
                                Text("FOTO / PDF DO CARTÃO ISN")
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(2)
                                    .foregroundColor(.sgoTextMuted)

                                HStack(spacing: 10) {
                                    CardPhotoButton(
                                        label: "FRENTE DO CARTÃO",
                                        image: $certFrontImage,
                                        isUploading: $isUploadingFront
                                    ) { image in
                                        await uploadCardPhoto(image: image, isFront: true)
                                    }

                                    CardPhotoButton(
                                        label: "VERSO DO CARTÃO",
                                        image: $certBackImage,
                                        isUploading: $isUploadingBack
                                    ) { image in
                                        await uploadCardPhoto(image: image, isFront: false)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)

                        // POLÍTICA DE PRIVACIDADE
                        VStack(alignment: .leading, spacing: 14) {
                            SGOSectionHeader(title: "Política de Privacidade", color: .sgoPurple)

                            Button {
                                privacyAccepted.toggle()
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: privacyAccepted ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 22))
                                        .foregroundColor(privacyAccepted ? .sgoPurple : .sgoTextMuted)
                                        .animation(.spring(response: 0.3), value: privacyAccepted)

                                    (
                                        Text("Conheço e aceito a ")
                                            .foregroundColor(.sgoTextSecondary)
                                        + Text("Política de Privacidade")
                                            .foregroundColor(.sgoPurple)
                                            .fontWeight(.bold)
                                        + Text(" e o tratamento dos meus dados pessoais para fins de gestão de nadadores-salvadores.")
                                            .foregroundColor(.sgoTextSecondary)
                                    )
                                    .font(.system(size: 12))
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .buttonStyle(.plain)

                            Button {
                                showPrivacyPolicy = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 11))
                                    Text("LER POLÍTICA DE PRIVACIDADE")
                                        .font(.system(size: 10, weight: .black))
                                        .tracking(1.5)
                                }
                                .foregroundColor(.sgoPurple)
                                .underline()
                            }
                        }
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)

                        // Mensagens de erro / sucesso
                        if let error = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 13))
                                Text(error)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.sgoRed)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.sgoRed.opacity(0.08)))
                        }

                        if let success = successMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 13))
                                Text(success)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.sgoGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.sgoGreen.opacity(0.08)))
                        }

                        // Botão Submeter
                        Button {
                            Task { await submitRegistration() }
                        } label: {
                            HStack(spacing: 8) {
                                if isRegistering {
                                    ProgressView().tint(.white).scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Submeter Registo")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .sgoGlassButton()
                        }
                        .disabled(!canSubmit)
                        .opacity(canSubmit ? 1 : 0.45)

                        Button {
                            dismiss()
                        } label: {
                            Text("CANCELAR E VOLTAR")
                                .font(.system(size: 10, weight: .black))
                                .tracking(2.5)
                                .foregroundColor(.sgoTextMuted)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }

    // MARK: - Upload Foto Cartão

    private func uploadCardPhoto(image: UIImage, isFront: Bool) async {
        guard let jpeg = image.jpegData(compressionQuality: 0.6) else { return }
        let filename = isFront ? "cert_front.jpg" : "cert_back.jpg"
        do {
            let url = try await APIService.shared.uploadPhoto(imageData: jpeg, filename: filename)
            if isFront { certPhotoUrl = url } else { certPhotoBackUrl = url }
        } catch {
            errorMessage = "Erro ao carregar foto: \(error.localizedDescription)"
        }
    }

    // MARK: - Submeter Registo

    private func submitRegistration() async {
        isRegistering = true
        errorMessage = nil

        var userData: [String: Any] = [
            "name": name,
            "email": email,
            "phone": phone,
            "password": password,
            "role": Role.nadadorSalvador.rawValue,
            "privacyPolicyAccepted": true,
            "privacyPolicyAcceptedAt": ISO8601DateFormatter().string(from: Date())
        ]

        if !dataNascimento.isEmpty { userData["dataNascimento"] = dataNascimento }
        if !sexo.isEmpty            { userData["sexo"] = sexo }
        if !morada.isEmpty          { userData["morada"] = morada }
        if !nif.isEmpty             { userData["nif"] = nif }
        if !certNumber.isEmpty      { userData["certNumber"] = certNumber }
        if !certIssueDate.isEmpty   { userData["certIssueDate"] = certIssueDate }
        if !certExpiryDate.isEmpty  { userData["certExpiryDate"] = certExpiryDate }
        if let url = certPhotoUrl   { userData["certPhotoUrl"] = url }
        if let url = certPhotoBackUrl { userData["certPhotoBackUrl"] = url }

        do {
            let _ = try await APIService.shared.register(userData: userData)
            successMessage = "Registo submetido! A coordenação irá ativar a sua conta."
            errorMessage = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }

        isRegistering = false
    }
}

// MARK: - Card Photo Button

struct CardPhotoButton: View {
    let label: String
    @Binding var image: UIImage?
    @Binding var isUploading: Bool
    let onSelected: (UIImage) async -> Void

    @State private var showCamera = false
    @State private var showCameraPermissionAlert = false

    var body: some View {
        Button { requestCameraAccess() } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        image != nil ? Color.blue.opacity(0.4) : Color.gray.opacity(0.3),
                        style: StrokeStyle(lineWidth: 1.5, dash: image != nil ? [] : [6])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(image != nil ? Color.blue.opacity(0.05) : Color(UIColor.systemGray6).opacity(0.4))
                    )

                if isUploading {
                    VStack(spacing: 6) {
                        ProgressView().tint(.blue)
                        Text("A carregar...")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.sgoTextMuted)
                    }
                } else if let img = image {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.sgoGreen)
                            .padding(6)
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.sgoTextMuted)
                        Text(label)
                            .font(.system(size: 8, weight: .black))
                            .tracking(1)
                            .foregroundColor(.sgoTextMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
        }
        .buttonStyle(.plain)
        // Câmera
        .sheet(isPresented: $showCamera) {
            CameraPickerRepresentable { handle($0) }
                .ignoresSafeArea()
        }
        // Permissão de câmera negada
        .alert("Acesso à Câmera Bloqueado", isPresented: $showCameraPermissionAlert) {
            Button("Abrir Definições") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Para tirar fotos do cartão ISN, permite o acesso à câmera nas Definições do iPhone.")
        }
    }

    private func handle(_ selected: UIImage) {
        image = selected
        isUploading = true
        Task {
            await onSelected(selected)
            isUploading = false
        }
    }

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showCamera = true }
                    else { showCameraPermissionAlert = true }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert = true
        @unknown default:
            showCameraPermissionAlert = true
        }
    }
}

// MARK: - Camera Picker

struct CameraPickerRepresentable: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerRepresentable
        init(_ parent: CameraPickerRepresentable) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Privacy Policy View

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    private let privacyPolicyText = """
    A Política de Privacidade pretende dar a conhecer aos nossos clientes e utilizadores as regras gerais de privacidade e tratamento dos seus dados pessoais, que recolhemos e tratamos no estrito respeito e cumprimento da Lei de Proteção de Dados Pessoais.

    A Salva Mais, Lda. respeita as melhores práticas no domínio da segurança e da proteção dos dados pessoais, tendo para o efeito aprovado um processo capaz de acautelar a proteção dos dados que nos são disponibilizados por todos aqueles que de alguma forma se relacionam com a Empresa.

    Neste contexto, a Salva Mais, Lda. tem uma política rigorosa para a Proteção dos Dados Pessoais e de implementação para a verificação desta Política de Privacidade bem como, pela definição de regras claras de tratamento de dados pessoais, assegurando que todos os que nos confiam o tratamento dos seus dados pessoais, tenham conhecimento da forma como a Salva Mais, Lda. trata os dados e quais os direitos que lhes assistem nesta matéria.

    Leia por favor esta Política de Privacidade com atenção pois, se está a aceder a um dos nossos websites ou portais, a disponibilização dos seus dados pessoais implica o conhecimento e aceitação das condições aqui constantes. Assim, ao disponibilizar os seus dados pessoais, está a autorizar a recolha, uso e divulgação dos mesmos de acordo com as regras aqui definidas.

    ABRANGÊNCIA DA POLÍTICA DE PRIVACIDADE

    Esta Política de Privacidade aplica-se exclusivamente à recolha e tratamento de dados pessoais efetuados pela Salva Mais, Lda.

    No website e portais da Salva Mais, Lda. poderá encontrar links de acesso a outros websites que são alheios à Salva Mais, Lda. A disponibilização de tais links é efetuada de boa fé, não podendo a Salva Mais, Lda. ser responsabilizada pela recolha e tratamento de dados pessoais efetuados nesses websites e portais, nem ser responsabilizada pela exatidão, credibilidade e funcionalidades de websites e portais pertencentes a terceiros.

    A Salva Mais, Lda. considera perentória a leitura das Políticas de Privacidade de todos os websites que visitar.

    DADOS PESSOAIS

    Quando nos referimos a dados pessoais referimo-nos a qualquer informação, de qualquer natureza e independentemente do respetivo suporte, incluindo som e imagem, relativa a uma pessoa singular identificada, coletiva ou identificável.

    É considerada identificável a pessoa que possa ser identificada direta ou indiretamente, designadamente por referência a um número de identificação ou a um ou mais elementos específicos da sua identidade física, fisiológica, psíquica, económica, cultural ou social.

    RESPONSÁVEL PELO TRATAMENTO DE DADOS

    A entidade responsável pela recolha e tratamento dos dados pessoais é a Empresa Salva Mais, Lda. e que no contexto decide quais os dados recolhidos, os meios de tratamento dos dados e para que finalidades são utilizados.

    TIPO DE DADOS PESSOAIS RECOLHIDOS

    A Salva Mais, Lda., no âmbito da sua atividade, procede à recolha e ao tratamento dos dados pessoais necessários à prestação de serviços e/ou fornecimento de produtos, tratando nesse âmbito dados como o nome, a morada, o número de telefone e o endereço de correio eletrónico.

    RECOLHA DE DADOS

    A Salva Mais, Lda. recolhe os seus dados por telefone, por escrito ou através do seu website, mediante o seu consentimento. Por regra, os dados pessoais são recolhidos quando o utilizador subscreve um dos nossos serviços ou através dos formulários presentes no website.

    Alguns dados pessoais são de fornecimento obrigatório e, em caso de falta ou insuficiência desses dados, a Salva Mais, Lda. não poderá disponibilizar a informação em causa.

    Os dados pessoais recolhidos são tratados informaticamente e no estrito cumprimento da legislação de proteção de dados pessoais, sendo armazenados em base de dados específicas, criadas para o efeito.

    FINALIDADES DO TRATAMENTO DE DADOS PESSOAIS

    Em geral, os dados pessoais recolhidos destinam-se à gestão da relação comercial, à informação sobre a prestação dos serviços contratados, à adequação dos serviços às necessidades e interesses do cliente, a ações de informação e marketing, bem como à inclusão do cliente e do utilizador nas listas de assinantes.

    CONSERVAÇÃO DOS SEUS DADOS PESSOAIS

    O período de tempo durante o qual os dados são armazenados e conservados varia de acordo com a finalidade para a qual a informação é tratada. Sempre que não exista uma exigência legal específica, os dados serão armazenados apenas pelo período mínimo necessário para as finalidades que motivaram a sua recolha.

    ACESSO, RETIFICAÇÃO OU OPOSIÇÃO AO TRATAMENTO DOS SEUS DADOS PESSOAIS

    Nos termos da Lei de Proteção de Dados Pessoais, é garantido ao titular dos dados o direito de acesso, atualização, retificação ou eliminação dos seus dados pessoais, mediante pedido escrito endereçado à Salva Mais, Lda.

    MEDIDAS DE SEGURANÇA

    A Salva Mais, Lda. assume o compromisso de garantir a proteção da segurança dos dados pessoais que nos são disponibilizados, tendo adotado diversas medidas de segurança, de carácter técnico e organizativo, de forma a proteger os dados pessoais contra a sua difusão, perda, uso indevido, alteração, tratamento ou acesso não autorizado.

    CONTACTOS

    Salva Mais, Lda.
    Centro Empresarial de Algés
    Av. Bombeiros Voluntários de Algés 52, loja 8, Sala D
    1495-022 Algés
    Telemóvel: 93 856 52 93
    E-mail: geral@salvamais.pt

    Data da última atualização: 24 de março de 2026
    """

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 10) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.sgoPurple)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("POLÍTICA DE")
                                        .font(.system(size: 10, weight: .black))
                                        .tracking(4)
                                        .foregroundColor(.sgoTextMuted)
                                    Text("Privacidade")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(.sgoTextPrimary)
                                }
                            }
                            Text("Salva Mais, Lda. — Última atualização: 24 de março de 2026")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.sgoTextMuted)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .sgoGlassCard(cornerRadius: 24)

                        // Content
                        Text(privacyPolicyText)
                            .font(.system(size: 13))
                            .foregroundColor(.sgoTextPrimary)
                            .lineSpacing(5)
                            .padding(24)
                            .sgoGlassCard(cornerRadius: 24)

                        // Close button
                        Button {
                            dismiss()
                        } label: {
                            Text("FECHAR")
                                .frame(maxWidth: .infinity)
                                .sgoGlassButton()
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
