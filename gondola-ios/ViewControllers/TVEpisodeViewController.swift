//
//  TVEpisodeViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 13/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//
//  This shows the details of an episode and lets you play it.

import UIKit
import AVKit
import AVFoundation

class TVEpisodeViewController: UIViewController {
    
    let episode: TVEpisodeMetadata
    let show: TVShowMetadata
    let season: TVSeasonMetadata
    let episodeImage: UIImage?
    let backdrop: UIImage?
    
    init(episode: TVEpisodeMetadata, show: TVShowMetadata, season: TVSeasonMetadata, episodeImage: UIImage?, backdrop: UIImage?) {
        self.episode = episode
        self.show = show
        self.season = season
        self.episodeImage = episodeImage
        self.backdrop = backdrop
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var rootView = TVEpisodeView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.title.text = episode.name
        rootView.overview.text = episode.overview
        rootView.background.image = backdrop
        rootView.episodeImage.image = episodeImage
        rootView.details.text = season.name + "\nEpisode \(episode.episode)\nAir date: \(episode.airDate)\nVote: \(episode.vote)"
        
        rootView.play.addTarget(self, action: #selector(tapPlay), for: .primaryActionTriggered)
    }
    
    func tapPlay() {
        guard let url = ServiceHelpers.url(path: episode.media) else { return }
        let vc = AVPlayerViewController()
        vc.player = AVPlayer(url: url)
        present(vc, animated: true, completion: nil)
        vc.player?.play() // Play before the completion block so it starts loading sooner.
    }
    
}

class TVEpisodeView: UIView {
    
    let background = UIImageView()
    let dim = UIView()
    let title = UILabel()
    let overview = UILabel()
    let episodeImage = UIImageView()
    let details = UILabel()
    let play = UIButton(type: .system)
    
    init() {
        super.init(frame: CGRect.zero)
        
        background.contentMode = .scaleAspectFill
        addSubview(background)
        
        dim.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(dim)
        
        title.textColor = UIColor.white
        title.font = UIFont.systemFont(ofSize: 60, weight: UIFontWeightThin)
        addSubview(title)
        
        overview.textColor = UIColor.white
        overview.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightLight)
        overview.numberOfLines = 0
        addSubview(overview)

        episodeImage.contentMode = .scaleAspectFit
        addSubview(episodeImage)
        
        details.textColor = UIColor(white: 1, alpha: 0.7)
        details.numberOfLines = 0
        details.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightLight)
        addSubview(details)
        
        play.setTitle("Play", for: .normal)
        addSubview(play)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = bounds.height
        
        background.frame = bounds
        dim.frame = bounds

        // Top row.
        title.frame = CGRect(x: LayoutHelpers.sideMargins,
                             y: LayoutHelpers.vertMargins,
                             width: w - 2*LayoutHelpers.sideMargins,
                             height: ceil(title.font.lineHeight))
        
        // Image under it.
        let imageWidth = round(w * 0.35)
        let aspect: CGFloat
        if let image = episodeImage.image, image.size.width > 0 {
            aspect = image.size.height / image.size.width
        } else {
            aspect = 0
        }
        let imageHeight = round(imageWidth * aspect)
        episodeImage.frame = CGRect(x: LayoutHelpers.sideMargins, y: title.frame.maxY + 40, width: imageWidth, height: imageHeight)
        
        // Details under image.
        let detailsTop = episodeImage.frame.maxY + 40
        let detailsBottom = h - LayoutHelpers.vertMargins
        let detailsWidth = imageWidth
        let maxDetailsHeight = detailsBottom - detailsTop
        let textDetailsHeight = ceil(details.sizeThatFits(CGSize(width: detailsWidth, height: 999)).height)
        let detailsHeight = min(textDetailsHeight, maxDetailsHeight)
        details.frame = CGRect(x: episodeImage.frame.minX, y: detailsTop, width: detailsWidth, height: detailsHeight)
        
        let overviewLeft = episodeImage.frame.maxX + LayoutHelpers.sideMargins
        let overviewRight = w - LayoutHelpers.sideMargins
        let overviewTop = episodeImage.frame.minY
        let overviewBottom = h - LayoutHelpers.vertMargins
        let overviewWidth = overviewRight - overviewLeft
        let maxOverviewHeight = overviewBottom - overviewTop
        let textOverviewHeight = ceil(overview.sizeThatFits(CGSize(width: overviewWidth, height: 999)).height)
        let overviewHeight = min(textOverviewHeight, maxOverviewHeight)
        overview.frame = CGRect(x: overviewLeft,
                                y: overviewTop,
                                width: overviewWidth,
                                height: overviewHeight)
        
        // Center bottom.
        let playSize = play.intrinsicContentSize
        play.frame = CGRect(origin: CGPoint(x: round(w/2 - playSize.width/2),
                                            y: round(h - LayoutHelpers.vertMargins - playSize.height - 8)), // -8 to compensate for focus growth
                            size: playSize)
    }
    
}
