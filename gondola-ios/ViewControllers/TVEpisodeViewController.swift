//
//  TVEpisodeViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 13/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//
//  This shows the details of an episode and lets you play it.

import UIKit

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
        pushPlayer(media: episode.media)
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
        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        background.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        background.topAnchor.constraint(equalTo: topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        dim.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dim.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dim)
        dim.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dim.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dim.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dim.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        episodeImage.contentMode = .scaleAspectFit
        episodeImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(episodeImage)
        episodeImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: LayoutHelpers.sideMargins).isActive = true
        episodeImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: LayoutHelpers.vertMargins).isActive = true
        episodeImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25, constant: 0).isActive = true
        episodeImage.heightAnchor.constraint(equalTo: episodeImage.widthAnchor, multiplier: 16/9, constant: 0).isActive = true
        episodeImage.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5).isActive = true

        details.textColor = UIColor(white: 1, alpha: 0.7)
        details.numberOfLines = 0
        details.font = UIFont.systemFont(ofSize: 11, weight: .light)
        details.translatesAutoresizingMaskIntoConstraints = false
        addSubview(details)
        details.leadingAnchor.constraint(equalTo: episodeImage.leadingAnchor).isActive = true
        details.trailingAnchor.constraint(equalTo: episodeImage.trailingAnchor).isActive = true
        details.topAnchor.constraint(equalTo: episodeImage.bottomAnchor, constant: 10).isActive = true

        overview.textColor = UIColor.white
        overview.font = UIFont.systemFont(ofSize: 12, weight: .light)
        overview.numberOfLines = 0
        overview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overview)
        overview.leadingAnchor.constraint(equalTo: episodeImage.trailingAnchor, constant: LayoutHelpers.sideMargins).isActive = true
        overview.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -LayoutHelpers.sideMargins).isActive = true
        overview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: LayoutHelpers.vertMargins).isActive = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
