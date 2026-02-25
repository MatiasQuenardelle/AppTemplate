import SwiftUI
import PhotosUI
import FirebaseStorage

struct BugReportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var descriptionText = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isSubmitting = false
    @State private var showSuccess = false

    private var canSubmit: Bool {
        descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var iosVersion: String {
        UIDevice.current.systemVersion
    }

    private var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.deepBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Describe the bug")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)

                            TextEditor(text: $descriptionText)
                                .scrollContentBackground(.hidden)
                                .background(Theme.cardBackground)
                                .foregroundStyle(.white)
                                .frame(minHeight: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(alignment: .topLeading) {
                                    if descriptionText.isEmpty {
                                        Text("What happened? What did you expect?")
                                            .foregroundStyle(Theme.tertiaryText)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 12)
                                            .allowsHitTesting(false)
                                    }
                                }

                            Text("Minimum 10 characters")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.secondaryText)
                        }

                        // Image Picker
                        VStack(alignment: .leading, spacing: 8) {
                            if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Button {
                                    selectedItem = nil
                                    selectedImageData = nil
                                } label: {
                                    Label("Remove image", systemImage: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.red)
                                }
                            } else {
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    HStack {
                                        Image(systemName: "camera")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Theme.salmonAccent)
                                            .frame(width: 28)

                                        Text("Attach screenshot")
                                            .font(.system(size: 15))
                                            .foregroundStyle(.white)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Theme.tertiaryText)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(Theme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }

                        // Device Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Device Info")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)

                            VStack(spacing: 0) {
                                DeviceInfoRow(label: "App Version", value: appVersion)
                                Divider().background(Theme.tertiaryText)
                                DeviceInfoRow(label: "iOS", value: iosVersion)
                                Divider().background(Theme.tertiaryText)
                                DeviceInfoRow(label: "Device", value: deviceModel)
                            }
                            .background(Theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)

                if isSubmitting {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Report a Bug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.deepBlack, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.salmonAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        Task { await submitReport() }
                    }
                    .foregroundStyle(canSubmit ? Theme.salmonAccent : Theme.tertiaryText)
                    .disabled(!canSubmit || isSubmitting)
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .alert("Thank you!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your bug report has been submitted. We'll look into it.")
            }
        }
    }

    private func submitReport() async {
        isSubmitting = true
        defer { isSubmitting = false }

        let reportId = UUID().uuidString
        let userId = AuthenticationService.shared.currentUser?.uid ?? "anonymous"
        var imageURL: String?

        if let imageData = selectedImageData {
            let compressed = UIImage(data: imageData)?
                .jpegData(compressionQuality: 0.6) ?? imageData

            if compressed.count <= 5 * 1024 * 1024 {
                let storageRef = Storage.storage().reference()
                    .child("bugReports/\(userId)/\(reportId).jpg")

                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"

                do {
                    _ = try await storageRef.putDataAsync(compressed, metadata: metadata)
                    imageURL = try await storageRef.downloadURL().absoluteString
                } catch {
                    print("BugReport: Failed to upload image: \(error)")
                }
            }
        }

        let report = FSBugReport(
            id: reportId,
            userId: userId,
            description: descriptionText.trimmingCharacters(in: .whitespacesAndNewlines),
            imageURL: imageURL,
            appVersion: appVersion,
            iosVersion: iosVersion,
            deviceModel: deviceModel,
            locale: Locale.current.identifier,
            status: "open",
            createdAt: Date()
        )

        do {
            try await FirestoreService.shared.saveBugReport(report)
            await MainActor.run { showSuccess = true }
        } catch {
            print("BugReport: Failed to save report: \(error)")
        }
    }
}

private struct DeviceInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Theme.secondaryText)
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
