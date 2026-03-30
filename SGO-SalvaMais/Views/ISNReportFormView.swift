import SwiftUI

// MARK: - ISN Report Form View (Complete 2-page form)

struct ISNReportFormView: View {
    let reportType: ReportType
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var page = 1
    @State var selectedServicoId = ""
    @State var isSaving = false
    @State var showSuccess = false
    
    // MARK: Form State
    @State var localidade = ""
    @State var concelho = ""
    @State var dataStr = ""
    @State var hora = ""
    @State var emServico = true
    @State var foraServico = false
    
    // NS
    @State var nsNome = ""
    @State var nsNacionalidade = "Portuguesa"
    @State var nsSexoM = false
    @State var nsSexoF = false
    @State var nsContacto = ""
    @State var nsNumero = ""
    @State var sigAgent: UIImage? = nil
    
    // Vítima
    @State var vitimaNome = ""
    @State var vitimaMorada = ""
    @State var vitimaPorta = ""
    @State var vitimaAndar = ""
    @State var vitimaCP = ""
    @State var vitimaLocalidade = ""
    @State var vitimaNacionalidade = "Portuguesa"
    @State var vitimaIdade = ""
    @State var vitimaSexoM = false
    @State var vitimaSexoF = false
    @State var vitimaContacto = ""
    
    // Incidente
    @State var tipoSalvamento = false
    @State var tipo1Socorros = false
    @State var tipoBusca = false
    @State var tipoOutro = ""
    @State var consIleso = false
    @State var consFerido = false
    @State var consMorto = false
    @State var consDesaparecido = false
    @State var consOutro = ""
    
    // Causas Praia
    @State var causaCorrentes = false
    @State var causaTraumatica = false
    @State var causaNadarMal = false
    @State var causaPicadas = false
    @State var causaCansaco = false
    @State var causaAlergica = false
    @State var causaDorPrecordial = false
    @State var causaInsolacao = false
    @State var causaFalhaEquip = false
    @State var causaPerdida = false
    @State var causaAfogamento = false
    @State var causaCaibra = false
    
    // Causas Piscina
    @State var causaAVC = false
    @State var causaAngina = false
    @State var causaEnfarte = false
    @State var causaChoque = false
    @State var causaHemorragia = false
    @State var causaParagemDigestiva = false
    @State var causaQueimadura = false
    @State var causaGolpeCalor = false
    @State var causaCefaleias = false
    @State var traumaVertebro = false
    @State var traumaCranio = false
    @State var traumaMusculo = false
    @State var traumaQueda = false
    @State var causaDiabetica = false
    @State var causaEpileptica = false
    @State var causaPicada = false
    @State var causaFeridas = false
    @State var causaOutra = ""
    
    // Atividade
    @State var ativNatacao = false
    @State var ativAula = false
    @State var ativSalto = false
    @State var ativLudica = false
    @State var ativApneia = false
    @State var ativCaminhada = false
    @State var ativFlutuar = false
    @State var ativMergulho = false
    @State var ativOutra = ""
    
    // Entidades
    @State var entInem = false
    @State var entBombeiros = false
    @State var entPM = false
    @State var entGNR = false
    @State var entPSP = false
    @State var entNS = false
    @State var entAmarok = false
    @State var entESV = false
    @State var entParticular = ""
    
    // Condições Ambientais
    @State var condVentoFraco = false
    @State var condVentoMod = false
    @State var condVentoForte = false
    @State var condVisibMa = false
    @State var condVisibMedia = false
    @State var condVisibBoa = false
    @State var condCorrenteForte = false
    @State var condCorrenteMedia = false
    @State var condCorrenteFraca = false
    @State var condMareEnch = false
    @State var condMareVaz = false
    @State var condOndulacao1m = false
    @State var condOndulacao1a2m = false
    @State var condOndulacao2a3m = false
    @State var condOndulacaoOutro = ""
    @State var condBandVerde = false
    @State var condBandAmarela = false
    @State var condBandVerm = false
    @State var condBandSem = false
    
    // Meios
    @State var meioNenhum = false
    @State var meioCinto = false
    @State var meioBoiaCircular = false
    @State var meioVara = false
    @State var meioPlanoRigido = false
    @State var meioEmbarcacao = false
    @State var meioMotaAgua = false
    @State var meioBoiaTorpedo = false
    @State var meioMoto4x4 = false
    @State var meioViatura4x4 = false
    @State var meioPrancha = false
    @State var meioGoes = false
    @State var meioOutro = ""
    
    // Evacuação
    @State var evacInem = false
    @State var evacBombeiros = false
    @State var evacViatPart = false
    @State var evacNaoNec = false
    @State var evacEmbCap = false
    @State var evacViatCap = false
    @State var evacHeliFAP = false
    @State var evacHeliCNBCP = false
    @State var evacOutro = ""
    
    // Recusa
    @State var recusaEu = ""
    @State var recusaCC = ""
    @State var sigRecusal: UIImage? = nil
    @State var obsAdicionaisP1 = ""
    
