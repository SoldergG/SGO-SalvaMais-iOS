import Foundation

// MARK: - Role

enum Role: String, Codable, CaseIterable {
    case nadadorSalvador = "Nadador Salvador"
    case coordenador = "Coordenador"
    case administrador = "Administrador"
    case cliente = "Cliente"
    case gestor = "Gestor"
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .nadadorSalvador: return "figure.pool.swim"
        case .coordenador: return "person.badge.shield.checkmark.fill"
        case .administrador: return "gear.badge.checkmark"
        case .cliente: return "building.2.fill"
        case .gestor: return "person.crop.rectangle.stack.fill"
        }
    }
    
    var color: String {
        switch self {
        case .nadadorSalvador: return "blue"
        case .coordenador: return "orange"
        case .administrador: return "red"
        case .cliente: return "purple"
        case .gestor: return "green"
        }
    }
    
    var isManager: Bool {
        self == .administrador || self == .coordenador || self == .gestor
    }
    
    var isHighLevel: Bool {
        self == .administrador || self == .gestor
    }
}

// MARK: - User

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var role: Role
    var entidade: String?
    var entidadeIds: [String]?
    var servicoIds: [String]?
    var coordinatorId: String?
    var nif: String?
    var certNumber: String?
    var certIssueDate: String?
    var certExpiryDate: String?
    var certPhotoUrl: String?
    var certPhotoBackUrl: String?
    var isArchived: Bool?
    var isPending: Bool?
    var nacionalidade: String?
    var sexo: String?
    var morada: String?
    var dataNascimento: String?
    var privacyPolicyAccepted: Bool?
    var privacyPolicyAcceptedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, role, entidade, entidadeIds, servicoIds
        case coordinatorId, nif, certNumber, certIssueDate, certExpiryDate
        case certPhotoUrl, certPhotoBackUrl, isArchived, isPending, nacionalidade, sexo, morada, dataNascimento
        case privacyPolicyAccepted, privacyPolicyAcceptedAt
    }
    
    // Handle _id from MongoDB
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Try "id" first, fallback to trying a dynamic "_id" key
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            // Fallback: try to decode from a dynamic container
            let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dynamicContainer.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        role = try container.decode(Role.self, forKey: .role)
        entidade = try container.decodeIfPresent(String.self, forKey: .entidade)
        entidadeIds = try container.decodeIfPresent([String].self, forKey: .entidadeIds)
        servicoIds = try container.decodeIfPresent([String].self, forKey: .servicoIds)
        coordinatorId = try container.decodeIfPresent(String.self, forKey: .coordinatorId)
        nif = try container.decodeIfPresent(String.self, forKey: .nif)
        certNumber = try container.decodeIfPresent(String.self, forKey: .certNumber)
        certIssueDate = try container.decodeIfPresent(String.self, forKey: .certIssueDate)
        certExpiryDate = try container.decodeIfPresent(String.self, forKey: .certExpiryDate)
        certPhotoUrl = try container.decodeIfPresent(String.self, forKey: .certPhotoUrl)
        certPhotoBackUrl = try container.decodeIfPresent(String.self, forKey: .certPhotoBackUrl)
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived)
        isPending = try container.decodeIfPresent(Bool.self, forKey: .isPending)
        nacionalidade = try container.decodeIfPresent(String.self, forKey: .nacionalidade)
        sexo = try container.decodeIfPresent(String.self, forKey: .sexo)
        morada = try container.decodeIfPresent(String.self, forKey: .morada)
        dataNascimento = try container.decodeIfPresent(String.self, forKey: .dataNascimento)
        privacyPolicyAccepted = try container.decodeIfPresent(Bool.self, forKey: .privacyPolicyAccepted)
        privacyPolicyAcceptedAt = try container.decodeIfPresent(String.self, forKey: .privacyPolicyAcceptedAt)
    }
    
    /// Whether the user's ISN certification is expiring soon (within 90 days)
    var isCertExpiringSoon: Bool {
        guard let expiry = certExpiryDate,
              let date = ISO8601DateFormatter().date(from: expiry) ?? dateFormatter.date(from: expiry) else { return false }
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 999
        return daysLeft < 90
    }
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }
}

// MARK: - Dynamic CodingKeys for _id

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(stringValue: String) { self.stringValue = stringValue; self.intValue = nil }
    init?(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
}
