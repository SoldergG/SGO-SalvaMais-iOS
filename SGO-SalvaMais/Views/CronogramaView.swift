import SwiftUI

// MARK: - Cronograma Ativo

struct CronogramaView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    private var sorted: [Servico] {
        dashboardVM.servicos.sorted { a, b in
            a.startDate < b.startDate
        }
    }

    private var byMonth: [(String, [Servico])] {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let disp = DateFormatter()
        disp.dateFormat = "MMMM yyyy"
        disp.locale = Locale(identifier: "pt_PT")
        var dict: [String: [Servico]] = [:]
        for s in sorted {
            let key: String
            if let d = fmt.date(from: String(s.startDate.prefix(10))) {
                key = disp.string(from: d).capitalized
            } else {
                key = "Sem data"
            }
            dict[key, default: []].append(s)
        }
        return dict.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                if dashboardVM.servicos.isEmpty {
                    emptyState
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(byMonth, id: \.0) { month, servicos in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(month.uppercased())
                                        .font(.system(size: 9, weight: .black))
                                        .tracking(2)
                                        .foregroundColor(.sgoTextMuted)
                                        .padding(.horizontal, 4)
                                    ForEach(servicos) { s in
                                        servicoRow(s)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Cronograma Ativo")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("📅").font(.system(size: 48))
            Text("Sem serviços no cronograma")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.sgoTextMuted)
        }
    }

    @ViewBuilder
    private func servicoRow(_ s: Servico) -> some View {
        HStack(spacing: 12) {
            // Date bar
            VStack(spacing: 2) {
                Text(shortDate(s.startDate))
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.sgoRed)
                Rectangle()
                    .fill(s.isCurrentlyActive ? Color.sgoGreen : Color.gray.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                Text(shortDate(s.endDate))
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.sgoTextMuted)
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(s.servicoType.icon).font(.system(size: 16))
                    Text(s.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                }
                Text(s.location)
                    .font(.system(size: 11))
                    .foregroundColor(.sgoTextMuted)
                HStack(spacing: 8) {
                    Label("\(s.teamSize) pessoas", systemImage: "person.2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.sgoTextMuted)
                    if s.isCurrentlyActive {
                        Text("ATIVO")
                            .font(.system(size: 8, weight: .black))
                            .tracking(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.sgoGreen.opacity(0.12))
                            .foregroundColor(.sgoGreen)
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .sgoGlassCard(cornerRadius: 16)
    }

    private func shortDate(_ raw: String) -> String {
        let s = String(raw.prefix(10))
        let parts = s.split(separator: "-")
        guard parts.count == 3 else { return s }
        return "\(parts[2])/\(parts[1])"
    }
}
