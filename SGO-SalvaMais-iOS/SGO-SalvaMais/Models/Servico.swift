import Foundation

// MARK: - Servico Type

enum ServicoType: String, Codable, CaseIterable {
    case praia = "Praia"
    case piscina = "Piscina"
    
    var icon: String {
        switch self {
        case .praia: return "🌊"
        case .piscina: return "🏊"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .praia: return "water.waves"
        case .piscina: return "figure.pool.swim"
        }
    }
}

// MARK: - Servico Status

enum ServicoStatus: String, Codable {
    case ativo = "Ativo"
    case inativo = "Inativo"
    case concluido = "Concluído"
    
    var color: String {
        switch self {
        case .ativo: return "green"
        case .inativo: return "red"
        case .concluido: return "gray"
        }
    }
}

// MARK: - Weekly Schedule

struct WeeklyScheduleDay: Codable {
    var open: String
    var close: String
    var closed: Bool
}

struct WeeklySchedule: Codable {
    var monday: WeeklyScheduleDay
    var tuesday: WeeklyScheduleDay
    var wednesday: WeeklyScheduleDay
    var thursday: WeeklyScheduleDay
    var friday: WeeklyScheduleDay
    var saturday: WeeklyScheduleDay
    var sunday: WeeklyScheduleDay
}

// MARK: - Servico

struct Servico: Identifiable, Codable {
    let id: String
    var name: String
    var entityId: String
    var servicoType: ServicoType
    var tipologiaAguas: String
    var location: String
    var distrito: String?
    var startDate: String
    var endDate: String
    var coordinatorIds: [String]
    var lifeguardIds: [String]
    var contractId: String?
    var status: ServicoStatus
    var description: String
    var gestorNome: String?
    var gestorEmail: String?
    var gestorTelemovel: String?
    var gestorSuplenteNome: String?
    var gestorSuplenteEmail: String?
    var gestorSuplenteTelemovel: String?
    var weeklySchedule: WeeklySchedule?
    var minLifeguards: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, entityId, servicoType, tipologiaAguas, location, distrito
        case startDate, endDate, coordinatorIds, lifeguardIds, contractId
        case status, description, gestorNome, gestorEmail, gestorTelemovel
        case gestorSuplenteNome, gestorSuplenteEmail, gestorSuplenteTelemovel
        case weeklySchedule, minLifeguards
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        name = try container.decode(String.self, forKey: .name)
        entityId = try container.decodeIfPresent(String.self, forKey: .entityId) ?? ""
        servicoType = try container.decodeIfPresent(ServicoType.self, forKey: .servicoType) ?? .praia
        tipologiaAguas = try container.decodeIfPresent(String.self, forKey: .tipologiaAguas) ?? ""
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        distrito = try container.decodeIfPresent(String.self, forKey: .distrito)
        startDate = try container.decodeIfPresent(String.self, forKey: .startDate) ?? ""
        endDate = try container.decodeIfPresent(String.self, forKey: .endDate) ?? ""
        coordinatorIds = try container.decodeIfPresent([String].self, forKey: .coordinatorIds) ?? []
        lifeguardIds = try container.decodeIfPresent([String].self, forKey: .lifeguardIds) ?? []
        contractId = try container.decodeIfPresent(String.self, forKey: .contractId)
        status = try container.decodeIfPresent(ServicoStatus.self, forKey: .status) ?? .ativo
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        gestorNome = try container.decodeIfPresent(String.self, forKey: .gestorNome)
        gestorEmail = try container.decodeIfPresent(String.self, forKey: .gestorEmail)
        gestorTelemovel = try container.decodeIfPresent(String.self, forKey: .gestorTelemovel)
        gestorSuplenteNome = try container.decodeIfPresent(String.self, forKey: .gestorSuplenteNome)
        gestorSuplenteEmail = try container.decodeIfPresent(String.self, forKey: .gestorSuplenteEmail)
        gestorSuplenteTelemovel = try container.decodeIfPresent(String.self, forKey: .gestorSuplenteTelemovel)
        weeklySchedule = try container.decodeIfPresent(WeeklySchedule.self, forKey: .weeklySchedule)
        minLifeguards = try container.decodeIfPresent(Int.self, forKey: .minLifeguards)
    }
    
    /// Check if service is currently active based on dates
    var isCurrentlyActive: Bool {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let start = formatter.date(from: String(startDate.prefix(10))),
              let end = formatter.date(from: String(endDate.prefix(10))) else { return false }
        return today >= start && today <= end
    }
    
    var teamSize: Int {
        coordinatorIds.count + lifeguardIds.count
    }
}
