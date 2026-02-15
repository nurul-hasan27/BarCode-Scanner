//
//  ContentView.swift
//  BarCodeScanner
//
//  Created by Nurul Hasan on 11/02/26.
//

import SwiftUI
import UIKit


struct AlertItem: Identifiable {
    let id = UUID()
    let title : String
    let message : String
    let dismissButton : Alert.Button
}

struct AlertContext {
    static let invalidDeviceInput = AlertItem(title: "Invalid Device Input",
                                              message: "Something is wrong with the camera, we are unable to capture input",
                                              dismissButton: .default(Text("OK")))
    
    static let invalidScannedType = AlertItem(title: "Invalid Scan Type",
                                              message: "The value scanned is not valid",
                                              dismissButton: .default(Text("OK")))
    
    static let copied = AlertItem(
            title: "Copied",
            message: "Barcode copied to clipboard.",
            dismissButton: .default(Text("OK"))
        )
}

struct BarcodeScannerView: View {
    
    @State private var scannedCode = ""
    @State private var alertItem : AlertItem?

    
    var body: some View {
        NavigationStack{
            VStack{
                ScannerView(scannedCode: $scannedCode, alertItem: $alertItem)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(1.0), radius: 20, x: 0, y: 0)
                    .padding(10)
                
                Spacer().frame(height: 50)
                
                Label("Scanned Barcode :", systemImage: "barcode.viewfinder")
                    .font(.title)
                
                Text(scannedCode.isEmpty ? "Not Yet Scanned" : scannedCode)
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(scannedCode.isEmpty ? .red : .green)
                    .padding(10)
                    .onTapGesture {
                        guard !scannedCode.isEmpty else { return }
                        UIPasteboard.general.string = scannedCode
                        alertItem = AlertContext.copied
                    }
            }
            .navigationTitle("Scanly")
            .alert(item:$alertItem){alertItem in
                Alert(title: Text(alertItem.title),
                      message: Text(alertItem.message),
                      dismissButton: alertItem.dismissButton)
            }

        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    BarcodeScannerView()
}
