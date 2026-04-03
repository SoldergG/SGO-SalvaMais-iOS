import SwiftUI

// MARK: - Inventory Overview View

struct InventoryOverviewView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    @State private var inventoryItems: [InventoryItem] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView().tint(.sgoRed).scaleEffect(1.4)
                        Text("A CARREGAR INVENTÁRIO...")
                            .font(.system(size: 9, weight: .black))
                            .tracking(3)
                            .foregroundColor(.sgoTextMuted)
                    }
                } else if inventoryItems.isEmpty {
                    VStack(spacing: 16) {
                        Text("📦")
                            .font(.system(size: 52))
                        Text("Inventário Vazio")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.sgoTextPrimary)
                        Text("Nenhum item de equipamento registado")
                            .font(.system(size: 12))
                            .foregroundColor(.sgoTextMuted)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Summary badges
                            HStack(spacing: 10) {
                                summaryBadge(
                                    count: inventoryItems.filter { $0.condition == "Bom" }.count,
                                    label: "Bom Estado",
                                    color: .sgoGreen
                                )
                                summaryBadge(
                                    count: inventoryItems.filter { $0.condition == "Razoável" }.count,
                                    label: "Razoável",
                                    color: .sgoOrange
                                )
                                summaryBadge(
                                    count: inventoryItems.filter { $0.condition == "Mau" }.count,
                                    label: "Mau Estado",
                                    color: .sgoRed
                                )
                            }

                            // Items by category
                            ForEach(groupedByCategory.keys.sorted(), id: \.self) { category in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(category.uppercased())
                                        .font(.system(size: 9, weight: .black))
                                        .tracking(2)
                                        .foregroundColor(.sgoTextMuted)
                                        .padding(.horizontal, 4)

                                    VStack(spacing: 8) {
                                        ForEach(groupedByCategory[category] ?? []) { item in
                                            itemRow(item)
                                        }
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
            .navigationTitle("Estado Inventário")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }
                        .foregroundColor(.sgoRed)
                }
            }
        }
        .task { await loadInventory() }
    }

    private var groupedByCategory: [String: [InventoryItem]] {
        Dictionary(grouping: inventoryItems, by: { $0.category })
    }

    @ViewBuilder
    private func summaryBadge(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 8, weight: .black))
                .tracking(1)
                .foregroundColor(.sgoTextMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .sgoGlassCard(cornerRadius: 20)
    }

    @ViewBuilder
    private func itemRow(_ item: InventoryItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.sgoTextPrimary)
                Text("Qtd: \(item.quantity)")
                    .font(.system(size: 11))
                    .foregroundColor(.sgoTextMuted)
            }
            Spacer()
            Text(item.condition)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(conditionColor(item.condition).opacity(0.12))
                .foregroundColor(conditionColor(item.condition))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .sgoGlassCard(cornerRadius: 16)
    }

    private func conditionColor(_ condition: String) -> Color {
        switch condition {
        case "Bom": return .sgoGreen
        case "Razoável": return .sgoOrange
        case "Mau": return .sgoRed
        default: return .gray
        }
    }

    private func loadInventory() async {
        isLoading = true
        var items: [InventoryItem] = []
        for servico in dashboardVM.servicos {
            if let fetched = try? await APIService.shared.getInventory(servicoId: servico.id) {
                items.append(contentsOf: fetched)
            }
        }
        inventoryItems = items
        isLoading = false
    }
}
