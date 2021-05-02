//
//  ViewController.swift
//  Ej2NFCWriter
//
//  Created by lucas on 13/05/2020.
//  Copyright © 2020 lucas. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {
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
        // nada
    }
    
    
    @IBOutlet weak var texto: UITextField!
    var session: NFCNDEFReaderSession?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func write(_ sender: Any) {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Acerca el iPhone a la etiqueta para escribir en ella"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {

            if tags.count > 1 {
                // Restart polling in 500 milliseconds.
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }
            
            // Connect to the found tag and write an NDEF message to it.
            let tag = tags.first!
            session.connect(to: tag, completionHandler: { (error: Error?) in
                if nil != error {
                    session.alertMessage = "Unable to connect to tag."
                    session.invalidate()
                    return
                }
                
                tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                    guard error == nil else {
                        session.alertMessage = "Unable to query the NDEF status of tag."
                        session.invalidate()
                        return
                    }

                    switch ndefStatus {
                    case .notSupported:
                        session.alertMessage = "Tag is not NDEF compliant."
                        session.invalidate()
                    case .readOnly:
                        session.alertMessage = "Tag is read only."
                        session.invalidate()
                    case .readWrite:
                        
                        let message = NFCNDEFMessage(records: [NFCNDEFPayload.wellKnownTypeTextPayload(string: self.texto.text!, locale: .current)!])
                        tag.writeNDEF( message, completionHandler: { (error: Error?) in
                            if nil != error {
                                session.alertMessage = "Write NDEF message fail: \(error!)"
                            } else {
                                session.alertMessage = "Write NDEF message successful."
                            }
                            session.invalidate()
                        })
                    @unknown default:
                        session.alertMessage = "Unknown NDEF tag status."
                        session.invalidate()
                    }
                })
            })
            
        }
        




}

