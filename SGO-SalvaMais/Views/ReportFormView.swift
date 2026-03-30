import SwiftUI

// MARK: - Report Form View

struct ReportFormView: View {
    let reportType: ReportType
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedServicoId = ""
    @State private var descricao = ""
    @State private var intervenientes = ""
    @State private var data = Date()
    @State private var isSaving = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text(reportType.icon)
                                .font(.system(size: 48))
                            
                            Text(reportType.displayName)
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.sgoTextPrimary)
                            
                            Text(reportType.isISN ? "REGISTO OFICIAL ISN" : "OCORRÊNCIA INTERNA")
                                .font(.system(size: 9, weight: .black))
                                .tracking(4)
                                .foregroundColor(.sgoRed)
                        }
                        .padding(.top, 10)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Posto
                            VStack(alignment: .leading, spacing: 8) {
                                Text("POSTO DE OPERAÇÃO")
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(3)
                                    .foregroundColor(.sgoTextMuted)
                                
                                Picker("Posto", selection: $selectedServicoId) {
                                    Text("Escolher Unidade...").tag("")
                                    ForEach(dashboardVM.activeServicos) { s in
                                        Text(s.name).tag(s.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .sgoGlassField()
                            }
                            
                            // Data & Hora
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DATA E HORA")
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(3)
                                    .foregroundColor(.sgoTextMuted)
                                
                                DatePicker("", selection: $data, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .sgoGlassField()
                            }
                            
                            // Descrição
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DESCRIÇÃO DOS FACTOS")
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(3)
                                    .foregroundColor(.sgoTextMuted)
                                
                                TextEditor(text: $descricao)
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(minHeight: 150)
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(UIColor.systemGray6).opacity(0.5))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.gray.opacity(0.15), lineWidth: 1.5)
                                            )
                                    )
                                    .scrollContentBackground(.hidden)
                            }
                            
                            // Intervenientes
                            VStack(alignment: .leading, spacing: 8) {
                                Text("INTERVENIENTES")
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(3)
                                    .foregroundColor(.sgoTextMuted)
                                
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.sgoTextMuted)
                                    TextField("Nomes dos intervenientes", text: $intervenientes)
                                }
                                .sgoGlassField()
                            }
                        }
                        .padding(24)
                        .sgoGlassCard(cornerRadius: 28)
                        
                        // Buttons
                        HStack(spacing: 12) {
                            Button { dismiss() } label: {
                                Text("Cancelar")
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 11, weight: .black))
                                    .textCase(.uppercase)
                                    .tracking(2)
                                    .padding(.vertical, 16)
                                    .background(
                                        Capsule().fill(Color(UIColor.systemGray5))
                                    )
                                    .foregroundColor(.sgoTextMuted)
                            }
                            
                            Button {
                                Task { await submitReport() }
                            } label: {
                                HStack {
                                    if isSaving {
                                        ProgressView().tint(.white).scaleEffect(0.8)
                                    } else {
                                        Text("Submeter")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .sgoGlassButton(isDestructive: true)
                            }
                            .disabled(selectedServicoId.isEmpty || descricao.isEmpty || isSaving)
                            .opacity(selectedServicoId.isEmpty || descricao.isEmpty ? 0.5 : 1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.sgoTextSecondary)
                            .padding(10)
                            .background(Circle().fill(Color(UIColor.systemGray6)))
                    }
                }
            }
            .overlay {
                if showSuccess {
                    successOverlay
                }
            }
        }
    }
    
    private func submitReport() async {
        guard let user = authVM.user else { return }
        isSaving = true
        
        let servicoName = dashboardVM.activeServicos.first { $0.id == selectedServicoId }?.name ?? ""
        let success = await dashboardVM.submitInternalReport(
            type: reportType,
            servicoId: selectedServicoId,
            user: user,
            descricao: descricao,
            servicoName: servicoName
        )
        
        isSaving = false
        
        if success {
            withAnimation { showSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { dismiss() }
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.sgoGreen)
                
                Text("Registo Submetido")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.white)
                
                Text("PROCESSADO COM SUCESSO")
                    .font(.system(size: 9, weight: .black))
                    .tracking(4)
                    .foregroundColor(.sgoGreen)
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}
