import SwiftUI

// MARK: - Servicos List View

struct ServicosListView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var servicosVM: ServicosViewModel
    @State private var selectedServico: Servico?
    @State private var showDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                
                if servicosVM.isLoading {
                    VStack(spacing: 16) {
                        SGOAnimatedOrb(size: 80, color: .sgoRed)
                        Text("A CARREGAR...")
                            .font(.system(size: 9, weight: .black))
                            .tracking(4)
                            .foregroundColor(.sgoTextMuted)
                    }
                } else if servicosVM.filteredServicos.isEmpty {
                    VStack(spacing: 16) {
                        SGOAnimatedOrb(size: 90, color: .sgoRed)
                            .overlay(
                                Text("🏖️")
                                    .font(.system(size: 32))
                            )
                        Text("Sem Serviços")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.sgoTextPrimary)
                        Text("Nenhum serviço encontrado")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.sgoTextMuted)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            // Filter pills
                            filterBar
                            
                            // Servicos list
                            LazyVStack(spacing: 12) {
                                ForEach(servicosVM.filteredServicos) { servico in
                                    ServicoCard(servico: servico)
                                        .onTapGesture {
                                            let gen = UIImpactFeedbackGenerator(style: .light)
                                            gen.impactOccurred()
                                            selectedServico = servico
                                            showDetail = true
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                        .padding(.top, 8)
                    }
                    .refreshable {
                        if let user = authVM.user {
                            await servicosVM.fetchServicos(for: user)
                        }
                    }
                }
            }
            .navigationTitle("Serviços")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showDetail) {
                if let servico = selectedServico {
                    ServicoDetailView(servico: servico)
                        .environmentObject(authVM)
                        .environmentObject(servicosVM)
                }
            }
        }
    }
    
    private var filterBar: some View {
        HStack(spacing: 8) {
            FilterPill(title: "Todos", isSelected: servicosVM.filterType == nil) {
                servicosVM.filterType = nil
            }
            FilterPill(title: "🌊 Praia", isSelected: servicosVM.filterType == .praia) {
                servicosVM.filterType = .praia
            }
            FilterPill(title: "🏊 Piscina", isSelected: servicosVM.filterType == .piscina) {
                servicosVM.filterType = .piscina
            }
            Spacer()
            Text("\(servicosVM.filteredServicos.count)")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.sgoTextMuted)
                .tracking(1)
            + Text(" postos")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.sgoTextMuted)
        }
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let gen = UISelectionFeedbackGenerator()
            gen.selectionChanged()
            action()
        }) {
            Text(title)
                .font(.system(size: 11, weight: .black))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(isSelected ? .sgoRed : .sgoTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.6))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.sgoRed.opacity(0.3) : Color.clear, lineWidth: 1.5)
                        )
                )
                .shadow(color: isSelected ? Color.sgoRed.opacity(0.15) : .clear, radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Servico Card

struct ServicoCard: View {
    let servico: Servico
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Type icon
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 60, height: 60)
                
                Text(servico.servicoType.icon)
                    .font(.system(size: 28))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(servico.name)
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.sgoTextPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Status pill
                    Text(servico.status.rawValue)
                        .font(.system(size: 8, weight: .black))
                        .tracking(1)
                        .textCase(.uppercase)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(statusColor.opacity(0.1))
                        )
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 10))
                    Text(servico.location)
                        .lineLimit(1)
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.sgoTextMuted)
                
                HStack(spacing: 12) {
                    Label("\(servico.teamSize)", systemImage: "person.2.fill")
                    Label(servico.distrito ?? "—", systemImage: "map.fill")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.sgoTextMuted)
            }
        }
        .padding(16)
        .sgoGlassCard(cornerRadius: 24)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
    
    private var statusColor: Color {
        switch servico.status {
        case .ativo: return .sgoGreen
        case .inativo: return .sgoRed
        case .concluido: return .gray
        }
    }
}
