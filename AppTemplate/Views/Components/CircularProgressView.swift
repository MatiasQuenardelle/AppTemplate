import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: [Color]

    init(progress: Double, lineWidth: CGFloat = 20, gradient: [Color] = [.blue, .cyan]) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.gradient = gradient
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: lineWidth
                )

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradient),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        CircularProgressView(progress: 0.7)
            .frame(width: 150, height: 150)

        CircularProgressView(progress: 0.5, lineWidth: 15, gradient: [.green, .mint])
            .frame(width: 100, height: 100)
    }
}
