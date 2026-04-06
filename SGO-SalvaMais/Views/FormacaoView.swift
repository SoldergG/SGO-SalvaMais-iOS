import SwiftUI

// MARK: - Formação e Desenvolvimento

struct FormacaoView: View {
    @Environment(\.dismiss) var dismiss

    private let recursos: [(String, String, String, String)] = [
        ("🎓", "Curso Nadador-Salvador", "Formação inicial ISN", "https://www.amn.pt/ISN"),
        ("🔄", "Recertificação ISN", "Renovação da cédula profissional", "https://www.amn.pt/ISN"),
        ("📋", "Regulamento ISN", "Regras e normas vigentes", "https://www.amn.pt/ISN"),
        ("🎥", "Vídeos de Formação", "Material audiovisual didático", "https://www.amn.pt/ISN"),
        ("📖", "Manual de Primeiros Socorros", "Protocolos de socorro", "https://www.cruz-vermelha.pt"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Header card
                        VStack(spacing: 10) {
                            Text("🎓")
                                .font(.system(size: 44))
                            Text("Formação e Desenvolvimento")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.sgoTextPrimary)
                                .multilineTextAlignment(.center)
                            Text("Recursos oficiais ISN e materiais de formação para nadadores-salvadores")
                                .font(.system(size: 12))
                                .foregroundColor(.sgoTextMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .sgoGlassCard(cornerRadius: 24)

                        Text("RECURSOS DISPONÍVEIS")
                            .font(.system(size: 9, weight: .black))
                            .tracking(2)
                            .foregroundColor(.sgoTextMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)

                        ForEach(recursos, id: \.1) { icon, title, sub, urlStr in
                            Button {
                                if let url = URL(string: urlStr) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    Text(icon).font(.system(size: 26))
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(title)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.sgoTextPrimary)
                                        Text(sub)
                                            .font(.system(size: 11))
                                            .foregroundColor(.sgoTextMuted)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 14))
                                        .foregroundColor(.sgoRed)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .sgoGlassCard(cornerRadius: 18)
                            }
                            .buttonStyle(.plain)
                        }

                        // ISN contact
                        VStack(spacing: 8) {
                            Text("CONTACTO ISN")
                                .font(.system(size: 9, weight: .black))
                                .tracking(2)
                                .foregroundColor(.sgoTextMuted)
                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.sgoRed)
                                Text("isn@amn.pt")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.sgoTextPrimary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .sgoGlassCard(cornerRadius: 18)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Formação")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
    }
}
