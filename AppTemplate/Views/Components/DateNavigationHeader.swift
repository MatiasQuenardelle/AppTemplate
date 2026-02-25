import SwiftUI

// MARK: - Date Navigation Header

struct DateNavigationHeader: View {
    @Binding var selectedDate: Date
    var showCalendarPicker: Bool = true
    var onSettingsTapped: (() -> Void)? = nil

    @State private var showDatePicker = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                if showCalendarPicker {
                    showDatePicker = true
                }
            } label: {
                Text(formattedDate)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if selectedDate.isToday {
                Text("Today")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.copperGold))
            }

            Spacer()

            if let onSettingsTapped {
                Button {
                    onSettingsTapped()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Theme.copperGold)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cardBackground)
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        )
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate)
                .presentationDetents([.medium])
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEE, MMM d")
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    @State private var tempDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $tempDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedDate = tempDate
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempDate = selectedDate
            }
        }
    }
}

#Preview {
    DateNavigationHeader(selectedDate: .constant(Date()), onSettingsTapped: {})
        .padding()
        .background(Theme.deepBlack)
        .preferredColorScheme(.dark)
}
