import SwiftUI

// MARK: - Dashboard ViewModel

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var servicos: [Servico] = []
    @Published var reports: [Report] = []
    @Published var users: [User] = []
    @Published var notifications: [AppNotification] = []
    @Published var allInventory: [(servicoName: String, items: [InventoryItem])] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var activeServicos: [Servico] {
        servicos.filter { $0.isCurrentlyActive }
    }
    
    var lifeguardCount: Int {
        users.filter { $0.role == .nadadorSalvador }.count
    }
    
    var complianceAlerts: [User] {
        users.filter { $0.role == .nadadorSalvador && $0.isCertExpiringSoon }
    }
    
    var unreadNotifications: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    // MARK: - Fetch All Data
    
    func fetchAll(for user: User) async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let fetchedServicos = APIService.shared.getServicos()
            async let fetchedReports = APIService.shared.getReports()
            async let fetchedUsers = APIService.shared.getAllUsers()
            async let fetchedNotifs = APIService.shared.getNotifications(userId: user.id)
            
            let (s, r, u, n) = try await (fetchedServicos, fetchedReports, fetchedUsers, fetchedNotifs)
            
            // Filter servicos based on role
            if user.role.isHighLevel {
                servicos = s
                reports = r
            } else if user.role == .cliente {
                let allowedEntityIds = user.entidadeIds ?? []
                let allowedServicoIds = user.servicoIds ?? []
                servicos = s.filter { srv in
                    allowedEntityIds.contains(srv.entityId) ||
                    allowedServicoIds.contains(srv.id) ||
                    srv.gestorEmail == user.email
                }
                let myServicoIds = Set(servicos.map { $0.id })
                reports = r.filter { myServicoIds.contains($0.servicoId ?? "") }
            } else {
                servicos = s.filter { srv in
                    srv.lifeguardIds.contains(user.id) || srv.coordinatorIds.contains(user.id)
                }
                let myServicoIds = Set(servicos.map { $0.id })
                reports = r.filter { myServicoIds.contains($0.servicoId ?? "") }
            }
            
            users = u
            notifications = n
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Submit Internal Report
    
    func submitInternalReport(
        type: ReportType,
        servicoId: String,
        user: User,
        descricao: String,
        servicoName: String
    ) async -> Bool {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let body: [String: Any] = [
            "submitterId": user.id,
            "submitterName": user.name,
            "servicoId": servicoId,
            "type": type.rawValue,
            "submissionDate": ISO8601DateFormatter().string(from: now),
            "formData": [
                "data": dateFormatter.string(from: now),
                "hora": timeFormatter.string(from: now),
                "descricao": descricao,
                "localOcorrencia": servicoName,
                "categoria": type.displayName
            ]
        ]
        
        do {
            let _ = try await APIService.shared.addReport(body)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Notifications
    
    func markAllRead(userId: String) async {
        let _ = try? await APIService.shared.markNotificationsAsRead(userId: userId)
        notifications = notifications.map { n in
            let updated = n
            // Since isRead is a var, we can conceptually mark it. 
            // In practice, the server handles this.
            return updated
        }
    }
    
    func deleteNotification(_ id: String) async {
        let _ = try? await APIService.shared.deleteNotification(id)
        notifications.removeAll { $0.id == id }
    }

    // MARK: - Inventory Overview

    func fetchInventoryOverview() async {
        var result: [(servicoName: String, items: [InventoryItem])] = []
        for servico in activeServicos {
            do {
                let items = try await APIService.shared.getInventory(servicoId: servico.id)
                if !items.isEmpty {
                    result.append((servicoName: servico.name, items: items))
                }
            } catch {
                // Skip servicos with no inventory
            }
        }
        allInventory = result
    }
}
