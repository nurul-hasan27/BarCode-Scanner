//
//  ScannerVC.swift
//  BarCodeScanner
//
//  Created by Nurul Hasan on 13/02/26.
//

import UIKit
import AVFoundation


enum CameraError {
    case invalidDeviceInput
    case invalidScannedValue
}




protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
    func didSurface(error: CameraError)
}




final class ScannerVC: UIViewController {
    
    // The engine that runs the camera.
    let captureSession = AVCaptureSession()
    // This shows the camera feed on screen.
    // Without this → camera works but nothing visible.
    var previewLayer: AVCaptureVideoPreviewLayer?
    // Used to send results back.
    // weak avoids memory leaks.
    weak var scannerDelegate: ScannerVCDelegate?
    
    // This forces you to pass a delegate when creating ScannerVC./
    init(scannerDelegate: ScannerVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    // When screen loads → Call setupCaptureSession().
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    // This makes camera fill the whole screen.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = previewLayer else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        previewLayer.frame = view.layer.bounds
    }
    
    private func setupCaptureSession() {
        // Get Camera
        // If nil → No camera → show error.
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // connects the physical camera to the capture session.
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // Now session can receive video feed.
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // This tells the system: “We are scanning barcodes.”
        let metaDataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            
            // When barcode is found → Call delegate function.
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.ean8, .ean13, .qr, .microQR]
        } else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
}



// Barcode Detection Function
extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    // This gets called automatically when something is detected.
//    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        
//        // Get first detected thing.
//        guard let object = metadataObjects.first else {
//            scannerDelegate?.didSurface(error: .invalidScannedValue)
//            return
//        }
//        
//        // Convert to MachineReadable
//        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
//            scannerDelegate?.didSurface(error: .invalidScannedValue)
//            return
//        }
//        
//        // Get String Value
//        guard let barcode = machineReadableObject.stringValue else {
//            scannerDelegate?.didSurface(error: .invalidScannedValue)
//            return
//        }
//        
//        // Notify Delegate Tell SwiftUI: "I found: 8901234567890"
//        scannerDelegate?.didFind(barcode: barcode)
//    }
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        guard let machineReadableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = machineReadableObject.stringValue else {
            return   // 🔥 DO NOTHING if nothing detected
        }
        
        scannerDelegate?.didFind(barcode: barcode)
    }

}
