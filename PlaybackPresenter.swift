//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by Isidora Lazic on 6.2.22..
//

import AVFoundation
import Foundation
import UIKit

// MARK: - Delegate

protocol PlayerDataSource: AnyObject{
    var songName: String? {get}
    var subtitle: String? {get}
    var imageURL: URL? {get}
}

final class PlaybackPresenter {
    
    // MARK: - Singleton
    
    static let shared = PlaybackPresenter()
    
    // MARK: - Properties
    
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    var index = 0
    
    var playerVC: PlayerViewController?
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    var controlsView : PlayerControlView?
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }
        else if self.playerQueue != nil, !tracks.isEmpty {
            return tracks[index]
        }
        return nil
    }
    
    var alert: UIAlertController!
    
    // MARK: - Helpers
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack){
        guard let url = URL(string: track.preview_url ?? "") else{
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        
        viewController.present(UINavigationController(rootViewController: vc), animated: true) {[weak self] in
            self?.player?.play()
        }
        self.playerVC = vc
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]){
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else{
                return nil
            }
            return AVPlayerItem(url: url)
        }))
        
        self.playerQueue?.volume = 0.5
        self.playerQueue?.play()
        
        self.tracks = tracks
        self.track = nil
        
        let vc = PlayerViewController()
        vc.title = "Now Playing"
        vc.dataSource = self
        vc.delegate = self
        
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        self.playerVC = vc
    }
}

// MARK: - PlayerViewControllerDelegate

extension PlaybackPresenter: PlayerViewControllerDelegate{
    func didTapBack() {
        if tracks.isEmpty{
            //not a playlist or an album
            player?.pause()
            player?.play()
        } else {
            controlsView?.playPauseButton.isEnabled = false
        }
    }
    
    func didTapNext() {
        if tracks.isEmpty{
            //not a playlist or an album
            controlsView?.playPauseButton.isEnabled = false
        }
        else if let player = playerQueue{
            player.advanceToNextItem()
            index += 1
            playerVC?.refreshUI()
        }
    }
    
    func didTapPlayPause() {
        if let player = player{
            if player.timeControlStatus == .playing{
                player.pause()
            }
            else if player.timeControlStatus == .paused{
                player.play()
            }
        }
        else if let player = playerQueue{
            if player.timeControlStatus == .playing{
                player.pause()
            }
            else if player.timeControlStatus == .paused{
                player.play()
            }
        }
    }
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
    func closePlayer() {
        if let player = player {
            if player.timeControlStatus == .playing{
                player.pause()
                player.isMuted = true
            }
        }
        else if let player = playerQueue{
            if player.timeControlStatus == .playing{
                player.pause()
                player.isMuted = true
            }
        }
    }
}

// MARK: - PlayerDataSource

extension PlaybackPresenter: PlayerDataSource{
    var songName: String?{
        return currentTrack?.name
    }
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}