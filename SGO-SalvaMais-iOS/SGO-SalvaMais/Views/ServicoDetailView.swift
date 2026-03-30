import SwiftUI

// MARK: - Servico Detail View

struct ServicoDetailView: View {
    let servico: Servico
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var servicosVM: ServicosViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Header
                        headerSection
                        
                        // Info Grid
                        infoGrid
                        
                        // Schedule
                        if servico.weeklySchedule != nil {
                            scheduleSection
                        }
                        
                        // Team
                        teamSection
                        
                        // Manager Info
                        if let gestor = servico.gestorNome, !gestor.isEmpty {
                            managerSection
                        }
                        
                        // Inventory
                        inventorySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60)
                    .padding(.top, 10)
                }
            }
            .navigationTitle(servico.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.sgoTextSecondary)
                            .padding(10)
                            .background(Circle().fill(Color(UIColor.systemGray6)))
                    }
                }
            }
            .task {
                await servicosVM.fetchShifts(for: servico.id)
                await servicosVM.fetchInventory(for: servico.id)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.sgoBlack)
                    .frame(height: 120)
                
                VStack(spacing: 6) {
                    Text(servico.servicoType.icon)
                        .font(.system(size: 40))
                    
                    Text(servico.name)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Text(servico.status.rawValue)
                        .font(.system(size: 9, weight: .black))
                        .tracking(3)
                        .foregroundColor(servico.status == .ativo ? .sgoGreen : .sgoRed)
                        .textCase(.uppercase)
                }
            }
        }
    }
    
    // MARK: - Info Grid
    
    private var infoGrid: some View {
        VStack(spacing: 10) {
            SGOSectionHeader(title: "Informações", subtitle: nil)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                InfoTile(icon: "mappin.circle.fill", label: "Localização", value: servico.location)
                InfoTile(icon: "map.fill", label: "Distrito", value: servico.distrito ?? "—")
                InfoTile(icon: "calendar", label: "Início", value: String(servico.startDate.prefix(10)))
                InfoTile(icon: "calendar.badge.clock", label: "Fim", value: String(servico.endDate.prefix(10)))
                InfoTile(icon: "water.waves", label: "Tipologia", value: servico.tipologiaAguas)
                InfoTile(icon: "person.2.fill", label: "Equipa", value: "\(servico.teamSize) membros")
            }
        }
    }
    
    // MARK: - Schedule
    
    private var scheduleSection: some View {
        VStack(spacing: 10) {
            SGOSectionHeader(title: "Horário Semanal", subtitle: nil, color: .sgoBlack)
            
            VStack(spacing: 6) {
                if let schedule = servico.weeklySchedule {
                    ScheduleRow(day: "Segunda", data: schedule.monday)
                    ScheduleRow(day: "Terça", data: schedule.tuesday)
                    ScheduleRow(day: "Quarta", data: schedule.wednesday)
                    ScheduleRow(day: "Quinta", data: schedule.thursday)
                    ScheduleRow(day: "Sexta", data: schedule.friday)
                    ScheduleRow(day: "Sábado", data: schedule.saturday)
                    ScheduleRow(day: "Domingo", data: schedule.sunday)
                }
            }
            .padding(16)
            .sgoGlassCard(cornerRadius: 20)
        }
    }
    
    // MARK: - Team
    
    private var teamSection: some View {
        VStack(spacing: 10) {
            SGOSectionHeader(title: "Equipa", subtitle: "\(servico.lifeguardIds.count) NS · \(servico.coordinatorIds.count) Coord")
            
            VStack(spacing: 8) {
                ForEach(servico.coordinatorIds, id: \.self) { cid in
                    HStack {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .foregroundColor(.sgoOrange)
                        Text("Coordenador \(cid.prefix(6))...")
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text("COORD")
                            .font(.system(size: 8, weight: .black))
                            .tracking(2)
                            .foregroundColor(.sgoOrange)
                    }
                    .padding(12)
                    .sgoGlassCard(cornerRadius: 16)
                }
                
                ForEach(servico.lifeguardIds, id: \.self) { lid in
                    HStack {
                        Image(systemName: "figure.pool.swim")
                            .foregroundColor(.blue)
                        Text("Nadador Salvador \(lid.prefix(6))...")
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text("NS")
                            .font(.system(size: 8, weight: .black))
                            .tracking(2)
                            .foregroundColor(.blue)
                    }
                    .padding(12)
                    .sgoGlassCard(cornerRadius: 16)
                }
            }
        }
    }
    
    // MARK: - Manager
    
    private var managerSection: some View {
        VStack(spacing: 10) {
            SGOSectionHeader(title: "Gestor Responsável", subtitle: nil)
            
            VStack(alignment: .leading, spacing: 8) {
                if let nome = servico.gestorNome { InfoRow(label: "Nome", value: nome) }
                if let email = servico.gestorEmail { InfoRow(label: "Email", value: email) }
                if let tel = servico.gestorTelemovel { InfoRow(label: "Telefone", value: tel) }
            }
            .padding(16)
            .sgoGlassCard(cornerRadius: 20)
        }
    }
    
    // MARK: - Inventory
    
    private var inventorySection: some View {
        VStack(spacing: 10) {
            SGOSectionHeader(title: "Inventário", subtitle: "\(servicosVM.inventory.count) items")
            
            if servicosVM.inventory.isEmpty {
                Text("Sem itens de inventário")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.sgoTextMuted)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .sgoGlassCard(cornerRadius: 20)
            } else {
                ForEach(servicosVM.inventory) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.system(size: 13, weight: .bold))
                            Text("Qtd: \(item.quantity) · \(item.category)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.sgoTextMuted)
                        }
                        Spacer()
                        Text(item.condition)
                            .font(.system(size: 9, weight: .black))
                            .tracking(1)
                            .textCase(.uppercase)
                            .foregroundColor(conditionColor(item.condition))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(conditionColor(item.condition).opacity(0.1))
                            )
                    }
                    .padding(14)
                    .sgoGlassCard(cornerRadius: 18)
                }
            }
        }
    }
    
    private func conditionColor(_ condition: String) -> Color {
        switch condition {
        case "Bom": return .sgoGreen
        case "Razoável": return .sgoOrange
        case "Mau": return .sgoRed
        default: return .gray
        }
    }
}

// MARK: - Supporting Components

struct InfoTile: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.sgoRed)
                Text(label)
                    .font(.system(size: 9, weight: .black))
                    .tracking(2)
                    .foregroundColor(.sgoTextMuted)
                    .textCase(.uppercase)
            }
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.sgoTextPrimary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .sgoGlassCard(cornerRadius: 18)
    }
}

struct ScheduleRow: View {
    let day: String
    let data: WeeklyScheduleDay
    
    var body: some View {
        HStack {
            Text(day)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.sgoTextPrimary)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            if data.closed {
                Text("ENCERRADO")
                    .font(.system(size: 9, weight: .black))
                    .tracking(2)
                    .foregroundColor(.sgoRed)
            } else {
                Text("\(data.open) — \(data.close)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.sgoTextPrimary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .black))
                .tracking(2)
                .foregroundColor(.sgoTextMuted)
                .textCase(.uppercase)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.sgoTextPrimary)
        }
    }
}
