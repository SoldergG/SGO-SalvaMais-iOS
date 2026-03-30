import Foundation

// MARK: - Report Type

enum ReportType: String, Codable, CaseIterable {
    case praiaMaritima = "praia_maritima"
    case praiaFluvial = "praia_fluvial"
    case piscinaInterior = "piscina_interior"
    case piscinaExterior = "piscina_exterior"
    case outraClimatologicas = "outra_climatologicas_poluicao"
    case outraOcorrencias = "outra_ocorrencias_diversas"
    case outraPrevencao = "outra_prevencao_ativa"
    case outraAnomalia = "outra_anomalia_tecnica"
    
    var displayName: String {
        switch self {
        case .praiaMaritima: return "Praia Marítima"
        case .praiaFluvial: return "Praia Fluvial"
        case .piscinaInterior: return "Piscina Interior"
        case .piscinaExterior: return "Piscina Exterior"
        case .outraClimatologicas: return "Climatéricas"
        case .outraOcorrencias: return "Diversas"
        case .outraPrevencao: return "Prevenção"
        case .outraAnomalia: return "Anomalia"
        }
    }
    
    var icon: String {
        switch self {
        case .praiaMaritima: return "🌊"
        case .praiaFluvial: return "🏞️"
        case .piscinaInterior: return "🏟️"
        case .piscinaExterior: return "☀️"
        case .outraClimatologicas: return "🌫️"
        case .outraOcorrencias: return "📝"
        case .outraPrevencao: return "📢"
        case .outraAnomalia: return "🛠️"
        }
    }
    
    var isISN: Bool {
        switch self {
        case .praiaMaritima, .praiaFluvial, .piscinaInterior, .piscinaExterior:
            return true
        default:
            return false
        }
    }
    
    var isPool: Bool {
        switch self {
        case .piscinaInterior, .piscinaExterior:
            return true
        default:
            return false
        }
    }
    
    static var isnTypes: [ReportType] {
        [.praiaMaritima, .praiaFluvial, .piscinaInterior, .piscinaExterior]
    }
    
    static var internalTypes: [ReportType] {
        [.outraClimatologicas, .outraOcorrencias, .outraPrevencao, .outraAnomalia]
    }
}

// MARK: - Report

struct Report: Identifiable, Codable {
    let id: String
    var submitterId: String
    var submitterName: String
    var servicoId: String?
    var type: ReportType
    var submissionDate: String
    var formData: ReportFormData
    var isOfflinePending: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, submitterId, submitterName, servicoId, type, submissionDate, formData, isOfflinePending
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        submitterId = try container.decode(String.self, forKey: .submitterId)
        submitterName = try container.decodeIfPresent(String.self, forKey: .submitterName) ?? ""
        servicoId = try container.decodeIfPresent(String.self, forKey: .servicoId)
        type = try container.decode(ReportType.self, forKey: .type)
        submissionDate = try container.decode(String.self, forKey: .submissionDate)
        formData = try container.decodeIfPresent(ReportFormData.self, forKey: .formData) ?? ReportFormData()
        isOfflinePending = try container.decodeIfPresent(Bool.self, forKey: .isOfflinePending)
    }
    
    /// Formatted date
    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: submissionDate) {
            let display = DateFormatter()
            display.dateFormat = "dd/MM/yyyy HH:mm"
            return display.string(from: date)
        }
        return String(submissionDate.prefix(10))
    }
}

// MARK: - Report Form Data (flexible - matches web version)

struct ReportFormData: Codable {
    // Basic / internal fields
    var data: String?
    var hora: String?
    var localOcorrencia: String?
    var descricao: String?
    var intervenientes: String?
    var categoria: String?
    
    // MARK: Contexto Operacional
    var localidade: String?
    var concelho: String?
    var emServico: Bool?
    var foraServico: Bool?
    
    // MARK: Identificação Nadador-Salvador
    var nsNome: String?
    var nsNacionalidade: String?
    var nsSexoM: Bool?
    var nsSexoF: Bool?
    var nsMorada: String?
    var nsIdade: String?
    var nsContacto: String?
    var nsNumero: String?
    var signatureAgent: String?
    
    // MARK: Identificação da Vítima
    var vitimaNome: String?
    var vitimaMorada: String?
    var vitimaPorta: String?
    var vitimaAndar: String?
    var vitimaCP: String?
    var vitimaLocalidade: String?
    var vitimaNacionalidade: String?
    var vitimaIdade: String?
    var vitimaSexoM: Bool?
    var vitimaSexoF: Bool?
    var vitimaContacto: String?
    
    // MARK: Tipologia Piscina
    var tipoMunCob: Bool?
    var tipoMunDes: Bool?
    var tipoMunNat: Bool?
    var tipoHotCob: Bool?
    var tipoHotDes: Bool?
    var tipoHotAq: Bool?
    var tipoDespCob: Bool?
    var tipoDespDes: Bool?
    var tipoPrivCob: Bool?
    var tipoPrivDes: Bool?
    var tipoCampCob: Bool?
    var tipoCampDes: Bool?
    var tipoEscCob: Bool?
    var tipoEscDes: Bool?
    var tipoOutra: String?
    
