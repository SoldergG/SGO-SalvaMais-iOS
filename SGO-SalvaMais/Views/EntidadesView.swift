import SwiftUI

// MARK: - Entidades - Clientes Ativos

struct EntidadesView: View {
    @Environment(\.dismiss) var dismiss

    @State private var entities: [Entity] = []
    @State private var isLoading = false
    @State private var searchText = ""

    private var filtered: [Entity] {
        guard !searchText.isEmpty else { return entities }
        return entities.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.distrito ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.sgoTextMuted)
                        TextField("Pesquisar entidade...", text: $searchText)
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
                            Text("🏛️").font(.system(size: 44))
                            Text(entities.isEmpty ? "Sem entidades registadas" : "Sem resultados")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.sgoTextMuted)
                        }
                        Spacer()
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 8) {
                                ForEach(filtered) { entity in
                                    entityRow(entity)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("Entidades")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
        .task { await loadEntities() }
    }

    @ViewBuilder
    private func entityRow(_ e: Entity) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.sgoPurple.opacity(0.12))
                .frame(width: 46, height: 46)
                .overlay(Text("🏛️").font(.system(size: 20)))

            VStack(alignment: .leading, spacing: 3) {
                Text(e.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.sgoTextPrimary)
                if let nif = e.nif, !nif.isEmpty {
                    Text("NIF: \(nif)")
                        .font(.system(size: 11))
                        .foregroundColor(.sgoTextMuted)
                }
                if let morada = e.morada, !morada.isEmpty {
                    Text(morada)
                        .font(.system(size: 10))
                        .foregroundColor(.sgoTextMuted)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let distrito = e.distrito, !distrito.isEmpty {
                Text(distrito)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color.sgoPurple.opacity(0.1))
                    .foregroundColor(.sgoPurple)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .sgoGlassCard(cornerRadius: 16)
    }

    private func loadEntities() async {
        isLoading = true
        entities = (try? await APIService.shared.getEntities()) ?? []
        isLoading = false
    }
}
