//
//  ViewController.swift
//  MLImageRecognition
//
//  Created by Berke Topcu on 9.11.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        //Seçilmiş UIImage'ı CIImage'a çevirdik ve bunu fonksiyonda oluşturduğumuz parametre olarak verdik.
        
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
        
    }
    
    func recognizeImage(image:CIImage) {
        
        //1-Request
        //2-Handler
        resultLabel.text = "Finding.."
        //Projemizin içine yüklemiş olduğumuz MobileNetV2 Modelimize ulaşıp bir değişkene atadık.
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            //Request Start
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            //0 ile 1 arasında gelen doğrulama oranını 100 üzerinden alabilmek için çarptık
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel * 100) / 100
                            
                            self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                        }
                    }
                    
                }
            }
            //Request End
            
            //Handle Start
            //Handle oluşturduk ve requestimizi ele aldık.
            let handler = VNImageRequestHandler(ciImage: image)
            //DispatchQueue global > DispatchQueue main
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
        }
    }
    
    
    
}

