import Foundation

// MARK: - Shift

struct Shift: Identifiable, Codable {
    let id: String
    var servicoId: String
    var lifeguardId: String
    var lifeguardName: String
    var date: String
    var startTime: String?
    var endTime: String?
    var shiftType: String // "Manhã" | "Tarde" | "Dia Inteiro" | "Personalizado"
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, servicoId, lifeguardId, lifeguardName, date, startTime, endTime, shiftType, notes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        servicoId = try container.decode(String.self, forKey: .servicoId)
        lifeguardId = try container.decode(String.self, forKey: .lifeguardId)
        lifeguardName = try container.decodeIfPresent(String.self, forKey: .lifeguardName) ?? ""
        date = try container.decode(String.self, forKey: .date)
        startTime = try container.decodeIfPresent(String.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(String.self, forKey: .endTime)
        shiftType = try container.decodeIfPresent(String.self, forKey: .shiftType) ?? "Dia Inteiro"
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }
}

// MARK: - Inventory Item

struct InventoryItem: Identifiable, Codable {
    let id: String
    var servicoId: String
    var name: String
    var quantity: Int
    var category: String
    var condition: String
    var lastCheckedDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, servicoId, name, quantity, category, condition, lastCheckedDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        servicoId = try container.decode(String.self, forKey: .servicoId)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity) ?? 0
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "Outro"
        condition = try container.decodeIfPresent(String.self, forKey: .condition) ?? "Bom"
        lastCheckedDate = try container.decodeIfPresent(String.self, forKey: .lastCheckedDate) ?? ""
    }
    
    var conditionColor: String {
        switch condition {
        case "Bom": return "green"
        case "Razoável": return "orange"
        case "Mau": return "red"
        default: return "gray"
        }
    }
}

// MARK: - AppNotification

struct AppNotification: Identifiable, Codable {
    let id: String
    var recipientId: String
    var reportId: String
    var message: String
    var isRead: Bool
    var createdAt: String
    var type: String?
    
    enum CodingKeys: String, CodingKey {
        case id, recipientId, reportId, message, isRead, createdAt, type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        recipientId = try container.decodeIfPresent(String.self, forKey: .recipientId) ?? ""
        reportId = try container.decodeIfPresent(String.self, forKey: .reportId) ?? ""
        message = try container.decode(String.self, forKey: .message)
        isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead) ?? false
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
    
    var typeIcon: String {
        switch type {
        case "incident": return "🚨"
        case "compliance": return "🛡️"
        default: return "🔔"
        }
    }
}

// MARK: - Evaluation

struct Evaluation: Identifiable, Codable {
    let id: String
    var servicoId: String
    var clientId: String
    var clientName: String
    var entityName: String
    var submissionDate: String
    var comments: String
    var wouldRehire: String
    
    enum CodingKeys: String, CodingKey {
        case id, servicoId, clientId, clientName, entityName, submissionDate, comments, wouldRehire
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        servicoId = try container.decode(String.self, forKey: .servicoId)
        clientId = try container.decodeIfPresent(String.self, forKey: .clientId) ?? ""
        clientName = try container.decodeIfPresent(String.self, forKey: .clientName) ?? ""
        entityName = try container.decodeIfPresent(String.self, forKey: .entityName) ?? ""
        submissionDate = try container.decodeIfPresent(String.self, forKey: .submissionDate) ?? ""
        comments = try container.decodeIfPresent(String.self, forKey: .comments) ?? ""
        wouldRehire = try container.decodeIfPresent(String.self, forKey: .wouldRehire) ?? ""
    }
}

// MARK: - EmailLog

struct EmailLog: Identifiable, Codable {
    let id: String
    var recipient: String
    var subject: String
    var timestamp: String
    var status: String
    var errorDetails: String?

    enum CodingKeys: String, CodingKey {
        case id, recipient, subject, timestamp, status, errorDetails
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let v = try? c.decode(String.self, forKey: .id) { id = v }
        else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        recipient = try c.decodeIfPresent(String.self, forKey: .recipient) ?? ""
        subject = try c.decodeIfPresent(String.self, forKey: .subject) ?? ""
        timestamp = try c.decodeIfPresent(String.self, forKey: .timestamp) ?? ""
        status = try c.decodeIfPresent(String.self, forKey: .status) ?? "Desconhecido"
        errorDetails = try c.decodeIfPresent(String.self, forKey: .errorDetails)
    }
}

// MARK: - AccessLog

struct AccessLog: Identifiable, Codable {
    let id: String
    var userName: String
    var userRole: String
    var totalSessions: Int
    var lastIp: String
    var lastAccess: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userName, userRole, totalSessions, lastIp, lastAccess
    }
}

// MARK: - HealthStatus

struct HealthStatus: Codable {
    var status: String
    var database: String
    var timestamp: String
    var environment: String
    var host: String?
}

// MARK: - Entity

struct Entity: Identifiable, Codable {
    let id: String
    var name: String
    var nif: String?
    var contacto: String?
    var email: String?
    var morada: String?
    var codigoPostal: String?
    var distrito: String?

    enum CodingKeys: String, CodingKey {
        case id, name, nif, contacto, email, morada, codigoPostal, distrito
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
        nif = try container.decodeIfPresent(String.self, forKey: .nif)
        contacto = try container.decodeIfPresent(String.self, forKey: .contacto)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        morada = try container.decodeIfPresent(String.self, forKey: .morada)
        codigoPostal = try container.decodeIfPresent(String.self, forKey: .codigoPostal)
        distrito = try container.decodeIfPresent(String.self, forKey: .distrito)
    }
}
