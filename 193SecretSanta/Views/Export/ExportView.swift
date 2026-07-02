import SwiftUI

struct ExportView: View {
    @StateObject private var viewModel: ExportViewModel
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    init(viewModel: ExportViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    exportBlock(title: "Share Summary", icon: "doc.text.fill", color: .appAccent) {
                        Text(viewModel.shareText)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .appSurface(.inset, cornerRadius: AppTheme.smallRadius)

                        AppPrimaryButton(title: "Share Text", icon: "square.and.arrow.up") {
                            shareItems = [viewModel.shareText]
                            showShareSheet = true
                        }
                    }

                    exportBlock(title: "Export PDF", icon: "doc.fill", color: .appAccentSecondary) {
                        if viewModel.pdfURL != nil {
                            AppSecondaryButton(title: "Share PDF Report", icon: "arrow.up.doc.fill") {
                                if let url = viewModel.pdfURL {
                                    shareItems = [url]
                                    showShareSheet = true
                                }
                            }
                        }
                    }

                    exportBlock(title: "QR Transfer", icon: "qrcode", color: Color(hex: "6bcb77")) {
                        Text("Scan on another iPhone to import (assignments reset)")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)

                        if let image = viewModel.qrImage {
                            Image(uiImage: image)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .padding(16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                                .appSurface(.raised, accent: Color(hex: "6bcb77").opacity(0.4))
                                .frame(maxWidth: .infinity)
                        }

                        AppSecondaryButton(title: "Copy QR Data", icon: "doc.on.doc") {
                            UIPasteboard.general.string = viewModel.exportPayload
                        }
                    }

                    exportBlock(title: "Import Event", icon: "square.and.arrow.down.fill", color: .orange) {
                        Text("Paste QR data from another device")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)

                        TextEditor(text: $viewModel.importPayload)
                            .frame(height: 80)
                            .foregroundColor(.appTextPrimary)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .appSurface(.inset, cornerRadius: AppTheme.smallRadius)

                        AppPrimaryButton(
                            title: "Import Event",
                            icon: "arrow.down.circle.fill",
                            isEnabled: !viewModel.importPayload.isEmpty,
                            action: viewModel.importEvent
                        )
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .appNavigationStyle(title: "Export & Import")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: viewModel.goBack)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
        .alert("Imported!", isPresented: $viewModel.showImportSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Event imported successfully.")
        }
        .alert("Import Failed", isPresented: $viewModel.showImportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.importErrorMessage)
        }
    }

    @ViewBuilder
    private func exportBlock<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        AppCard(accent: color) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    IconBadge(icon: icon, color: color)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                }
                content()
            }
        }
    }
}
