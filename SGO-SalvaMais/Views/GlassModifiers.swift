import SwiftUI

// MARK: - S+GO Liquid Glass Design System

// App brand colors
extension Color {
    static let sgoAmber = Color(red: 253/255, green: 230/255, blue: 138/255)       // #fde68a
    static let sgoRed = Color(red: 220/255, green: 38/255, blue: 38/255)           // #dc2626
    static let sgoBlack = Color(red: 10/255, green: 10/255, blue: 10/255)
    static let sgoCardBg = Color.white
    static let sgoTextPrimary = Color.black
    static let sgoTextSecondary = Color(red: 120/255, green: 120/255, blue: 120/255)
    static let sgoTextMuted = Color(red: 160/255, green: 160/255, blue: 160/255)
    static let sgoGreen = Color(red: 34/255, green: 197/255, blue: 94/255)
    static let sgoOrange = Color.orange
    static let sgoPurple = Color.purple
}

// MARK: - Glass Card Modifier

struct SGOGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 28
    var opacity: CGFloat = 0.95
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white.opacity(opacity))
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.2),
                                Color.sgoRed.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Glass Button Modifier

struct SGOGlassButton: ViewModifier {
    var isDestructive: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 11, weight: .black))
            .textCase(.uppercase)
            .tracking(2)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(isDestructive ? Color.sgoRed : Color.sgoBlack)
                    .shadow(color: (isDestructive ? Color.sgoRed : Color.sgoBlack).opacity(0.3), radius: 12, x: 0, y: 6)
            )
            .foregroundColor(.white)
    }
}

// MARK: - Glass Input Field

struct SGOGlassField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .bold))
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemGray6).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1.5)
                    )
            )
    }
}

// MARK: - View Extensions

extension View {
    func sgoGlassCard(cornerRadius: CGFloat = 28, opacity: CGFloat = 0.95) -> some View {
        modifier(SGOGlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    func sgoGlassButton(isDestructive: Bool = false) -> some View {
        modifier(SGOGlassButton(isDestructive: isDestructive))
    }
    
    func sgoGlassField() -> some View {
        modifier(SGOGlassField())
    }
}

// MARK: - Section Header

struct SGOSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var color: Color = .sgoRed
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: 32)
                .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(color)
                    .textCase(.uppercase)
                    .tracking(3)
                
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.sgoTextMuted)
                        .textCase(.uppercase)
                        .tracking(2)
                }
            }
            
            Spacer()
            
            Rectangle()
                .fill(color.opacity(0.15))
                .frame(height: 1)
        }
    }
}

// MARK: - Glass Stat Card

struct SGOStatCard: View {
    let value: String
    let label: String
    var icon: String? = nil
    var color: Color = .sgoBlack
    
    var body: some View {
        VStack(spacing: 8) {
            if let ic = icon {
                Text(ic)
                    .font(.system(size: 28))
            }
            
            Text(value)
                .font(.system(size: 42, weight: .ultraLight))
                .tracking(-2)
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.sgoTextMuted)
                .textCase(.uppercase)
                .tracking(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .sgoGlassCard(cornerRadius: 28)
    }
}

// MARK: - Glass Tool Card

struct SGOToolCard: View {
    let title: String
    let subtitle: String
    let icon: String
    var statusLabel: String? = nil
    var statusColor: Color = .sgoGreen
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 52, height: 52)
                    
                    Text(icon)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.sgoTextPrimary)
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .lineLimit(1)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.sgoTextMuted)
                        .textCase(.uppercase)
                        .tracking(1)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let status = statusLabel {
                    Text(status)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.1))
                        )
                        .textCase(.uppercase)
                        .tracking(1)
                }
            }
            .padding(20)
            .sgoGlassCard(cornerRadius: 28)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Animated Glass Orb (for loading / empty states)

struct SGOAnimatedOrb: View {
    @State private var phase: CGFloat = 0
    var size: CGFloat = 100
    var color: Color = .sgoRed
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.15), color.opacity(0.03), .clear],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.6, height: size * 1.6)
                .blur(radius: 12)
            
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.white.opacity(0.05), color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(color: color.opacity(0.15), radius: 20, x: 0, y: 10)
        }
        .scaleEffect(1.0 + sin(phase) * 0.04)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}
