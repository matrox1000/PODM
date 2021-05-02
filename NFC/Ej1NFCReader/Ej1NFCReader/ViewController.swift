//
//  ViewController.swift
//  Ej1NFCReader
//
//  Created by lucas on 21/05/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UIViewController,  NFCNDEFReaderSessionDelegate  {
    
    var session: NFCNDEFReaderSession?
    


    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func scan(_ sender: Any) {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Acerca el iPhone a la etiqueta para leer su contenido"
        session?.begin()

    }
   
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        // A new session instance is required to read new tags.
        self.session = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            // Process detected NFCNDEFMessage objects.
            switch messages.last!.records.last!.typeNameFormat{
            case .nfcWellKnown:
                let contenido = messages.last!.records.last!.wellKnownTypeTextPayload()
                if let texto = contenido.0 {
                    self.label.text = "NFC Well Known type: " + texto
                } else {
                    self.label.text = "Invalid data"
                }
                
                
            case .empty: break
                
            case .media: break
                
            case .absoluteURI: break
                
            case .nfcExternal: break
                
            case .unknown: break
                
            case .unchanged: break
                
            @unknown default: break
                
            }
        }
    }
}

