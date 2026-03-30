import SwiftUI

// MARK: - Notifications View

struct NotificationsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var dashboardVM: DashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sgoAmber.ignoresSafeArea()
                
                if dashboardVM.notifications.isEmpty {
                    VStack(spacing: 16) {
                        SGOAnimatedOrb(size: 80, color: .sgoRed)
                            .overlay(
                                Text("📭")
                                    .font(.system(size: 28))
                                    .grayscale(0.5)
                                    .opacity(0.5)
                            )
                        
                        Text("Tudo em Dia")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.sgoTextPrimary)
                        
                        Text("SEM NOTIFICAÇÕES PENDENTES")
                            .font(.system(size: 9, weight: .black))
                            .tracking(4)
                            .foregroundColor(.sgoTextMuted)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(dashboardVM.notifications) { notif in
                                NotificationCard(notification: notif) {
                                    Task {
                                        await dashboardVM.deleteNotification(notif.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Notificações")
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
                
                if !dashboardVM.notifications.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                if let uid = authVM.user?.id {
                                    await dashboardVM.markAllRead(userId: uid)
                                }
                            }
                        } label: {
                            Text("Ler Todas")
                                .font(.system(size: 10, weight: .black))
                                .tracking(1)
                                .foregroundColor(.sgoRed)
                                .textCase(.uppercase)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    if let uid = authVM.user?.id {
                        await dashboardVM.markAllRead(userId: uid)
                    }
                }
            }
        }
    }
}

// MARK: - Notification Card

struct NotificationCard: View {
    let notification: AppNotification
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(typeColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text(notification.typeIcon)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.message)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.sgoTextPrimary)
                    .lineLimit(3)
                
                Text(formattedTime)
                    .font(.system(size: 9, weight: .black))
                    .tracking(2)
                    .foregroundColor(.sgoTextMuted)
                    .textCase(.uppercase)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.sgoTextMuted)
                    .padding(8)
                    .background(Circle().fill(Color(UIColor.systemGray6)))
            }
        }
        .padding(14)
        .sgoGlassCard(cornerRadius: 20)
    }
    
    private var typeColor: Color {
        switch notification.type {
        case "incident": return .sgoOrange
        case "compliance": return .sgoRed
        default: return .blue
        }
    }
    
    private var formattedTime: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: notification.createdAt) {
            let f = DateFormatter()
            f.dateFormat = "HH:mm · dd/MM"
            return f.string(from: date)
        }
        return notification.createdAt.prefix(10).description
    }
}
