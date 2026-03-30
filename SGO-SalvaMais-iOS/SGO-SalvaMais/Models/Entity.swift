import Foundation

// MARK: - Entity

struct Entity: Identifiable, Codable {
    let id: String
    var name: String
    var nif: String
    var address: String
    var postalCode: String
    var phone: String
    var email: String
    var isArchived: Bool
    var createdAt: String
    var contracts: [Contract]?

    enum CodingKeys: String, CodingKey {
        case id, name, nif, address, postalCode, phone, email, isArchived, createdAt, contracts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        nif = try container.decodeIfPresent(String.self, forKey: .nif) ?? ""
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        postalCode = try container.decodeIfPresent(String.self, forKey: .postalCode) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        contracts = try container.decodeIfPresent([Contract].self, forKey: .contracts)
    }
}

// MARK: - Contract

struct Contract: Identifiable, Codable {
    let id: String
    var name: String
    var referenceNumber: String?
    var startDate: String
    var endDate: String

    enum CodingKeys: String, CodingKey {
        case id, name, referenceNumber, startDate, endDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idValue = try? container.decode(String.self, forKey: .id) {
            id = idValue
        } else {
            let dyn = try decoder.container(keyedBy: DynamicCodingKeys.self)
            id = (try? dyn.decode(String.self, forKey: DynamicCodingKeys(stringValue: "_id")!)) ?? UUID().uuidString
        }
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        referenceNumber = try container.decodeIfPresent(String.self, forKey: .referenceNumber)
        startDate = try container.decodeIfPresent(String.self, forKey: .startDate) ?? ""
        endDate = try container.decodeIfPresent(String.self, forKey: .endDate) ?? ""
    }
}
