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
                
                let player = AVPlayer(url: url)
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

                presenter.present(vc, animated: true, completion: { [weak vc] in
                    vc?.player?.play()
                })
            }
        })
    }
}
