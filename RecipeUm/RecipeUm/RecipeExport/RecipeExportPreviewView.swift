//
//  RecipeExportPreviewView.swift
//  RecipeUm
//
//  Created by Codex on 8/27/26.
//

import Foundation
import Photos
import SwiftUI
import UIKit

struct RecipeExportPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let snapshot: RecipeExportSnapshot

    @State private var selectedTemplate: RecipeExportTemplate = .receipt
    @State private var includePersonalNotes: Bool
    @State private var includeSourceMetadata: Bool
    @State private var exportActionInProgress: ExportAction?
    @State private var sharedImage: SharedImage?
    @State private var exportErrorMessage: String?
    @State private var saveConfirmationMessage: String?
    @State private var exportWidth: CGFloat = 360

    init(snapshot: RecipeExportSnapshot) {
        self.snapshot = snapshot
        _includePersonalNotes = State(initialValue: snapshot.personalNotes != nil)
        _includeSourceMetadata = State(initialValue: false)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                templatePicker
                exportOptions

                GeometryReader { geometry in
                    ScrollView {
                        RecipeExportCardView(snapshot: exportSnapshot, template: selectedTemplate)
                            .frame(width: cardWidth(for: geometry.size.width))
                            .padding(.horizontal, horizontalPreviewPadding)
                            .padding(.vertical, 22)
                    }
                    .frame(maxWidth: .infinity)
                    .background(RecipeTheme.background)
                    .onAppear {
                        exportWidth = cardWidth(for: geometry.size.width)
                    }
                    .onChange(of: geometry.size.width) { _, newWidth in
                        exportWidth = cardWidth(for: newWidth)
                    }
                }
            }
            .navigationTitle("내보내기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        saveSelectedTemplateToPhotos()
                    } label: {
                        Label("사진에 저장", systemImage: "square.and.arrow.down")
                    }
                    .disabled(exportActionInProgress != nil)

                    Button {
                        exportSelectedTemplate()
                    } label: {
                        Label("공유", systemImage: "square.and.arrow.up")
                    }
                    .disabled(exportActionInProgress != nil)
                }
            }
        }
        .sheet(item: $sharedImage) { sharedImage in
            ShareSheet(activityItems: [sharedImage.image])
        }
        .alert("내보내기 실패", isPresented: isShowingExportError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(exportErrorMessage ?? "다시 시도해 주세요.")
        }
        .alert("저장 완료", isPresented: isShowingSaveConfirmation) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(saveConfirmationMessage ?? "사진 앱에 저장했습니다.")
        }
    }

    private var templatePicker: some View {
        Picker("템플릿", selection: $selectedTemplate) {
            ForEach(RecipeExportTemplate.allCases) { template in
                Text(template.displayName).tag(template)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(.bar)
    }

    @ViewBuilder
    private var exportOptions: some View {
        if snapshot.personalNotes != nil || snapshot.source?.hasDisplayContent == true {
            HStack {
                HStack(spacing: 14) {
                    if snapshot.personalNotes != nil {
                        exportOptionToggle("내 메모", isOn: $includePersonalNotes)
                    }

                    if snapshot.source?.hasDisplayContent == true {
                        exportOptionToggle("출처", isOn: $includeSourceMetadata)
                    }
                }

                Spacer(minLength: 0)
            }
            .font(.subheadline.weight(.semibold))
            .toggleStyle(.switch)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 12)
            .background(.bar)
        }
    }

    private func exportOptionToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 6) {
            Text(title)
            Toggle(title, isOn: isOn)
                .labelsHidden()
        }
    }

    private var horizontalPreviewPadding: CGFloat {
        16
    }

    private var isShowingExportError: Binding<Bool> {
        Binding(
            get: { exportErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    exportErrorMessage = nil
                }
            }
        )
    }

    private var isShowingSaveConfirmation: Binding<Bool> {
        Binding(
            get: { saveConfirmationMessage != nil },
            set: { isPresented in
                if !isPresented {
                    saveConfirmationMessage = nil
                }
            }
        )
    }

    private var exportSnapshot: RecipeExportSnapshot {
        snapshot.applyingExportOptions(
            includesPersonalNotes: includePersonalNotes,
            includesSourceMetadata: includeSourceMetadata
        )
    }

    private func cardWidth(for availableWidth: CGFloat) -> CGFloat {
        max(280, availableWidth - horizontalPreviewPadding * 2)
    }

    private func exportSelectedTemplate() {
        guard exportActionInProgress == nil else {
            return
        }

        exportActionInProgress = .share
        defer { exportActionInProgress = nil }

        do {
            let exportedImage = try RecipeImageExporter().exportImage(
                snapshot: exportSnapshot,
                template: selectedTemplate,
                width: exportWidth,
                dynamicTypeSize: dynamicTypeSize
            )
            sharedImage = SharedImage(image: exportedImage.image)
        } catch {
            exportErrorMessage = error.localizedDescription
        }
    }

    private func saveSelectedTemplateToPhotos() {
        guard exportActionInProgress == nil else {
            return
        }

        exportActionInProgress = .saveToPhotos

        do {
            let exportedImage = try RecipeImageExporter().exportImage(
                snapshot: exportSnapshot,
                template: selectedTemplate,
                width: exportWidth,
                dynamicTypeSize: dynamicTypeSize
            )
            saveToPhotos(exportedImage.image)
        } catch {
            exportActionInProgress = nil
            exportErrorMessage = error.localizedDescription
        }
    }

    private func saveToPhotos(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            Task { @MainActor in
                guard status == .authorized || status == .limited else {
                    exportActionInProgress = nil
                    exportErrorMessage = "사진 추가 권한이 필요합니다."
                    return
                }

                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    Task { @MainActor in
                        exportActionInProgress = nil

                        if success {
                            saveConfirmationMessage = "사진 앱에 저장했습니다."
                        } else {
                            exportErrorMessage = error?.localizedDescription ?? "사진에 저장할 수 없습니다."
                        }
                    }
                }
            }
        }
    }
}

private enum ExportAction {
    case share
    case saveToPhotos
}

private struct SharedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

#Preview {
    RecipeExportPreviewView(snapshot: .preview)
}
