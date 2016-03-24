//
//  AudioRecorderHelper.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/24/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let kAudioFileName = "MaplifyAudioRecording.m4a"

class AudioRecorderHelper: NSObject {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var delegate: AudioRecorderDelegate! = nil
    var isRecording = false
    
    override init() {
        super.init()
        
        self.setupRecord()
    }
    
    // MARK: - setup
    func setupRecord() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if !allowed {
                        self.delegate?.audioRecordDidFinishRecording(false, filePath: String())
                    }
                }
            }
        } catch {
            self.delegate?.audioRecordDidFinishRecording(false, filePath: String())
        }
        
        let audioURL = NSURL(fileURLWithPath: filePath())
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
        } catch {
            finishRecording()
            self.delegate?.audioRecordDidFinishRecording(false, filePath: String())
        }
    }
    
    // MARK: - toggle record
    func toggleStartPauseRecording() {
        if self.isRecording {
            self.pauseRecording()
        } else {
            self.startRecord()
        }
        self.isRecording = !self.isRecording
    }
    
    // MARK: - start record
    private func startRecord() {
        audioRecorder.record()
    }
    
    // MARK: - pause record
    private func pauseRecording() {
        self.audioRecorder.pause()
    }

    // MARK: - stop record
    func finishRecording() {
        audioRecorder.stop()
        audioRecorder = nil
        self.delegate?.audioRecordDidFinishRecording(true, filePath: filePath())
    }
    
    // MARK: - private
    private func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func filePath() -> String {
        return getDocumentsDirectory().stringByAppendingPathComponent(kAudioFileName)
    }
}

protocol AudioRecorderDelegate {
    func audioRecordDidFinishRecording(success: Bool, filePath: String)
}
