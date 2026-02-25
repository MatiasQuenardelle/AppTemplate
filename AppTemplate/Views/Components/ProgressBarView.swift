import SwiftUI

struct ProgressBarView: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(current))/\(Int(goal))\(unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)

                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 10)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 10)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(title: "Tasks", current: 3, goal: 10, unit: "", color: .blue)
        ProgressBarView(title: "Progress", current: 7, goal: 10, unit: "", color: .orange)
    }
    .padding()
}
