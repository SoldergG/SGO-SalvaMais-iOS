import Foundation

// MARK: - API Service

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.salvamais.pt/api"
    private let token = "salvamais_secure_token_2025_prod"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        session = URLSession(configuration: config)
        decoder = JSONDecoder()
    }
    
    // MARK: - Generic Request
    
    private func request<T: Decodable>(
        _ endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "x-ei-token")
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Auth
    
    func login(email: String, password: String) async throws -> User {
        try await request("/auth/login", method: "POST", body: [
            "email": email,
            "password": password
        ])
    }
    
    func register(userData: [String: Any]) async throws -> User {
        try await request("/auth/register", method: "POST", body: userData)
    }
    
    // MARK: - Health Check
    
    func pingAPI() async -> Bool {
        do {
            guard let url = URL(string: "\(baseURL)/health") else { return false }
            var req = URLRequest(url: url)
            req.timeoutInterval = 5
            req.setValue(token, forHTTPHeaderField: "x-ei-token")
            let (_, response) = try await session.data(for: req)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    // MARK: - Users

    func getAllUsers() async throws -> [User] {
        try await request("/users")
    }

    func addUser(_ userData: [String: Any]) async throws -> User {
        try await request("/users", method: "POST", body: userData)
    }

    func updateUser(_ id: String, data: [String: Any]) async throws -> User {
        try await request("/users/\(id)", method: "PUT", body: data)
    }

    // MARK: - Entities

    func getAllEntities() async throws -> [Entity] {
        try await request("/entities")
    }

    func addEntity(_ entity: [String: Any]) async throws -> Entity {
        try await request("/entities", method: "POST", body: entity)
    }

    func updateEntity(_ id: String, data: [String: Any]) async throws -> Entity {
        try await request("/entities/\(id)", method: "PUT", body: data)
    }

    // MARK: - Servicos

    func getServicos() async throws -> [Servico] {
        try await request("/servicos")
    }

    func getServicoById(_ id: String) async throws -> Servico {
        try await request("/servicos/\(id)")
    }

    func addServico(_ data: [String: Any]) async throws -> Servico {
        try await request("/servicos", method: "POST", body: data)
    }

    func updateServico(_ id: String, data: [String: Any]) async throws -> Servico {
        try await request("/servicos/\(id)", method: "PUT", body: data)
    }

    func assignLifeguardToServico(_ servicoId: String, lifeguardId: String) async throws -> Servico {
        try await request("/servicos/\(servicoId)/assign-lifeguard", method: "POST", body: ["lifeguardId": lifeguardId])
    }

    func removeLifeguardFromServico(_ servicoId: String, lifeguardId: String) async throws -> Servico {
        try await request("/servicos/\(servicoId)/remove-lifeguard", method: "POST", body: ["lifeguardId": lifeguardId])
    }

    func assignCoordinatorToServico(_ servicoId: String, coordinatorId: String) async throws -> Servico {
        try await request("/servicos/\(servicoId)/assign-coordinator", method: "POST", body: ["coordinatorId": coordinatorId])
    }

    func removeCoordinatorFromServico(_ servicoId: String, coordinatorId: String) async throws -> Servico {
        try await request("/servicos/\(servicoId)/remove-coordinator", method: "POST", body: ["coordinatorId": coordinatorId])
    }

    // MARK: - Reports

    func getReports(servicoId: String? = nil) async throws -> [Report] {
        if let sid = servicoId {
            return try await request("/reports?servicoId=\(sid)")
        }
        return try await request("/reports")
    }

    func getReportById(_ id: String) async throws -> Report {
        try await request("/reports/\(id)")
    }

    func addReport(_ report: [String: Any]) async throws -> Report {
        try await request("/reports", method: "POST", body: report)
    }

    func updateReport(_ id: String, data: [String: Any]) async throws -> Report {
        try await request("/reports/\(id)", method: "PUT", body: data)
    }

    // MARK: - Shifts

    func getShifts(servicoId: String) async throws -> [Shift] {
        try await request("/shifts/\(servicoId)")
    }

    func addShift(_ shift: [String: Any]) async throws -> Shift {
        try await request("/shifts", method: "POST", body: shift)
    }

    func deleteShift(_ id: String) async throws -> EmptyResponse {
        try await request("/shifts/\(id)", method: "DELETE")
    }

    // MARK: - Inventory

    func getInventory(servicoId: String) async throws -> [InventoryItem] {
        try await request("/inventory/\(servicoId)")
    }

    func addInventoryItem(_ item: [String: Any]) async throws -> InventoryItem {
        try await request("/inventory", method: "POST", body: item)
    }

    func updateInventoryItem(_ id: String, data: [String: Any]) async throws -> InventoryItem {
        try await request("/inventory/\(id)", method: "PUT", body: data)
    }

    func deleteInventoryItem(_ id: String) async throws -> EmptyResponse {
        try await request("/inventory/\(id)", method: "DELETE")
    }

    // MARK: - Notifications

    func getNotifications(userId: String) async throws -> [AppNotification] {
        try await request("/notifications?userId=\(userId)")
    }

    func createNotification(_ data: [String: Any]) async throws -> AppNotification {
        try await request("/notifications", method: "POST", body: data)
    }

    func markNotificationsAsRead(userId: String) async throws -> [AppNotification] {
        try await request("/notifications/read", method: "POST", body: ["userId": userId])
    }

    func clearNotifications(userId: String) async throws -> EmptyResponse {
        try await request("/notifications/clear", method: "POST", body: ["userId": userId])
    }

    func deleteNotification(_ id: String) async throws -> EmptyResponse {
        try await request("/notifications/\(id)", method: "DELETE")
    }

    // MARK: - Evaluations

    func getEvaluations() async throws -> [Evaluation] {
        try await request("/evaluations")
    }

    func addEvaluation(_ data: [String: Any]) async throws -> Evaluation {
        try await request("/evaluations", method: "POST", body: data)
    }

    func getEvaluationByServicoId(_ servicoId: String) async throws -> Evaluation {
        try await request("/evaluations/servico/\(servicoId)")
    }

    // MARK: - Config

    func getAccessPermissions() async throws -> [String: [String: Bool]] {
        try await request("/config/access_permissions")
    }

    func updateAccessPermissions(_ permissions: [String: Any]) async throws -> EmptyResponse {
        try await request("/config/access_permissions", method: "POST", body: ["key": "access_permissions", "value": permissions])
    }

    func getAppConfig() async throws -> [String: String] {
        try await request("/config/app_config")
    }

    func updateAppConfig(_ config: [String: Any]) async throws -> EmptyResponse {
        try await request("/config/app_config", method: "POST", body: ["key": "app_config", "value": config])
    }

    // MARK: - Logs

    func getEmailLogs() async throws -> [[String: String]] {
        try await request("/email-logs")
    }

    func getAccessLogs() async throws -> [[String: String]] {
        try await request("/access-logs")
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int, String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL inválido"
        case .invalidResponse: return "Resposta inválida do servidor"
        case .serverError(let code, let msg): return "Erro \(code): \(msg)"
        case .decodingError(let msg): return "Erro de descodificação: \(msg)"
        }
    }
}

// MARK: - Empty Response

struct EmptyResponse: Decodable {}
