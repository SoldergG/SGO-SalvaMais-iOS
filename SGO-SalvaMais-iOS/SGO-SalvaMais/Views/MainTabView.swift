import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var dashboardVM = DashboardViewModel()
    @StateObject private var servicosVM = ServicosViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environmentObject(dashboardVM)
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)
            
            ServicosListView()
                .environmentObject(servicosVM)
                .tabItem {
                    Label("Serviços", systemImage: "building.2.fill")
                }
                .tag(1)
            
            CalendarView()
                .environmentObject(servicosVM)
                .tabItem {
                    Label("Calendário", systemImage: "calendar")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .tint(Color.sgoRed)
        .onAppear {
            // Glass tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor(Color.white.opacity(0.85))
            appearance.shadowColor = UIColor(Color.gray.opacity(0.1))
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .task {
            if let user = authVM.user {
                await dashboardVM.fetchAll(for: user)
                await servicosVM.fetchServicos(for: user)
            }
        }
    }
}
