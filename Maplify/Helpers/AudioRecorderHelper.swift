//
//  AudioRecorderHelper.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/24/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation

let kAudioFileName = "MaplifyAudioRecording.m4a"
let kRecordTimeUpdateInterval: Double = 0.03

class AudioRecorderHelper: NSObject {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var delegate: AudioRecorderDelegate! = nil
    var recordTimeMax: Double = 20
    private var isRecording = false
    private var recordProgress: Double = 0
    private var timer: NSTimer? = nil
    
    // MARK: - setup
    func setupRecord() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.audioRecordDidCheckedPermissions(allowed)
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
    
    // MARK: - timer
    func startTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(kRecordTimeUpdateInterval, target: self, selector: #selector(AudioRecorderHelper.timerDidUpdate(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func timerDidUpdate(timer: NSTimer) {
        if self.canRecord() {
            self.recordProgress += kRecordTimeUpdateInterval
            let progress = recordProgress / recordTimeMax
            self.delegate?.audioRecordDidUpdateProgress(Float(progress))
        } else {
            timer.invalidate()
            self.pauseRecording()
        }
    }
    
    // MARK: - toggle record
    func toggleStartPauseRecording() {
        if self.canRecord() {
            self.changeRecordState()
        }
    }
    
    func changeRecordState() {
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
        self.startTimer()
        self.delegate?.audioRecordDidStart()
    }
    
    // MARK: - pause record
    private func pauseRecording() {
        self.audioRecorder.pause()
        self.stopTimer()
        self.delegate?.audioRecordDidPause()
    }

    // MARK: - stop record
    func finishRecording() {
        self.pauseRecording()
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
    
    private func canRecord() -> Bool {
        return self.recordProgress < recordTimeMax
    }
}

protocol AudioRecorderDelegate {
    func audioRecordDidFinishRecording(success: Bool, filePath: String)
    func audioRecordDidUpdateProgress(progress: Float)
    func audioRecordDidStart()
    func audioRecordDidPause()
    func audioRecordDidCheckedPermissions(success: Bool)
}
