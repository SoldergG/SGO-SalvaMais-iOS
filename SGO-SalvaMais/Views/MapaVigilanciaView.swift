import SwiftUI
import MapKit
import CoreLocation

// MARK: - Location Manager

final class LocationPermissionManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()
    @Published var status: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        status = manager.authorizationStatus
    }

    func requestPermission() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
    }
}

// MARK: - Mapa de Vigilância

struct MapaVigilanciaView: View {
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationMgr = LocationPermissionManager()

    @State private var annotations: [ServicoAnnotation] = []
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.5, longitude: -8.0),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )
    )
    @State private var isGeocoding = false
    @State private var selectedFilter = "Todos"
    private let filters = ["Todos", "Ativo", "Inativo"]

    var filteredServicos: [Servico] {
        switch selectedFilter {
        case "Ativo": return dashboardVM.servicos.filter { $0.status == .ativo }
        case "Inativo": return dashboardVM.servicos.filter { $0.status != .ativo }
        default: return dashboardVM.servicos
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Filter pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filters, id: \.self) { f in
                                Button {
                                    selectedFilter = f
                                    Task { await geocodeServicos() }
                                } label: {
                                    Text(f)
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(selectedFilter == f ? Color.sgoRed : Color.white.opacity(0.7))
                                        .foregroundColor(selectedFilter == f ? .white : .sgoTextPrimary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }

                    // Map
                    Map(position: $mapPosition) {
                        ForEach(annotations) { ann in
                            Annotation(ann.name, coordinate: ann.coordinate) {
                                VStack(spacing: 2) {
                                    Text(ann.icon)
                                        .font(.system(size: 22))
                                    Text(ann.name)
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.sgoBlack)
                                        .lineLimit(1)
                                        .padding(.horizontal, 4)
                                        .background(Color.white.opacity(0.85))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        if locationMgr.status == .authorizedWhenInUse || locationMgr.status == .authorizedAlways {
                            UserAnnotation()
                        }
                    }
                    .frame(height: 300)

                    if isGeocoding {
                        HStack(spacing: 8) {
                            ProgressView().tint(.sgoRed).scaleEffect(0.8)
                            Text("A carregar localizações...")
                                .font(.system(size: 11))
                                .foregroundColor(.sgoTextMuted)
                        }
                        .padding(10)
                    }

                    // List
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(filteredServicos) { s in
                                HStack(spacing: 12) {
                                    Text(s.servicoType.icon)
                                        .font(.system(size: 22))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(s.name)
                                            .font(.system(size: 13, weight: .semibold))
                                        Text(s.location)
                                            .font(.system(size: 11))
                                            .foregroundColor(.sgoTextMuted)
                                    }
                                    Spacer()
                                    Text(s.status.rawValue)
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(statusColor(s.status).opacity(0.12))
                                        .foregroundColor(statusColor(s.status))
                                        .clipShape(Capsule())
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .sgoGlassCard(cornerRadius: 16)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Mapa de Vigilância")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") { dismiss() }.foregroundColor(.sgoRed)
                }
            }
        }
        .task {
            locationMgr.requestPermission()
            await geocodeServicos()
        }
    }

    private func statusColor(_ s: ServicoStatus) -> Color {
        switch s {
        case .ativo: return .sgoGreen
        case .inativo: return .sgoRed
        case .concluido: return .gray
        }
    }

    private func geocodeServicos() async {
        isGeocoding = true
        var result: [ServicoAnnotation] = []
        let geocoder = CLGeocoder()
        for s in filteredServicos.prefix(20) {
            let addr = s.location.isEmpty ? (s.distrito ?? "Portugal") : "\(s.location), Portugal"
            if let placemarks = try? await geocoder.geocodeAddressString(addr),
               let loc = placemarks.first?.location {
                result.append(ServicoAnnotation(
                    id: s.id,
                    name: s.name,
                    icon: s.servicoType.icon,
                    coordinate: loc.coordinate
                ))
            }
        }
        annotations = result
        isGeocoding = false
    }
}

struct ServicoAnnotation: Identifiable {
    let id: String
    let name: String
    let icon: String
    let coordinate: CLLocationCoordinate2D
}
