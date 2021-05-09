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
        
        title = episode.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(tapPlay))
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
        
        rootView.overview.text = episode.overview
        rootView.background.image = backdrop
        rootView.episodeImage.image = episodeImage
        rootView.details.text = season.name + "\nEpisode \(episode.episode)\nAir date: \(episode.airDate)\nVote: \(episode.vote)"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func tapPlay() {
        guard let url = ServiceHelpers.url(path: episode.media) else { return }
        let vc = AVPlayerViewController()
        vc.player = AVPlayer(url: url)
        present(vc, animated: true, completion: { [weak vc] in
            vc?.player?.play()
        })
    }
    
}

class TVEpisodeView: UIView {
    
    let background = UIImageView()
    let dim = UIView()
    let overview = UILabel()
    let episodeImage = UIImageView()
    let details = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        
        background.contentMode = .scaleAspectFill
        background.clipsToBounds = true
        addSubview(background)
        
        dim.backgroundColor = UIColor(white: 0, alpha: 0.6)
        addSubview(dim)
        
        overview.textColor = UIColor.white
        overview.font = UIFont.systemFont(ofSize: 12, weight: .light)
        overview.numberOfLines = 0
        addSubview(overview)

        episodeImage.contentMode = .scaleAspectFit
        addSubview(episodeImage)
        
        details.textColor = UIColor(white: 1, alpha: 0.7)
        details.numberOfLines = 0
        details.font = UIFont.systemFont(ofSize: 11, weight: .light)
        addSubview(details)
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
        
        // Image.
        let imageWidth = round(w * 0.35)
        let aspect: CGFloat
        if let image = episodeImage.image, image.size.width > 0 {
            aspect = image.size.height / image.size.width
        } else {
            aspect = 0
        }
        let imageHeight = round(imageWidth * aspect)
        episodeImage.frame = CGRect(x: LayoutHelpers.sideMargins, y: 64 + LayoutHelpers.vertMargins,
                                    width: imageWidth, height: imageHeight)
        
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
    }
    
}
