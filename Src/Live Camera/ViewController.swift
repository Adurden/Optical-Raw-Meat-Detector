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
    var minute: UInt = 0
    var seconds: UInt = 0
    
    let appendToFile: String = ".png"
    let maxMinutes: UInt = 10
    let cameraMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup camera
        camera = OpenCamera(controller: self, andImageView: self.cameraImageView)
        
        if !self.cameraMode {
            cameraImageView.image = UIImage(named: "0m0s\(appendToFile)")
            cameraImageView.image = camera.threshold(cameraImageView.image!)
            
            // Get percentage and set to label
            let percent_cooked = Double(self.camera.total_cooked_pixels) / Double(self.camera.total_uncooked_pixels + self.camera.total_cooked_pixels)
            let rounded = Double(round(1000 * percent_cooked) / 10)
            self.cookedPercentage.text = "\(rounded)%(m) \(calculateMeanRednessDonenessValue())%(h) cooked. (\(minute):\(seconds))"
            print("Red: \(self.camera.avg_red)\nGreen: \(self.camera.avg_green)\nBlue: \(self.camera.avg_blue)")
        }
        
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
    }
    
    func calculateMeanRednessDonenessValue() -> Double {
        // y = A + Bx + Cx^2
        let A = 6.3418533
        let B = -0.05501809
        let C = 0.00011605
        let x = Double(self.camera.avg_red)
        
        let y = A + B * x + C * (x * x)
        if y < 0 { return 0 }
        if y > 1 { return 1 }
        return Double(round(1000 * y) / 10)
    }
}

