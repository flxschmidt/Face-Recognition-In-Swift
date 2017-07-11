//
//  ViewController.swift
//  FaceRecognition
//
//  Created by Felix Schmidt on 11.07.17.
//

import UIKit
import Vision // <= Don't forget to import the amazing API! :)

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Your image with faces.
        guard let image = UIImage(named: "group-of-people-1") else { return }
        let imageView = UIImageView(image: image)
        let scaledHeight = view.frame.width / image.size.width * image.size.height // keep proportions
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        // Create a request for the image that you want to check for faces.
        let faceRectanglesRequest = VNDetectFaceRectanglesRequest { (request, error) in
            
            // Handle the result back in the main thread.
            DispatchQueue.main.async {
                if error != nil {
                    print("VNDetectFaceRectanglesRequest failed: ", error ?? "")
                    return
                }
                
                // Iterate over the results array of detected faces.
                request.results?.forEach({ (result) in
                    
                    // The result should be of type VNFaceObservation.
                    guard let faceObservation = result as? VNFaceObservation else { return }
                    
                    // Be attend: the coordinates are normalized to the dimensions of the processed image,
                    // with the origin at the image's lower-left (why ever o_O) corner!
                    let faceRectX = faceObservation.boundingBox.origin.x * self.view.frame.width
                    let faceRectHeight = scaledHeight * faceObservation.boundingBox.height
                    let faceRectY = (1 - faceObservation.boundingBox.origin.y) * scaledHeight - faceRectHeight
                    let faceRectWidth = self.view.frame.width * faceObservation.boundingBox.width
                    
                    let faceRect = UIView(frame: CGRect(x: faceRectX, y: faceRectY, width: faceRectWidth, height: faceRectHeight))
                    faceRect.backgroundColor = UIColor.green.withAlphaComponent(0.3)
                    self.view.addSubview(faceRect)
                })
            }
        }
        
        // Create a request handler for the image that you want to check for faces.
        guard let cgImage = image.cgImage else { return }
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform the face detection in an asynchronous thread.
        // The image will be displayed immediately and the detection results when they're finished.
        DispatchQueue.global(qos: .background).async {
            do {
                // Let the handler perform your request you've created above.
                try imageRequestHandler.perform([faceRectanglesRequest])
            } catch let error {
                print("Request Handler Performance failed: ", error)
            }
        }
    }
}
