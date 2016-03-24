//
//  StoryPointAddAudioController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/23/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import EZAudio
import AVFoundation

let kProgressBarHeight: CGFloat = 4

class StoryPointAddAudioController: ViewController, EZMicrophoneDelegate, AudioRecorderDelegate {
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButton: UIButton!
    
    var microphone: EZMicrophone!
    var audioRecorder = AudioRecorderHelper()
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
        self.setupAudioPlot()
        self.setupAudioRecording()
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.Ambient.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Next", comment: String()))
        self.progressBarHeightConstraint.constant = kProgressBarHeight
        self.progressBar.progress = 0 as Float
        self.setupStartRecordUI()
    }
    
    func setupAudioPlot() {
        self.audioPlot.backgroundColor = UIColor.darkGreyBlue()
        self.audioPlot.color = UIColor.whiteColor()
        self.audioPlot.plotType = .Buffer
        self.microphone = EZMicrophone(delegate: self, startsImmediately: true);
    }
    
    func setupAudioRecording() {
        self.audioRecorder.delegate = self
    }
    
    // MARK: - navigation bar
    override func navigationBarIsTranlucent() -> Bool {
        return false
    }
    
    override func navigationBarColor() -> UIColor {
        return UIColor.darkGreyBlue()
    }
    
    // MARK: - navigation bar item actions
    override func rightBarButtonItemDidTap() {
        self.showProgressHUD()
        self.audioRecorder.finishRecording()
    }
    
    // MARK: - actions
    
    @IBAction func recordTapped(sender: UIButton) {
        self.audioRecorder.toggleStartPauseRecording()
    }
    
    // MARK: - private
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue(), { () -> () in
            self.audioPlot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
    private func setupStartRecordUI() {
        self.recordButton.setImage(UIImage(named: ButtonImages.recordButtonShotStartDefault), forState: .Normal)
        self.recordButton.setImage(UIImage(named: ButtonImages.recordButtonShotStartHighlited), forState: .Highlighted)
        self.progressBar.progressTintColor = UIColor.dodgerBlue()
    }
    
    private func setupPauseRecordUI() {
        self.recordButton.setImage(UIImage(named: ButtonImages.recordButtonShotStopDefault), forState: .Normal)
        self.recordButton.setImage(UIImage(named: ButtonImages.recordButtonShotStopHighlited), forState: .Highlighted)
        self.progressBar.progressTintColor = UIColor.cherryRed()
    }
    
    // MARK: - AudioRecorderDelegate
    func audioRecordDidFinishRecording(success: Bool, filePath: String) {
        self.hideProgressHUD()
        if success {
            self.routesOpenStoryPointEditDescriptionController(StoryPointKind.Audio, storyPointAttachmentId: filePath)
        } else {
            // TODO:
        }
    }
    
    func audioRecordDidUpdateProgress(progress: Float) {
        self.progressBar.progress = progress
    }
    
    func audioRecordDidStart() {
        self.setupPauseRecordUI()
    }
    
    func audioRecordDidPause() {
        self.setupStartRecordUI()
    }
}
