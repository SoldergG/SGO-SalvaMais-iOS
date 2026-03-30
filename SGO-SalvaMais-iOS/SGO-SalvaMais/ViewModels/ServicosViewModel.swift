import SwiftUI

// MARK: - Servicos ViewModel

@MainActor
class ServicosViewModel: ObservableObject {
    @Published var servicos: [Servico] = []
    @Published var shifts: [Shift] = []
    @Published var inventory: [InventoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var filterType: ServicoType? = nil
    
    var filteredServicos: [Servico] {
        guard let type = filterType else { return servicos }
        return servicos.filter { $0.servicoType == type }
    }
    
    // MARK: - Fetch Servicos
    
    func fetchServicos(for user: User) async {
        isLoading = true
        do {
            let all = try await APIService.shared.getServicos()
            if user.role.isHighLevel {
                servicos = all
            } else if user.role == .cliente {
                let allowedEntityIds = user.entidadeIds ?? []
                let allowedServicoIds = user.servicoIds ?? []
                servicos = all.filter { srv in
                    allowedEntityIds.contains(srv.entityId) ||
                    allowedServicoIds.contains(srv.id) ||
                    srv.gestorEmail == user.email
                }
            } else {
                servicos = all.filter { srv in
                    srv.lifeguardIds.contains(user.id) || srv.coordinatorIds.contains(user.id)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Fetch Shifts
    
    func fetchShifts(for servicoId: String) async {
        do {
            shifts = try await APIService.shared.getShifts(servicoId: servicoId)
        } catch {
            shifts = []
        }
    }
    
    // MARK: - Fetch Inventory

    func fetchInventory(for servicoId: String) async {
        do {
            inventory = try await APIService.shared.getInventory(servicoId: servicoId)
        } catch {
            inventory = []
        }
    }

    // MARK: - Inventory CRUD

    func addInventoryItem(_ data: [String: Any]) async -> Bool {
        do {
            let item = try await APIService.shared.addInventoryItem(data)
            inventory.append(item)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateInventoryItem(_ id: String, data: [String: Any]) async -> Bool {
        do {
            let updated = try await APIService.shared.updateInventoryItem(id, data: data)
            if let idx = inventory.firstIndex(where: { $0.id == id }) {
                inventory[idx] = updated
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteInventoryItem(_ id: String) async -> Bool {
        do {
            let _ = try await APIService.shared.deleteInventoryItem(id)
            inventory.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
