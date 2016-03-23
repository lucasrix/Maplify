//
//  StoryPointAddAudioController.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/23/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import UIKit
import EZAudio

let kProgressBarHeight: CGFloat = 4

class StoryPointAddAudioController: ViewController, EZMicrophoneDelegate {
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarHeightConstraint: NSLayoutConstraint!
    
    var microphone: EZMicrophone!
    
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
    }
    
    func setupViews() {
        self.title = NSLocalizedString("Controller.Ambient.Title", comment: String())
        self.addRightBarItem(NSLocalizedString("Button.Next", comment: String()))
        self.progressBarHeightConstraint.constant = kProgressBarHeight
    }
    
    func setupAudioPlot() {
        self.audioPlot.backgroundColor = UIColor.darkGreyBlue()
        self.audioPlot.color = UIColor.whiteColor()
        self.audioPlot.plotType = .Buffer
        self.microphone = EZMicrophone(delegate: self, startsImmediately: true);
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
        // TODO:
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue(), { () -> () in
            self.audioPlot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
}
