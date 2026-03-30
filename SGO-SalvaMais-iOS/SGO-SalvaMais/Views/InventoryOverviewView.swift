import SwiftUI

// MARK: - Inventory Overview View

struct InventoryOverviewView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        if dashboardVM.allInventory.isEmpty {
                            emptyState
                        } else {
                            ForEach(dashboardVM.allInventory, id: \.servicoName) { group in
                                servicoInventorySection(name: group.servicoName, items: group.items)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Inventario")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.sgoRed)
                }
            }
            .task {
                await dashboardVM.fetchInventoryOverview()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("📦")
                .font(.system(size: 48))
            Text("Sem inventario registado")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.sgoTextMuted)
                .textCase(.uppercase)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    // MARK: - Servico Inventory Section

    private func servicoInventorySection(name: String, items: [InventoryItem]) -> some View {
        VStack(spacing: 12) {
            SGOSectionHeader(title: name, subtitle: "\(items.count) item(s)")

            ForEach(items) { item in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.sgoTextPrimary)

                        Text(item.category)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.sgoTextMuted)
                            .textCase(.uppercase)
                            .tracking(1)
                    }

                    Spacer()

                    Text("Qtd: \(item.quantity)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.sgoTextPrimary)

                    conditionBadge(item.condition)
                }
                .padding(16)
                .sgoGlassCard(cornerRadius: 20)
            }
        }
    }

    // MARK: - Condition Badge

    private func conditionBadge(_ condition: String) -> some View {
        Text(condition)
            .font(.system(size: 9, weight: .black))
            .textCase(.uppercase)
            .tracking(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(conditionColor(condition).opacity(0.15))
            )
            .foregroundColor(conditionColor(condition))
    }

    private func conditionColor(_ condition: String) -> Color {
        switch condition {
        case "Bom": return .sgoGreen
        case "Razoavel": return .sgoOrange
        case "Mau": return .sgoRed
        default: return .gray
        }
    }
}
