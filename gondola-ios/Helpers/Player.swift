//
//  Player.swift
//  gondola-ios
//
//  Created by Chris on 9/5/21.
//  Copyright © 2021 Gondola. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

extension UIViewController {
    func pushPlayer(media: String) {
        guard let url = ServiceHelpers.url(path: media) else { return }
        let presenter = self
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        GetBookmarkService.getBookmark(item: media, completion: { bookmark in
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                
                let item = PlayerItemWithUserInfo(url: url)
                let player = AVPlayer(playerItem: item)
                let interval = CMTime(seconds: 10, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (time: CMTime) in
                    SetBookmarkService.postBookmark(item: media, time: Int(time.seconds))
                })
                
                if bookmark > 0 {
                    let time = CMTime(seconds: Double(bookmark), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                    player.seek(to: time)
                }

                let vc = AVPlayerViewController()
                vc.player = player

                let endTimeListener = EndTimeListener(media: media, playerViewController: vc, playerItem: item)
                item.userInfo = endTimeListener // Give it the same lifetime as the item.

                presenter.present(vc, animated: true, completion: { [weak vc] in
                    vc?.player?.play()
                })
            }
        })
    }
}

// A player item that will retain something extra for us.
class PlayerItemWithUserInfo: AVPlayerItem {
    var userInfo: Any?
}

// This class just listens for the 'AVPlayerItemDidPlayToEndTime' and takes appropriate action.
class EndTimeListener {
    let media: String
    weak var playerViewController: AVPlayerViewController?
    weak var playerItem: AVPlayerItem?
    
    init(media: String, playerViewController: AVPlayerViewController, playerItem: AVPlayerItem) {
        self.media = media
        self.playerViewController = playerViewController
        self.playerItem = playerItem
        // Bug - you cannot specify the object: https://stackoverflow.com/a/51891930/59198
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    
    @objc func playerItemDidPlayToEndTime(notification: Notification) {
        guard let sender = notification.object as? AVPlayerItem else { return }
        guard sender === playerItem else { return }
        DispatchQueue.main.async { [playerViewController, media] in
            playerViewController?.dismiss(animated: true, completion: { [media] in
                SetBookmarkService.postBookmark(item: media, time: 0)
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
