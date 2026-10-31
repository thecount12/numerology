//
//  WordScanView.swift
//  Numerology
//
//  Scan a framed word with the camera (or type fallback) and compute text root.
//

import SwiftUI
import UIKit
import AVFoundation

struct WordScanView: View {
    @State private var scannedText: String = ""
    @State private var calculatedRoot: Int? = nil
    @State private var cameraAuthorized = false
    @State private var permissionChecked = false
    @State private var statusMessage: String? = nil
    @State private var showCamera = false
    
    private var cameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return UIImagePickerController.isSourceTypeAvailable(.camera)
            && AVCaptureDevice.default(for: .video) != nil
        #endif
    }
    
    var body: some View {
        Form {
            Section(header: Text("Word Source")) {
                if !permissionChecked {
                    ProgressView("Checking camera…")
                } else if cameraAvailable && cameraAuthorized {
                    Button {
                        statusMessage = nil
                        showCamera = true
                    } label: {
                        Label("Open Word Scanner", systemImage: "viewfinder")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Text("Pinch to zoom, frame one word inside the box, then tap Scan Word.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(cameraUnavailableReason)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Captured / Edited Word")) {
                TextField("Word or street text", text: $scannedText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: scannedText) {
                        calculatedRoot = NumerologyMath.textRoot(scannedText)
                    }
                
                if let statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            if let number = calculatedRoot {
                let theme = NumerologyTheme.from(number: number)
                
                Section {
                    VStack(spacing: 16) {
                        Text(scannedText)
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                        
                        Text("\(number)")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(theme.pulseColor)
                            .frame(width: 120, height: 120)
                            .background(theme.color.gradient)
                            .clipShape(Circle())
                            .shadow(color: theme.color.opacity(0.35), radius: 10, y: 5)
                        
                        Text(theme.name)
                            .font(.headline)
                        
                        Text("Text Root · letters & digits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Word Scan")
        .onAppear {
            refreshPermission()
        }
        .fullScreenCover(isPresented: $showCamera) {
            WordScanCameraContainer(
                onWordScanned: { word in
                    scannedText = word
                    calculatedRoot = NumerologyMath.textRoot(word)
                    statusMessage = nil
                    showCamera = false
                },
                onError: { message in
                    statusMessage = message
                },
                onClose: {
                    showCamera = false
                }
            )
            .ignoresSafeArea()
        }
    }
    
    private var cameraUnavailableReason: String {
        #if targetEnvironment(simulator)
        return "Camera scanning needs a real iPhone or iPad. Type a word below to calculate its root."
        #else
        if !cameraAvailable {
            return "No camera detected. Type a word below to calculate its root."
        }
        return "Camera access is off. Enable it in Settings → Numerology Calculator, or type a word below."
        #endif
    }
    
    private func refreshPermission() {
        #if targetEnvironment(simulator)
        cameraAuthorized = false
        permissionChecked = true
        return
        #else
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
            permissionChecked = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraAuthorized = granted
                    permissionChecked = true
                }
            }
        default:
            cameraAuthorized = false
            permissionChecked = true
        }
        #endif
    }
}

// MARK: - Full-screen camera shell with close button

private struct WordScanCameraContainer: View {
    let onWordScanned: (String) -> Void
    let onError: (String) -> Void
    let onClose: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            WordScanCameraView(
                onWordScanned: onWordScanned,
                onError: onError
            )
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.45))
                    .padding()
            }
            .padding(.top, 8)
        }
        .background(Color.black)
    }
}

#Preview {
    NavigationStack {
        WordScanView()
    }
}
