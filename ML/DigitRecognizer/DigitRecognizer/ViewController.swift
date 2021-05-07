//
//  ViewController.swift
//  DigitRecognizer
//
//  Created by lucas on 7/5/21.
//

import UIKit
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var drawingView: DrawingImageView!

    //var mnistModel = MNISTClassifierA()
    var mnistModel = MnistModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.drawingView.delegate = self
    }
    
    
    func numberDrawn(_ image: UIImage){
        
        //1. Redimensionar la imagen del usuario a una imagen 299 x 299 (tamaño que espera el modelo)
        //let modelSize = 299
        let modelSize = 28
        

   /*
        let size = CGSize(width: modelSize, height: modelSize)
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: image.bitsPerComponent,
                                bytesPerRow: image.bytesPerRow,
                                space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: image.bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        context?.draw(image, in: CGRect(origin: .zero, size: size))

        guard let scaledImage = context?.makeImage() else {
            fatalError("Error al redimensionar imagen")
        }
         */
        UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //2. UIImage -> CIImage
        guard let ciImage = CIImage(image: newImage) else {
            fatalError("Error al convertir de UIImage a CIImage")
        }
        
        //2.5 Desaturamos
       // let ciImageBW = ciImage.applyingFilter("CIColorControls", parameters: ["inputSaturation": 0, "inputContrast": 5])
    
    
        //3. Cargar el modelo en Vision
        guard let model = try? VNCoreMLModel( for: mnistModel.model ) else {
             fatalError("No se ha podido preparar el modelo de clasificación para Vision")
        }
        
        //4. Petición VNCoreMLRequest
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            //5. Al detectar la imagen, tenemos que saber el número que ha escrito el usuario y validar la respuesta

            guard let results = request.results as? [VNClassificationObservation], let prediction = results.first else {
                fatalError("Error al hacer la predicción: \(error?.localizedDescription ?? "Error Desconocido")")
            }
            
            DispatchQueue.main.async {
                //El resultado es la etiqueta de la clase donde el modelo ha catalogado nuestra imagen
                let result = prediction.identifier
                //Mostramos resultado
                self?.numberLabel.text=result
                print (result)
                self?.drawingView.image = nil

         }
        }
        
        //6. Justar todo en un VNImageRequestHandler
        let handler = VNImageRequestHandler(ciImage: ciImage)

        //Ejecutamos la predicción en un hilo secundario para no bloquear la UI
        DispatchQueue.global(qos: .userInteractive).async {
            do{
                try handler.perform([request])
            } catch{
                print(error.localizedDescription)
            }
        }
    }


}

