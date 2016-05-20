//
//  AmbientViewController.swift
//  Maplify
//
//  Created by Evgeniy Antonoff on 5/19/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import EZAudio
import AVFoundation
import UIKit

let nibNameAmbientControllerView = "AmbientViewController"
let kAmbientEqualizerViewHeightIPhone3_5: CGFloat = 240
let kAmbientDeleteButtonTopMarginIPhone3_5: CGFloat = 0

class AmbientViewController: UIViewController, EZMicrophoneDelegate, AudioRecorderDelegate {
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var equalizerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonTopConstraint: NSLayoutConstraint!
    
    var microphone: EZMicrophone!
    var audioRecorder = AudioRecorderHelper()
    var pickedLocation: MCMapCoordinate! = nil
    var delegate: AmbientControllerDelegate! = nil
    
    // MARK: - view controller life cycle
    override func loadView() {
        super.viewDidLoad()
        
        if let view = UINib(nibName: nibNameAmbientControllerView, bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setupAudioPlot()
    }
    
    // MARK: - setup
    func setup() {
        self.setupViews()
        self.setupAudioRecording()
    }
    
    func setupViews() {
        if UIScreen().isIPhoneScreenSize3_5() {
            self.equalizerViewHeightConstraint.constant = kAmbientEqualizerViewHeightIPhone3_5
            self.deleteButtonTopConstraint.constant = kAmbientDeleteButtonTopMarginIPhone3_5
        } else {
            self.equalizerViewHeightConstraint.constant = UIScreen().screenWidth()
        }
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
        self.audioRecorder.setupRecord()
        self.audioRecorder.delegate = self
    }
    
    // MARK: - actions
    @IBAction func recordTapped(sender: UIButton) {
        self.audioRecorder.toggleStartPauseRecording()
    }
    
    @IBAction func deleteTapped(sender: UIButton) {
        self.audioRecorder.reloadRecording()
    }
    
    // MARK: - private
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        self.audioPlot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
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
        self.deleteButton.hidden = true
    }
    
    func donePressed() {
        self.audioRecorder.finishRecording()
    }
    
    // MARK: - AudioRecorderDelegate
    func audioRecordDidFinishRecording(success: Bool, filePath: String) {
        if success {
            let audioData = NSFileManager.defaultManager().contentsAtPath(filePath)
            self.delegate?.audioDidRecord(audioData)
        } else {
            self.delegate?.audioDidRecord(nil)
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
        self.deleteButton.hidden = false
    }
    
    func audioRecordDidCheckedPermissions(success: Bool) {
        if !success {
            self.delegate?.audioMicrophoneUnauthorized()
        }
    }
    
    func audioRecordDidReload() {
        self.deleteButton.hidden = true
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}

protocol AmbientControllerDelegate {
    func audioDidRecord(audioData: NSData!)
    func audioMicrophoneUnauthorized()
}
