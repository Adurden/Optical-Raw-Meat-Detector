//
//  ViewController.swift
//  OpenCVSwift
//
//  Created by Logan Jahnke on 11/28/18.
//  Copyright © 2018 Logan Jahnke. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OpenCameraDelegate {
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var cookedPercentage: UILabel!
    
    var camera: OpenCamera!
    var isPaused: Bool = false
    var minute: UInt = 9
    var seconds: UInt = 0
    
    let appendToFile: String = ".png" // "-venison.jpg"
    let maxMinutes: UInt = 10
    let cameraMode: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup camera
        camera = OpenCamera(controller: self, andImageView: self.cameraImageView)
        
        if !self.cameraMode {
            self.cameraImageView.contentMode = .scaleAspectFit
            cameraImageView.image = UIImage(named: "0m0s\(appendToFile)")
            cameraImageView.image = camera.threshold(cameraImageView.image!)
            
            // Get percentage and set to label
            let percent_cooked = Double(self.camera.total_cooked_pixels) / Double(self.camera.total_uncooked_pixels + self.camera.total_cooked_pixels)
            let rounded = Double(round(1000 * percent_cooked) / 10)
            self.cookedPercentage.text = "\(rounded)%(m) \(calculateMeanRednessDonenessValue())%(h) cooked. (\(minute):\(seconds))"
            print("Red: \(self.camera.avg_red)\nGreen: \(self.camera.avg_green)\nBlue: \(self.camera.avg_blue)")
            
//            UIImageWriteToSavedPhotosAlbum(self.cameraImageView.image!, nil, nil, nil)
        }
        
//        while minute != 999 {
//            switchImage()
//        }
        
        // Tap
        cameraImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(switchImage))
        tap.numberOfTapsRequired = 1
        cameraImageView.addGestureRecognizer(tap)
    }
    
    // Start it when it appears
    override func viewDidAppear(_ animated: Bool) {
        if self.cameraMode {
            self.camera.start()
        }
    }
    
    // Stop it when it disappears
    override func viewWillDisappear(_ animated: Bool) {
        if self.cameraMode {
            self.camera.stop()
        }
    }

    func updatePercentage() {
        let percent_cooked = Double(self.camera.total_cooked_pixels) / Double(self.camera.total_uncooked_pixels + self.camera.total_cooked_pixels)
        let rounded = Double(round(1000 * percent_cooked) / 10)
        self.cookedPercentage.text = "\(rounded)%(m) \(calculateMeanRednessDonenessValue())%(h) cooked."
    }
    
    @objc func switchImage() {
        if !self.cameraMode {
            // Get image and threshold
            self.minute += self.seconds == 30 ? 1 : 0
            if self.minute == self.maxMinutes { self.minute = 0 }
            self.seconds = self.seconds == 0 ? 30 : 0
            self.cameraImageView.image = self.camera.threshold(UIImage(named: "\(minute)m\(seconds)s\(appendToFile)")!)
        }
        
        updatePercentage()
        
        if !self.cameraMode {
            self.cookedPercentage.text?.append(" (\(minute):\(seconds))")
            print("Red: \(self.camera.avg_red)\nGreen: \(self.camera.avg_green)\nBlue: \(self.camera.avg_blue)")
        }
        
        // If you want to save the image to the iPhone
        UIImageWriteToSavedPhotosAlbum(self.cameraImageView.image!, nil, nil, nil)
    }
    
    func calculateMeanRednessDonenessValue() -> Double {
        // Quadratic
        // y = A + Bx + Cx^2
        let A = 10.277144
        let B = -0.09767746
        let C = 0.0002294
        let x = Double(self.camera.avg_red)

        let y = A + B * x + C * (x * x)
        
        // Linear
        // y = A + Bx
//        let A = 3.162242716
//        let B = -0.01612571343
//        let x = Double(self.camera.avg_red)
//
//        let y = A + B * x
        
        if y < 0 { return 0 }
        if y > 1 { return 1 }
        return Double(round(1000 * y) / 10)
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