    // Testemunhas
    @State var t1Nome = ""
    @State var t1Morada = ""
    @State var t1CP = ""
    @State var t1Idade = ""
    @State var t1Tel = ""
    @State var t1SexoM = false
    @State var t1SexoF = false
    @State var t1Nac = "Portuguesa"
    @State var sigT1: UIImage? = nil
    @State var t2Nome = ""
    @State var t2Morada = ""
    @State var t2CP = ""
    @State var t2Idade = ""
    @State var t2Tel = ""
    @State var t2SexoM = false
    @State var t2SexoF = false
    @State var t2Nac = "Portuguesa"
    @State var sigT2: UIImage? = nil
    @State var obsAdicionaisP2 = ""
    
    // Familiares & CS
    @State var infFamPessSim = false
    @State var infFamPessNao = false
    @State var infFamPessOutro = ""
    @State var infFamTelSim = false
    @State var infFamTelNao = false
    @State var infFamTelOutro = ""
    @State var csInformadaSim = false
    @State var csInformadaNao = false
    @State var relatorioAutoridade = ""
    @State var sigResponsible: UIImage? = nil
    
    // Tipologia Piscina
    @State var tipoMunCob = false
    @State var tipoMunDes = false
    @State var tipoMunNat = false
    @State var tipoHotCob = false
    @State var tipoHotDes = false
    @State var tipoHotAq = false
    @State var tipoDespCob = false
    @State var tipoDespDes = false
    @State var tipoPrivCob = false
    @State var tipoPrivDes = false
    @State var tipoCampCob = false
    @State var tipoCampDes = false
    @State var tipoEscCob = false
    @State var tipoEscDes = false
    @State var tipoOutraStr = ""
    
    var isPool: Bool { reportType.isPool }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    pageSelector
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        if page == 1 {
                            page1Content
                        } else {
                            page2Content
                        }
                    }
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
            .overlay { if showSuccess { successOverlay } }
            .onAppear { prefillFromUser() }
        }
    }
    
    // MARK: - Page Selector
    
    private var pageSelector: some View {
        HStack(spacing: 0) {
            Button { withAnimation(.spring(response: 0.3)) { page = 1 } } label: {
                Text("Frente (P1)")
                    .font(.system(size: 12, weight: .black))
                    .textCase(.uppercase)
                    .tracking(2)
                    .foregroundColor(page == 1 ? .white : .sgoTextMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(page == 1 ? Capsule().fill(Color.sgoBlack) : Capsule().fill(Color.clear))
            }
            Button { withAnimation(.spring(response: 0.3)) { page = 2 } } label: {
                Text("Verso (P2)")
                    .font(.system(size: 12, weight: .black))
                    .textCase(.uppercase)
                    .tracking(2)
                    .foregroundColor(page == 2 ? .white : .sgoTextMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(page == 2 ? Capsule().fill(Color.sgoBlack) : Capsule().fill(Color.clear))
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.white.opacity(0.5)))
        .padding(.horizontal, 40)
        .padding(.vertical, 10)
    }
    
    private func prefillFromUser() {
        if let user = authVM.user {
            nsNome = user.name
            nsContacto = user.phone
            nsNumero = user.certNumber ?? ""
            nsNacionalidade = user.nacionalidade ?? "Portuguesa"
            nsSexoM = user.sexo == "M"
            nsSexoF = user.sexo == "F"
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        dataStr = df.string(from: Date())
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm"
        hora = tf.string(from: Date())
    }
}

// MARK: - Reusable Form Components

struct ISNBoxHeader: View {
    let title: String
    var dark: Bool = true
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .black))
                .foregroundColor(.white)
                .textCase(.uppercase)
                .tracking(3)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(dark ? Color.sgoBlack : Color.sgoRed)
        )
    }
}

struct ISNGroupTitle: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.sgoRed)
                .frame(width: 3, height: 16)
            Text(title)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.sgoRed)
                .textCase(.uppercase)
                .tracking(2)
            Spacer()
        }
    }
}

struct ISNCheckbox: View {
    let label: String
    @Binding var isChecked: Bool
    
    var body: some View {
        Button {
            let g = UIImpactFeedbackGenerator(style: .light)
            g.impactOccurred()
            isChecked.toggle()
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isChecked ? Color.sgoRed : Color.white)
                        .frame(width: 28, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isChecked ? Color.sgoRed : Color.gray.opacity(0.2), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                
                Text(label)
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(isChecked ? .sgoTextPrimary : .sgoTextMuted)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ISNTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.sgoTextMuted)
                .textCase(.uppercase)
                .tracking(2)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemGray6).opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.12), lineWidth: 1.5)
                        )
                )
        }
    }
}

// MARK: - Box Container

struct ISNBox<Content: View>: View {
    let title: String
    var dark: Bool = true
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            ISNBoxHeader(title: title, dark: dark)
            VStack(spacing: 16) {
                content
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.95))
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}
