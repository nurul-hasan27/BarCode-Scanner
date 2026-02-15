//
//  ScannerView.swift
//  BarCodeScanner
//
//  Created by Nurul Hasan on 13/02/26.
//

import SwiftUI

// This wraps ScannerVC into SwiftUI.
struct ScannerView: UIViewControllerRepresentable {
    
    // These connect to parent SwiftUI view.
    @Binding var scannedCode: String
    @Binding var alertItem: AlertItem?
    
    // Creates ScannerVC and sets delegate = Coordinator.
    func makeUIViewController(context: Context) -> ScannerVC {
        ScannerVC(scannerDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)
    }
    
    // This connects UIKit → SwiftUI.
    final class Coordinator: NSObject, ScannerVCDelegate {
        
        private let scannerView: ScannerView
        
        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        func didFind(barcode: String) {
            scannerView.scannedCode = barcode
            print(barcode)
        }
        
        func didSurface(error: CameraError) {
            switch error {
            case .invalidDeviceInput:
                scannerView.alertItem = AlertContext.invalidDeviceInput
            case .invalidScannedValue:
                scannerView.alertItem = AlertContext.invalidScannedType
            }
//            print(error)
        }
    }
}
