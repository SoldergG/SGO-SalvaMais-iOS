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

// MARK: - Evaluation Scores

struct EvaluationScores: Codable {
    var punctuality: Double?
    var professionalism: Double?
    var vigilance: Double?
    var interaction: Double?
    var safety: Double?
    var response: Double?
    var communication: Double?
    var global: Double?
}

// MARK: - Lifeguard Evaluation

struct LifeguardEvaluation: Codable {
    var lifeguardId: String
    var lifeguardName: String
    var score: Double
}

// MARK: - Evaluation

struct Evaluation: Identifiable, Codable {
    let id: String
    var servicoId: String
    var clientId: String
    var clientName: String
    var entityName: String
    var serviceStartDate: String?
    var serviceEndDate: String?
    var submissionDate: String
    var scores: EvaluationScores?
    var lifeguardEvaluations: [LifeguardEvaluation]?
    var comments: String
    var wouldRehire: String

    enum CodingKeys: String, CodingKey {
        case id, servicoId, clientId, clientName, entityName, serviceStartDate, serviceEndDate
        case submissionDate, scores, lifeguardEvaluations, comments, wouldRehire
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
        serviceStartDate = try container.decodeIfPresent(String.self, forKey: .serviceStartDate)
        serviceEndDate = try container.decodeIfPresent(String.self, forKey: .serviceEndDate)
        submissionDate = try container.decodeIfPresent(String.self, forKey: .submissionDate) ?? ""
        scores = try container.decodeIfPresent(EvaluationScores.self, forKey: .scores)
        lifeguardEvaluations = try container.decodeIfPresent([LifeguardEvaluation].self, forKey: .lifeguardEvaluations)
        comments = try container.decodeIfPresent(String.self, forKey: .comments) ?? ""
        wouldRehire = try container.decodeIfPresent(String.self, forKey: .wouldRehire) ?? ""
    }
}
