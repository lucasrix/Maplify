//
//  PhotoViewController.swift
//  PhotoViewController
//
//  Created by Evgeniy Antonoff on 3/30/16.
//  Copyright © 2016 Evgeniy Antonoff. All rights reserved.
//

import LLSimpleCamera
import UIKit
import CoreMedia
import AVFoundation

class PhotoViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    var simpleCamera: LLSimpleCamera! = nil
    var delegate: PhotoControllerDelegate! = nil
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setupCamera()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.simpleCamera.stop()
    }
    
    // MARK: - setup
    func setup() {
        self.setupBottomButtons()
    }
    
    func setupCamera() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { [weak self] (alowedAccess) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if alowedAccess {
                    self?.configureCamera()
                } else {
                    self?.delegate?.photoCameraUnauthorized()
                }
            })
        })
    }
    
    func configureCamera() {
        self.simpleCamera = LLSimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionRear, videoEnabled: false)
        self.simpleCamera.start()
        self.configureChildViewController(self.simpleCamera, onView: self.cameraView)
        self.simpleCamera.updateFlashMode(LLCameraFlashAuto)
        self.updateFlashUI()
    }
    
    func setupBottomButtons() {
        self.shotButton.setImage(UIImage(named: MediaButtons.photoShotHighlited), forState: [.Highlighted, .Selected])
    }
    
    // MARK: Orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // MARK: - actions
    @IBAction func shotTapped(sender: UIButton) {
        self.simpleCamera.capture({ [weak self] (camera, image, dict, error) -> Void in
            if let capturedImage = image {
                let correctOrientedImage = capturedImage.correctlyOrientedImage()
                self!.delegate?.photoDidTake(correctOrientedImage.cropToSquare())
            }
        })
    }
    
    @IBAction func cameraModeTapped(sender: UIButton) {
        self.simpleCamera.togglePosition()
    }
    
    @IBAction func flashTapped(sender: UIButton) {
        var flash = self.simpleCamera.flash
        if self.simpleCamera.flash == LLCameraFlashAuto {
            flash = LLCameraFlashOn
        } else if self.simpleCamera.flash == LLCameraFlashOn {
            flash = LLCameraFlashOff
        } else if self.simpleCamera.flash == LLCameraFlashOff {
            flash = LLCameraFlashAuto
        }
        self.simpleCamera.updateFlashMode(flash)
        self.updateFlashUI()
    }
    
    func updateFlashUI() {
        var flashImageString = String()
        if self.simpleCamera.flash == LLCameraFlashAuto {
            flashImageString = MediaButtons.flashOn
        } else if self.simpleCamera.flash == LLCameraFlashOn {
            flashImageString = MediaButtons.flashOff
        } else if self.simpleCamera.flash == LLCameraFlashOff {
            flashImageString = MediaButtons.flashAuto
        }
        self.flashButton.setImage(UIImage(named: flashImageString), forState: .Normal)
    }
    
    func donePressed() {
        // TODO:
    }
}

protocol PhotoControllerDelegate {
    func photoDidTake(image: UIImage)
    func photoCameraUnauthorized()
}
