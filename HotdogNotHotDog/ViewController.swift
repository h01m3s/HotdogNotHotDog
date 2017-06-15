//
//  ViewController.swift
//  HotdogNotHotDog
//
//  Created by Weijie Lin on 6/14/17.
//  Copyright © 2017 Weijie Lin. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    // Use your API Key
    let apiKey = ""
    let version = "2017-06-14"
    
    let picker = UIImagePickerController()
    var classificationResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        picker.delegate = self
    }
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        welcomeLabel.isHidden = true
        
        picker.sourceType = .savedPhotosAlbum
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
        self.navigationItem.title = ""
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg", isDirectory: false)
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
                guard let classes = classifiedImages.images.first!.classifiers.first?.classes else {
                    print("No Result Found!")
                    return
                }
                
                for index in 1..<classes.count {
                    self.classificationResults.append(classes[index].classification)
                }
                
//                print(self.classificationResults)
                
                DispatchQueue.main.async(execute: {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    })
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async(execute: { 
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.navigationItem.title = "Not Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                    })
                }
                
            })
            classificationResults.removeAll()
            dismiss(animated: true, completion: nil)
        } else {
            print("Error Picking Image")
        }
        
    }
    
    
}