    // MARK: Tipo de Incidente
    var tipoSalvamento: Bool?
    var tipo1Socorros: Bool?
    var tipoBusca: Bool?
    var tipoOutro: String?
    
    // MARK: Consequência
    var consIleso: Bool?
    var consFerido: Bool?
    var consMorto: Bool?
    var consDesaparecido: Bool?
    var consOutro: String?
    
    // MARK: Causas Prováveis (Praia)
    var causaCorrentes: Bool?
    var causaTraumatica: Bool?
    var causaNadarMal: Bool?
    var causaPicadas: Bool?
    var causaCansaco: Bool?
    var causaAlergica: Bool?
    var causaDorPrecordial: Bool?
    var causaInsolacao: Bool?
    var causaFalhaEquip: Bool?
    var causaPerdida: Bool?
    var causaAfogamento: Bool?
    var causaCaibra: Bool?
    
    // MARK: Causas Prováveis (Piscina)
    var causaAVC: Bool?
    var causaAngina: Bool?
    var causaEnfarte: Bool?
    var causaChoque: Bool?
    var causaHemorragia: Bool?
    var causaParagemDigestiva: Bool?
    var causaQueimadura: Bool?
    var causaGolpeCalor: Bool?
    var causaCefaleias: Bool?
    var traumaVertebro: Bool?
    var traumaCranio: Bool?
    var traumaMusculo: Bool?
    var traumaQueda: Bool?
    var causaDiabetica: Bool?
    var causaEpileptica: Bool?
    var causaPicada: Bool?
    var causaFeridas: Bool?
    var causaOutra: String?
    
    // MARK: Atividade no Momento
    var ativNatacao: Bool?
    var ativAula: Bool?
    var ativSalto: Bool?
    var ativLudica: Bool?
    var ativApneia: Bool?
    var ativCaminhada: Bool?
    var ativFlutuar: Bool?
    var ativMergulho: Bool?
    var ativOutra: String?
    
    // MARK: Condições Ambientais (só praias)
    var condVentoFraco: Bool?
    var condVentoMod: Bool?
    var condVentoForte: Bool?
    var condVisibMa: Bool?
    var condVisibMedia: Bool?
    var condVisibBoa: Bool?
    var condCorrenteForte: Bool?
    var condCorrenteMedia: Bool?
    var condCorrenteFraca: Bool?
    var condMareEnch: Bool?
    var condMareVaz: Bool?
    var condOndulacao1m: Bool?
    var condOndulacao1a2m: Bool?
    var condOndulacao2a3m: Bool?
    var condOndulacaoOutro: String?
    var condBandVerde: Bool?
    var condBandAmarela: Bool?
    var condBandVerm: Bool?
    var condBandSem: Bool?
    
    // MARK: Entidades que Prestaram Assistência
    var entInem: Bool?
    var entBombeiros: Bool?
    var entPM: Bool?
    var entGNR: Bool?
    var entPSP: Bool?
    var entNS: Bool?
    var entAmarok: Bool?
    var entESV: Bool?
    var entParticular: String?
    
    // MARK: Meios Envolvidos
    var meioNenhum: Bool?
    var meioCinto: Bool?
    var meioBoiaCircular: Bool?
    var meioVara: Bool?
    var meioPlanoRigido: Bool?
    var meioEmbarcacao: Bool?
    var meioMotaAgua: Bool?
    var meioBoiaTorpedo: Bool?
    var meioMoto4x4: Bool?
    var meioViatura4x4: Bool?
    var meioPrancha: Bool?
    var meioGoes: Bool?
    var meioOutro: String?
    
    // MARK: Evacuação
    var evacInem: Bool?
    var evacBombeiros: Bool?
    var evacViatPart: Bool?
    var evacNaoNec: Bool?
    var evacEmbCap: Bool?
    var evacViatCap: Bool?
    var evacHeliFAP: Bool?
    var evacHeliCNBCP: Bool?
    var evacOutro: String?
    
    // MARK: Recusa de Tratamento
    var recusaEu: String?
    var recusaCC: String?
    var signatureRefusal: String?
    
    // MARK: Observações
    var obsAdicionaisP1: String?
    var obsAdicionaisP2: String?
    
    // MARK: Testemunha 1
    var t1Nome: String?
    var t1Morada: String?
    var t1CP: String?
    var t1Idade: String?
    var t1Tel: String?
    var t1SexoM: Bool?
    var t1SexoF: Bool?
    var t1Nac: String?
    var signatureT1: String?
    
    // MARK: Testemunha 2
    var t2Nome: String?
    var t2Morada: String?
    var t2CP: String?
    var t2Idade: String?
    var t2Tel: String?
    var t2SexoM: Bool?
    var t2SexoF: Bool?
    var t2Nac: String?
    var signatureT2: String?
    
    // MARK: Informação Familiares
    var infFamPessSim: Bool?
    var infFamPessNao: Bool?
    var infFamPessOutro: String?
    var infFamTelSim: Bool?
    var infFamTelNao: Bool?
    var infFamTelOutro: String?
    
    // MARK: Comunicação Social
    var csInformadaSim: Bool?
    var csInformadaNao: Bool?
    
    // MARK: Relatório Autoridade
    var relatorioAutoridade: String?
    var signatureResponsible: String?
    
    init() {}
}
