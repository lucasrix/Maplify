//
//  VideoViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 3/31/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import LLSimpleCamera

public enum CameraState: Int {
    case Ready = 0
    case Recording
    case Finished
}

let nibNameVideoControllerView = "VideoViewController"
let kVideoFileName = "MaplifyVideoRecording.MOV"
let recordTimeMax: Double = 20
let kProgressViewHeight: CGFloat = 4

class VideoViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var progressBarHeightConstraint: NSLayoutConstraint!
    
    var simpleCamera: LLSimpleCamera! = nil
    var delegate: VideoControllerDelagate! = nil
    var fileUrl = ""
    var cameraState: CameraState! = nil
    private var recordProgress: Double = 0
    private var timer: NSTimer? = nil
    
    // MARK: - view controller life cycle
    override func loadView() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: nibNameVideoControllerView, bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    func setup() {
        self.setupViews()
        self.setupCamera()
    }
    
    // MARK: - setup
    func setupViews() {
        self.progressBarHeightConstraint.constant = kProgressViewHeight
        print(self.progressBarHeightConstraint.constant)
        self.progressView.progress = Float(0)
        self.updateUI()
        self.setupBottomButtons()
    }
    
    func setupCamera() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { [weak self] (alowedAccess) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if alowedAccess {
                    self?.configureCamera()
                } else {
                    self?.delegate?.videoCameraUnauthorized()
                }
            })
        })
    }
    
    func configureCamera() {
        self.simpleCamera = LLSimpleCamera(quality: AVCaptureSessionPreset640x480, position: LLCameraPositionRear, videoEnabled: true)
        self.simpleCamera.start()
        self.configureChildViewController(self.simpleCamera, onView: self.cameraView)
        self.cameraState = CameraState.Ready
    }
    
    func setupBottomButtons() {
        // record button
        self.recordButton.setImage(UIImage(named: MediaButtons.photoShotHighlited), forState: [.Highlighted, .Selected])
        
        // delete button
        self.deleteButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(kDeleteButtonHighlitedStateAlpha), forState: .Selected)
        self.deleteButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(kDeleteButtonHighlitedStateAlpha), forState: .Highlighted)
        self.deleteButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(kDeleteButtonHighlitedStateAlpha), forState: [.Selected, .Highlighted])
        self.deleteButton.setTitle(NSLocalizedString("Button.Delete", comment: String()), forState: .Normal)
    }
    
    // MARK: - actions
    @IBAction func recordTapped(sender: UIButton) {
        if self.cameraState == CameraState.Ready {
            self.recordAction()
        } else if self.cameraState == CameraState.Recording {
            self.stopAction()
        }
    }
    
    @IBAction func cameraModeTapped(sender: UIButton) {
        if self.cameraState == CameraState.Ready {
            self.simpleCamera.togglePosition()
        }
        self.flashButton.hidden = self.simpleCamera.position == LLCameraPositionFront
    }
    
    @IBAction func flashTapped(sender: UIButton) {
        if self.cameraState == CameraState.Ready {
            self.updateFlashMode()
        }
    }
    
    @IBAction func deleteTapped(sender: UIButton) {
        self.cameraState = CameraState.Ready
        self.updateUI()
        self.simpleCamera.start()
        self.recordProgress = 0
        self.progressView.progress = Float(0)
    }
    
    // MARK: - private
    func recordAction() {
        let outputURL = NSURL.fileURLWithPath(NSTemporaryDirectory() + kVideoFileName)
        self.simpleCamera.startRecordingWithOutputUrl(outputURL);
        self.cameraState = CameraState.Recording
        self.startTimer()
    }
    
    func stopAction() {
        self.simpleCamera.stopRecording { [weak self] (camera, outputFileUrl, error) in
            self?.fileUrl = outputFileUrl.URLString
            self?.cameraState = CameraState.Finished
            self?.updateUI()
            self?.simpleCamera.stop()
            self?.stopTimer()
        }
    }
    
    func donePressed() {
        if self.cameraState == CameraState.Finished {
            self.delegate?.videoDidWrite(self.fileUrl)
        }
    }
    
    func updateUI() {
        if self.cameraState == CameraState.Ready {
            self.deleteButton.hidden = true
        } else if self.cameraState == CameraState.Recording {
            self.deleteButton.hidden = true
        } else if self.cameraState == CameraState.Finished {
            self.deleteButton.hidden = false
        }
    }
    
    func updateFlashMode() {
        var flashImageString = String()
        if self.simpleCamera.flash == LLCameraFlashOff {
            self.simpleCamera.updateFlashMode(LLCameraFlashOn)
            flashImageString = MediaButtons.flashOn
        } else {
            self.simpleCamera.updateFlashMode(LLCameraFlashOff)
            flashImageString = MediaButtons.flashOff
        }
        self.flashButton.setImage(UIImage(named: flashImageString), forState: .Normal)
    }
    
    // MARK: - timer
    func startTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(kRecordTimeUpdateInterval, target: self, selector: #selector(AudioRecorderHelper.timerDidUpdate(_:)), userInfo: nil, repeats: true)
        self.progressView.progressTintColor = UIColor.cherryRed()
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.progressView.progressTintColor = UIColor.dodgerBlue()
    }
    
    func timerDidUpdate(timer: NSTimer) {
        if self.recordProgress < recordTimeMax {
            self.recordProgress += kRecordTimeUpdateInterval
            let progress = recordProgress / recordTimeMax
            self.progressView.progress = (Float(progress))
        } else {
            timer.invalidate()
            self.stopAction()
        }
    }
}

protocol VideoControllerDelagate {
    func videoDidWrite(url: String)
    func videoCameraUnauthorized()
}
