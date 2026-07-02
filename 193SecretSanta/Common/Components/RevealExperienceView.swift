import SwiftUI

struct EnvelopeRevealView: View {
    let receiverName: String
    let onRevealComplete: () -> Void

    @State private var isOpen = false
    @State private var flapRotation: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            if !isOpen {
                Text("Tap the envelope to reveal")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)

                Button(action: openEnvelope) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appAccent)
                            .frame(width: 160, height: 100)
                        Text("✉️")
                            .font(.system(size: 48))
                        EnvelopeFlap()
                            .rotation3DEffect(.degrees(flapRotation), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
                            .offset(y: -20)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Text("🎁")
                        .font(.system(size: 48))
                    Text("You are gifting to:")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                    Text(receiverName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appAccent)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5), value: isOpen)
    }

    private func openEnvelope() {
        withAnimation(.easeInOut(duration: 0.4)) {
            flapRotation = -180
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isOpen = true
            onRevealComplete()
        }
    }
}

struct EnvelopeFlap: View {
    var body: some View {
        Triangle()
            .fill(Color.appAccentSecondary)
            .frame(width: 160, height: 50)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct ScratchCardRevealView: View {
    let receiverName: String
    let onRevealComplete: () -> Void

    @State private var scratchPoints: [CGPoint] = []
    @State private var isRevealed = false

    var body: some View {
        VStack(spacing: 12) {
            Text(isRevealed ? "Revealed!" : "Scratch to reveal")
                .font(.caption)
                .foregroundColor(.appTextSecondary)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appAccent)
                    .frame(height: 120)
                    .overlay(
                        Text(receiverName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appBackground)
                    )

                if !isRevealed {
                    ScratchOverlay(points: $scratchPoints, onThresholdReached: {
                        isRevealed = true
                        onRevealComplete()
                    })
                    .frame(height: 120)
                    .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ScratchOverlay: View {
    @Binding var points: [CGPoint]
    let onThresholdReached: () -> Void

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.gray.opacity(0.9)))
            for point in points {
                let rect = CGRect(x: point.x - 20, y: point.y - 20, width: 40, height: 40)
                context.blendMode = .clear
                context.fill(Path(ellipseIn: rect), with: .color(.clear))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    points.append(value.location)
                    if points.count > 40 {
                        onThresholdReached()
                    }
                }
        )
    }
}

struct PasscodeGateView: View {
    @Binding var passcode: String
    let onUnlock: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("🔒 Enter Passcode")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            SecureField("Passcode", text: $passcode)
                .padding()
                .background(Color.appSurface)
                .cornerRadius(10)
                .foregroundColor(.appTextPrimary)
            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .foregroundColor(.appTextSecondary)
                Button("Unlock", action: onUnlock)
                    .foregroundColor(.appAccent)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color.appBackground)
        .cornerRadius(16)
        .padding()
    }
}

struct DateLockedView: View {
    let eventDate: Date

    var body: some View {
        VStack(spacing: 12) {
            Text("🔒")
                .font(.system(size: 40))
            Text("Reveal locked until event day")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            Text(eventDate.formattedEventDate())
                .font(.subheadline)
                .foregroundColor(.appAccent)
        }
        .padding()
    }
}
