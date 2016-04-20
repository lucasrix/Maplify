//
//  PlayerHelper.swift
//  Maplify
//
//  Created by - Jony - on 4/14/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Foundation
import Player
import KDEAudioPlayer

enum PlayerType: Int {
    case Audio
    case Video
}

class PlayerHelper: NSObject, PlayerDelegate, AudioPlayerDelegate {
    static let sharedPlayer = PlayerHelper()
    
    var videoPlayer: Player! = nil
    var audioPlayer: AudioPlayer! = nil
    var audioPlayerView: UIView! = nil
    
    override init() {
        super.init()
        self.setupAudioPlayer()
    }
    
    // MARK: - video player
    func playVideo(urlString: String, onView: UIView, delegate: PlayerHelperDelegate) {
        self.removeVideoPlayerIfNedded()
        self.setupVideoPlayer(onView)
        
        videoPlayer.setUrl(NSURL(string:urlString)!)
        videoPlayer.playFromBeginning()
    }
    
    func removeVideoPlayerIfNedded() {
        self.videoPlayer?.view?.superview?.backgroundColor = UIColor.clearColor()
        self.videoPlayer?.pause()
        self.videoPlayer?.view.removeFromSuperview()
    }
    
    func setupVideoPlayer(parentView: UIView) {
        parentView.backgroundColor = UIColor.blackColor()
        self.videoPlayer = Player()
        self.videoPlayer.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoTapHandler(_:)))
        self.videoPlayer.view.addGestureRecognizer(tapGesture)
        self.videoPlayer.view.frame = parentView.bounds
        parentView.addSubview(self.videoPlayer.view)
    }
    
    // MARK: - audio player
//    func removeAudioPlayerIfNedded() {
//        if self.audioPlayer != nil {
//            self.audioPlayer.pause()
//            self.audioPlayer = nil
//            self.audioPlayerView = nil
//        }
//    }
    
    func setupAudioPlayer() {
        self.audioPlayer = AudioPlayer()
        self.audioPlayer.delegate = self
    }
    
    func playAudio(urlString: String, onView: UIView, delegate: PlayerHelperDelegate) {

        let item = AudioItem(highQualitySoundURL: NSURL(string: urlString))
        self.audioPlayer.playItem(item!)
        
        
//        if self.audioPlayerView == onView {
//            self.toggleAudioPlayback()
//        } else {
////            self.audioPlayer = AudioPlayer()
//            self.audioPlayer?.stop()
//            let item = AudioItem(highQualitySoundURL: NSURL(string: urlString))
//            print(item)
//            print(urlString)
//            self.audioPlayer.playItem(item!)
//        }
        
        
//        self.videoPlayer.stop()
//        let item = AudioItem(highQualitySoundURL: NSURL(string: urlString))
//        self.audioPlayer.playItem(item!)
//        if onView == self.audioPlayerView {
//            self.toggleAudioPlayback()
//        } else {
//            self.audioPlayer.pause()
//            let item = AudioItem(highQualitySoundURL: NSURL(string: urlString))
//            self.audioPlayer.playItem(item!)
//        }
    }
    
    func toggleAudioPlayback() {
        print(self.audioPlayer)
        if self.audioPlayer.state == AudioPlayerState.Playing {
            self.audioPlayer.pause()
        } else if self.audioPlayer.state == AudioPlayerState.Paused {
            self.audioPlayer.resume()
        }
    }
    
    // MARK: - gestures
    func videoTapHandler(gestureRecognizer: UITapGestureRecognizer) {
        if self.videoPlayer.playbackState == PlaybackState.Playing {
            self.videoPlayer.pause()
        } else if self.videoPlayer.playbackState == PlaybackState.Paused {
            self.videoPlayer.playFromCurrentTime()
        }
    }
    
    // MARK: - PlayerDelegate
    func playerReady(player: Player) {
        
    }
    
    func playerPlaybackStateDidChange(player: Player) {
        if player.playbackState == PlaybackState.Stopped {
            self.removeVideoPlayerIfNedded()
        }
    }
    
    func playerBufferingStateDidChange(player: Player) {
        
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
        print("begin")
    }
    
    func playerPlaybackDidEnd(player: Player) {
        
    }
    
    // MARK: - AudioPlayerDelegate
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        print("change au")
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        print("finish duration au")
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem) {
        
    }
}

protocol PlayerHelperDelegate {
//    func videoPlayerDidPause()
}
