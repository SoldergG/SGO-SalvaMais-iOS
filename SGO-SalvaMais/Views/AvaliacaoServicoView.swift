import SwiftUI

// MARK: - Avaliação do Serviço

struct AvaliacaoServicoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dashboardVM: DashboardViewModel

    @State private var evaluations: [Evaluation] = []
    @State private var isLoading = false
    @State private var searchText = ""

    private var filtered: [Evaluation] {
        guard !searchText.isEmpty else { return evaluations }
        return evaluations.filter {
            $0.clientName.localizedCaseInsensitiveContains(searchText) ||
            $0.entityName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.sgoTextMuted)
                        TextField("Pesquisar avaliação...", text: $searchText)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    if isLoading {
                        Spacer()
                        ProgressView().tint(.sgoRed)
                        Spacer()
                    } else if filtered.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Text("⭐").font(.system(size: 44))
                            Text(evaluations.isEmpty ? "Sem avaliações registadas" : "Sem resultados")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.sgoTextMuted)
                        }
                        Spacer()
                    } else {
                        // Summary stats
                        let rehireYes = evaluations.filter { $0.wouldRehire.lowercased() == "sim" || $0.wouldRehire.lowercased() == "yes" }.count
                        HStack(spacing: 0) {
                            statBadge("\(evaluations.count)", "Total")
                            statBadge("\(rehireYes)", "Recontratar")
                            statBadge(evaluations.count > 0 ? "\(Int(Double(rehireYes)/Double(evaluations.count)*100))%" : "—", "Satisfação")
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 8) {
                                ForEach(filtered) { eval in
                                    evalRow(eval)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("Avaliações")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
        .task { await loadEvaluations() }
    }

    @ViewBuilder
    private func evalRow(_ e: Evaluation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.sgoOrange.opacity(0.12))
                    .frame(width: 44, height: 44)
                    .overlay(Text("⭐").font(.system(size: 20)))

                VStack(alignment: .leading, spacing: 3) {
                    Text(e.clientName.isEmpty ? "Cliente" : e.clientName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.sgoTextPrimary)
                    if !e.entityName.isEmpty {
                        Text(e.entityName)
                            .font(.system(size: 11))
                            .foregroundColor(.sgoTextMuted)
                    }
                }
                Spacer()
                let isYes = e.wouldRehire.lowercased() == "sim" || e.wouldRehire.lowercased() == "yes"
                Text(isYes ? "✅ Recontratar" : "❌ Não")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isYes ? Color.sgoGreen.opacity(0.12) : Color.sgoRed.opacity(0.12))
                    .foregroundColor(isYes ? .sgoGreen : .sgoRed)
                    .clipShape(Capsule())
            }
            if !e.comments.isEmpty {
                Text(e.comments)
                    .font(.system(size: 11))
                    .foregroundColor(.sgoTextMuted)
                    .lineLimit(3)
                    .padding(.leading, 56)
            }
            if !e.submissionDate.isEmpty {
                Text(e.submissionDate.prefix(10))
                    .font(.system(size: 9))
                    .foregroundColor(.sgoTextMuted.opacity(0.7))
                    .padding(.leading, 56)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .sgoGlassCard(cornerRadius: 16)
    }

    @ViewBuilder
    private func statBadge(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundColor(.sgoTextPrimary)
            Text(label)
                .font(.system(size: 8, weight: .black))
                .tracking(1)
                .foregroundColor(.sgoTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 3)
    }

    private func loadEvaluations() async {
        isLoading = true
        evaluations = (try? await APIService.shared.getEvaluations()) ?? []
        isLoading = false
    }
}
