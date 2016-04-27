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
    @IBOutlet weak var deleteButton: UIButton!
    
    var microphone: EZMicrophone!
    var audioRecorder = AudioRecorderHelper()
    var pickedLocation: MCMapCoordinate! = nil
    
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
        self.audioRecorder.setupRecord()
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
        self.audioRecorder.finishRecording()
    }
    
    override func backTapped() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.backTapped()
    }
    
    // MARK: - actions
    @IBAction func recordTapped(sender: UIButton) {
        self.audioRecorder.toggleStartPauseRecording()
    }
    
    @IBAction func deleteTapped(sender: UIButton) {
        self.audioRecorder.reloadRecording()
    }
    
    // MARK: - remote
    func remotePostAttachment(fileData: NSData) {
        self.showProgressHUD()
        
        let params = ["mimeType": "audio/m4a", "fileName": "audio.m4a"]
        
        ApiClient.sharedClient.postAttachment(fileData, params: params, success: { [weak self] (response) -> () in
            
            self?.hideProgressHUD()
            let attachmentID = (response as! Attachment).id
            self?.routesOpenStoryPointEditDescriptionController(StoryPointKind.Audio, storyPointAttachmentId: attachmentID, location: (self?.pickedLocation)!)
            
        }) { [weak self] (statusCode, errors, localDescription, messages) -> () in
            
            self?.hideProgressHUD()
            self?.handleErrors(statusCode, errors: errors, localDescription: localDescription, messages: messages)
        }
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
        self.deleteButton.hidden = true
    }
    
    private func showAudioPermissionsError() {
        let title = NSLocalizedString("Alert.Audio.Permissions.Title", comment: String()).capitalizedString
        let message = NSLocalizedString("Alert.Audio.Permissions.Message", comment: String()).capitalizedString
        let cancel = NSLocalizedString("Button.Cancel", comment: String())
        let buttonOpenSettingsTitle = NSLocalizedString("Button.OpenSettings", comment: String()).capitalizedString
        
        self.showAlert(title, message: message, cancel: cancel, buttons: [buttonOpenSettingsTitle]) { [weak self] (buttonIndex) in
            if buttonIndex == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            }
            self?.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - AudioRecorderDelegate
    func audioRecordDidFinishRecording(success: Bool, filePath: String) {
        if success {
            let audioData = NSFileManager.defaultManager().contentsAtPath(filePath)
            self.remotePostAttachment(audioData!)
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
        self.deleteButton.hidden = false
    }
    
    func audioRecordDidCheckedPermissions(success: Bool) {
        if !success {
            self.showAudioPermissionsError()
        }
    }
    
    // MARK: - ErrorHandlingProtocol
    func handleErrors(statusCode: Int, errors: [ApiError]!, localDescription: String!, messages: [String]!) {
        let title = NSLocalizedString("Alert.Error", comment: String())
        let cancel = NSLocalizedString("Button.Ok", comment: String())
        self.showMessageAlert(title, message: String.formattedErrorMessage(messages), cancel: cancel)
    }
}
