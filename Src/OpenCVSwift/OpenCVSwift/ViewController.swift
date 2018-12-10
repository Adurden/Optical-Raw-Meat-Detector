//
//  ViewController.swift
//  OpenCVSwift
//
//  Created by Logan Jahnke on 11/28/18.
//  Copyright © 2018 Logan Jahnke. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OpenCameraDelegate {
    
    // UI connections
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var cookedPercentage: UILabel!
    
    // Camera object
    var camera: OpenCamera!
    
    // DO NOT CHANGE
    let appendToFile: String = ".png"
    let maxMinutes: UInt = 10
    var minute: UInt = 0
    var seconds: UInt = 0
    
    // MARK:- CAMERA MODE
    // If using a real iPhone, you can turn on camera mode
    // which is a real-time version of the algorithm.
    let cameraMode: Bool = false
    
    /// Called when the view is first loaded
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
        }
        
        // Tap
        cameraImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(switchImage))
        tap.numberOfTapsRequired = 1
        cameraImageView.addGestureRecognizer(tap)
    }
    
    /// Start the live camera when it when it appears
    override func viewDidAppear(_ animated: Bool) {
        if self.cameraMode {
            self.camera.start()
        }
    }
    
    /// Stop the live camera when it disappears
    override func viewWillDisappear(_ animated: Bool) {
        if self.cameraMode {
            self.camera.stop()
        }
    }

    /// Updates the rounded browning ratio percentage
    func updatePercentage() {
        let percent_cooked = Double(self.camera.total_cooked_pixels) / Double(self.camera.total_uncooked_pixels + self.camera.total_cooked_pixels)
        let rounded = Double(round(1000 * percent_cooked) / 10)
        self.cookedPercentage.text = "\(rounded)%(m) \(calculateMeanRednessDonenessValue())%(h) cooked."
    }
    
    /// Enumerates through the test images
    @objc func switchImage() {
        if !self.cameraMode {
            // Get image and threshold
            self.minute += self.seconds == 30 ? 1 : 0
            if self.minute == self.maxMinutes { self.minute = 0 }
            self.seconds = self.seconds == 0 ? 30 : 0
            self.cameraImageView.image = self.camera.threshold(UIImage(named: "\(minute)m\(seconds)s\(appendToFile)")!)
        }
        
        self.updatePercentage()
        
        if !self.cameraMode {
            // Append minute and second to the label
            self.cookedPercentage.text?.append(" (\(minute):\(seconds))")
            print("Red: \(self.camera.avg_red)\nGreen: \(self.camera.avg_green)\nBlue: \(self.camera.avg_blue)")
        }
    }
    
    /// This is used for Du's algorithm
    ///
    /// - Returns: the estimated browning ratio of the meat
    func calculateMeanRednessDonenessValue() -> Double {
        // Quadratic
        // y = A + Bx + Cx^2
        let A = 10.277144
        let B = -0.09767746
        let C = 0.0002294
        let x = Double(self.camera.avg_red)

        let y = A + B * x + C * (x * x)
        
        if y < 0 { return 0 }
        if y > 1 { return 1 }
        return Double(round(1000 * y) / 10)
    }
}

