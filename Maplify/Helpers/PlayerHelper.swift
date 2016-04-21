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

class PlayerHelper: NSObject, PlayerDelegate, AudioPlayerDelegate {
    static let sharedPlayer = PlayerHelper()
    
    var videoPlayer: Player! = nil
    var audioPlayer: AudioPlayer! = nil
    var audioPlayerView: UIView! = nil
    var audioPlayerItem: AudioItem! = nil
    
    override init() {
        super.init()
        
        self.setupAudioPlayer()
    }
    
    // MARK: - video player
    func playVideo(urlString: String, onView: UIView, delegate: PlayerHelperDelegate) {
        self.audioPlayer?.stop()
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

    // MARK: - video player
    func setupAudioPlayer() {
        self.audioPlayer = AudioPlayer()
        self.audioPlayer.delegate = self
    }
    
    func playAudio(urlString: String, onView: UIView, delegate: PlayerHelperDelegate) {
        self.removeVideoPlayerIfNedded()
        self.audioPlayerItem = AudioItem(highQualitySoundURL: NSURL(string: urlString))
        self.audioPlayer.playItem(self.audioPlayerItem!)
        self.audioPlayerView = onView
        let audioTapGesture = UITapGestureRecognizer(target: self, action: #selector(PlayerHelper.audioTapHandler(_:)))
        self.audioPlayerView.addGestureRecognizer(audioTapGesture)
    }
    
    func toggleAudioPlayback() {
        self.removeVideoPlayerIfNedded()
        if self.audioPlayer?.state == AudioPlayerState.Playing {
            self.audioPlayer?.pause()
        } else if self.audioPlayer?.state == AudioPlayerState.Paused {
            self.audioPlayer?.resume()
        } else if self.audioPlayer?.state == AudioPlayerState.Stopped {
            self.audioPlayer?.playItem(self.audioPlayerItem)
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
    
    func audioTapHandler(gestureRecognizer: UITapGestureRecognizer) {
        self.toggleAudioPlayback()
    }
    
    // MARK: - PlayerDelegate
    func playerReady(player: Player) {
        // required protocol method
    }
    
    func playerPlaybackStateDidChange(player: Player) {
        if player.playbackState == PlaybackState.Stopped {
            self.removeVideoPlayerIfNedded()
        }
    }
    
    func playerBufferingStateDidChange(player: Player) {
        // required protocol method
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
        // required protocol method
    }
    
    func playerPlaybackDidEnd(player: Player) {
        // required protocol method
    }
    
    // MARK: - AudioPlayerDelegate
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        // required protocol method
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        // required protocol method
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float) {
        // required protocol method
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem) {
        // required protocol method
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        // required protocol method
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem) {
        // required protocol method
    }
}

protocol PlayerHelperDelegate {
    
}
