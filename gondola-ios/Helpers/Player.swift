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

        let player = AVPlayer(url: url)
        let interval = CMTime(seconds: 10, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) // Every 10s.
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (time: CMTime) in
            SetBookmarkService.postBookmark(item: media, time: Int(time.seconds))
        })

        let vc = AVPlayerViewController()
        vc.player = player

        present(vc, animated: true, completion: { [weak vc] in
            vc?.player?.play()
        })
    }
}
