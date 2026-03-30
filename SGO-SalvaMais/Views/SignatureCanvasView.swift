import SwiftUI

// MARK: - Signature Canvas View

struct SignatureCanvasView: View {
    let title: String
    @Binding var signatureImage: UIImage?
    
    @State private var lines: [[CGPoint]] = []
    @State private var currentLine: [CGPoint] = []
    
    var body: some View {
        VStack(spacing: 12) {
            if let img = signatureImage {
                // Show saved signature
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                .foregroundColor(Color.gray.opacity(0.2))
                        )
                    
                    VStack(spacing: 12) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 140)
                            .opacity(0.8)
                        
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                signatureImage = nil
                                lines = []
                                currentLine = []
                            }
                        } label: {
                            Text("Alterar Assinatura")
                                .font(.system(size: 10, weight: .black))
                                .textCase(.uppercase)
                                .tracking(1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.sgoRed))
                        }
                    }
                    .padding(16)
                }
                .frame(height: 200)
            } else {
                // Drawing canvas
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                .foregroundColor(Color.gray.opacity(0.2))
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    
                    Canvas { context, size in
                        for line in lines {
                            drawLine(line, in: &context)
                        }
                        if !currentLine.isEmpty {
                            drawLine(currentLine, in: &context)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                currentLine.append(value.location)
                            }
                            .onEnded { _ in
                                lines.append(currentLine)
                                currentLine = []
                            }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Placeholder text
                    if lines.isEmpty && currentLine.isEmpty {
                        Text(title)
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(Color.gray.opacity(0.2))
                            .textCase(.uppercase)
                            .tracking(4)
                            .allowsHitTesting(false)
                    }
                    
                    // Clear & Save buttons
                    if !lines.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        lines = []
                                        currentLine = []
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Circle().fill(Color.gray.opacity(0.6)))
                                }
                                
                                Button {
                                    saveSignature()
                                } label: {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Circle().fill(Color.sgoGreen))
                                }
                            }
                            .padding(12)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }
    
    private func drawLine(_ points: [CGPoint], in context: inout GraphicsContext) {
        guard points.count > 1 else { return }
        var path = Path()
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        context.stroke(path, with: .color(.black), lineWidth: 3)
    }
    
    private func saveSignature() {
        let renderer = ImageRenderer(content:
            Canvas { context, size in
                for line in lines {
                    drawLine(line, in: &context)
                }
            }
            .frame(width: 400, height: 200)
            .background(Color.white)
        )
        renderer.scale = 2.0
        if let image = renderer.uiImage {
            withAnimation(.spring(response: 0.3)) {
                signatureImage = image
            }
        }
    }
}

// MARK: - UIImage to Base64

extension UIImage {
    var base64String: String? {
        guard let data = self.pngData() else { return nil }
        return data.base64EncodedString()
    }
}
