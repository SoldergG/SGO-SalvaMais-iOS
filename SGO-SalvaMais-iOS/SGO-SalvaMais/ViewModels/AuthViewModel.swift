import SwiftUI
import Combine

// MARK: - Auth ViewModel

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOnline = false
    
    private let userKey = "sgo_current_user"
    
    init() {
        loadSavedUser()
        Task { await checkConnection() }
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loggedUser = try await APIService.shared.login(email: email, password: password)
            user = loggedUser
            isAuthenticated = true
            saveUser(loggedUser)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            errorMessage = error.localizedDescription
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    func logout() {
        user = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userKey)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Persistence
    
    private func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
    
    private func loadSavedUser() {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let savedUser = try? JSONDecoder().decode(User.self, from: data) else { return }
        user = savedUser
        isAuthenticated = true
    }
    
    // MARK: - Connection
    
    func checkConnection() async {
        isOnline = await APIService.shared.pingAPI()
    }
    
    // MARK: - Permissions
    
    var isManager: Bool { user?.role.isManager ?? false }
    var isHighLevel: Bool { user?.role.isHighLevel ?? false }
    var isCliente: Bool { user?.role == .cliente }
    var isNadadorSalvador: Bool { user?.role == .nadadorSalvador }
}
