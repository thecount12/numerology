//
//  WordScanCameraView.swift
//  Numerology
//
//  Live camera with center reticle, pinch-zoom, and crop-to-OCR shutter.
//

import SwiftUI
import UIKit
import AVFoundation

struct WordScanCameraView: UIViewControllerRepresentable {
    var onWordScanned: (String) -> Void
    var onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> WordScanCameraViewController {
        let controller = WordScanCameraViewController()
        controller.onWordScanned = onWordScanned
        controller.onError = onError
        return controller
    }
    
    func updateUIViewController(_ uiViewController: WordScanCameraViewController, context: Context) {}
}

final class WordScanCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var onWordScanned: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?
    private var isCapturing = false
    
    private let reticleView = UIView()
    private let dimOverlay = ReticleDimView()
    private let hintLabel = UILabel()
    private let shutterButton = UIButton(type: .system)
    private let activity = UIActivityIndicatorView(style: .large)
    
    /// Normalized reticle size relative to preview (width × height)
    private let reticleNormalizedSize = CGSize(width: 0.72, height: 0.18)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
        configureOverlay()
        configureGestures()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        layoutReticle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSessionIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }
    
    // MARK: - Session
    
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            onError?("No camera available on this device.")
            session.commitConfiguration()
            return
        }
        captureDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            device.unlockForConfiguration()
        } catch {
            onError?("Could not start the camera: \(error.localizedDescription)")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.insertSublayer(preview, at: 0)
        previewLayer = preview
    }
    
    private func startSessionIfNeeded() {
        guard !session.isRunning, !session.inputs.isEmpty else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    // MARK: - Overlay UI
    
    private func configureOverlay() {
        dimOverlay.translatesAutoresizingMaskIntoConstraints = false
        dimOverlay.isUserInteractionEnabled = false
        view.addSubview(dimOverlay)
        NSLayoutConstraint.activate([
            dimOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            dimOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        reticleView.layer.borderColor = UIColor.white.cgColor
        reticleView.layer.borderWidth = 2.5
        reticleView.layer.cornerRadius = 12
        reticleView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        reticleView.isUserInteractionEnabled = false
        view.addSubview(reticleView)
        
        hintLabel.text = "Pinch to zoom · Frame one word · Tap scan"
        hintLabel.textColor = .white
        hintLabel.font = .preferredFont(forTextStyle: .footnote)
        hintLabel.textAlignment = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintLabel)
        
        var config = UIButton.Configuration.filled()
        config.title = "Scan Word"
        config.image = UIImage(systemName: "viewfinder")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor.systemPurple
        config.baseForegroundColor = .white
        shutterButton.configuration = config
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        view.addSubview(shutterButton)
        
        activity.color = .white
        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activity)
        
        NSLayoutConstraint.activate([
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: shutterButton.topAnchor, constant: -16),
            hintLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            hintLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            shutterButton.heightAnchor.constraint(equalToConstant: 48),
            shutterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func layoutReticle() {
        let bounds = view.bounds
        let width = bounds.width * reticleNormalizedSize.width
        let height = bounds.height * reticleNormalizedSize.height
        reticleView.frame = CGRect(
            x: (bounds.width - width) / 2,
            y: (bounds.height - height) / 2,
            width: width,
            height: height
        )
        dimOverlay.reticleFrame = reticleView.frame
        dimOverlay.setNeedsDisplay()
    }
    
    private func configureGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinch)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let device = captureDevice else { return }
        let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 8.0)
        let minZoom: CGFloat = 1.0
        
        if gesture.state == .changed || gesture.state == .began {
            let newZoom = min(maxZoom, max(minZoom, device.videoZoomFactor * gesture.scale))
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = newZoom
                device.unlockForConfiguration()
            } catch {}
            gesture.scale = 1
        }
    }
    
    // MARK: - Capture + OCR
    
    @objc private func shutterTapped() {
        guard !isCapturing else { return }
        isCapturing = true
        activity.startAnimating()
        shutterButton.isEnabled = false
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            finishCapture(errorMessage: "Capture failed: \(error.localizedDescription)")
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let rawImage = UIImage(data: data) else {
            finishCapture(errorMessage: "Could not read the captured frame.")
            return
        }
        
        let fullImage = rawImage.normalizedUp()
        
        guard let cropped = cropToReticle(fullImage) else {
            finishCapture(errorMessage: "Could not crop the reticle region.")
            return
        }
        
        Task { [weak self] in
            let word = await WordOCR.recognizePrimaryWord(in: cropped)
            await MainActor.run {
                guard let self else { return }
                if let word, !word.isEmpty {
                    self.onWordScanned?(word)
                    self.finishCapture(errorMessage: nil)
                } else {
                    self.finishCapture(errorMessage: "No word found in the frame. Zoom in and try again.")
                }
            }
        }
    }
    
    private func finishCapture(errorMessage: String?) {
        isCapturing = false
        activity.stopAnimating()
        shutterButton.isEnabled = true
        if let errorMessage {
            onError?(errorMessage)
        }
    }
    
    /// Map the on-screen reticle into the captured image and crop.
    private func cropToReticle(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let viewSize = view.bounds.size
        guard viewSize.width > 0, viewSize.height > 0 else { return nil }
        
        // Aspect-fill mapping from view → image
        let scale = max(imageSize.width / viewSize.width, imageSize.height / viewSize.height)
        let displayedSize = CGSize(width: viewSize.width * scale, height: viewSize.height * scale)
        let offsetX = (imageSize.width - displayedSize.width) / 2
        let offsetY = (imageSize.height - displayedSize.height) / 2
        
        let reticle = reticleView.frame
        var cropRect = CGRect(
            x: reticle.origin.x * scale + offsetX,
            y: reticle.origin.y * scale + offsetY,
            width: reticle.width * scale,
            height: reticle.height * scale
        )
        
        // Expand slightly so edge letters aren't clipped
        cropRect = cropRect.insetBy(dx: -cropRect.width * 0.04, dy: -cropRect.height * 0.12)
        cropRect = cropRect.intersection(CGRect(origin: .zero, size: imageSize))
        
        guard cropRect.width > 8, cropRect.height > 8,
              let croppedCG = cgImage.cropping(to: cropRect.integral) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
    }
}

private extension UIImage {
    /// Draw the image upright so Vision OCR and reticle crop share the same space.
    func normalizedUp() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Dimmed mask outside the reticle

private final class ReticleDimView: UIView {
    var reticleFrame: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(UIColor.black.withAlphaComponent(0.45).cgColor)
        context.fill(bounds)
        context.setBlendMode(.clear)
        context.fill(reticleFrame.insetBy(dx: -1, dy: -1))
    }
}
