//
//  ScannerScreen.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation
import SwiftUI
import VisionKit

struct ScannerScreen: UIViewControllerRepresentable {

    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType

    func makeUIViewController(context: Context) -> DataScannerViewController {

        DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isGuidanceEnabled: false,
            isHighlightingEnabled: true
        )
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {

        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {

        uiViewController.stopScanning()
        uiViewController.delegate = nil
    }
}

extension ScannerScreen {

    class Coordinator: NSObject, DataScannerViewControllerDelegate {

        @Binding var recognizedItems: [RecognizedItem]

        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }

        func dataScannerDidZoom(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {}

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            recognizedItems = addedItems
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {}

        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {}
    }
}
