//
//  MovieViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 15/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//
//  This shows the details of a movie and lets you play it.

import UIKit
import AVKit
import AVFoundation

class MovieViewController: UIViewController {
    
    let movie: MovieMetadata
    let image: UIImage?
    
    init(movie: MovieMetadata, image: UIImage?) {
        self.movie = movie
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var rootView = MovieView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.title.text = movie.name
        rootView.overview.text = movie.overview
        rootView.image.image = image
        rootView.details.text = "Release date: \(movie.releaseDate)\nVote: \(movie.vote)"
        
        rootView.background.alpha = 0
        ServiceHelpers.imageRequest(path: movie.backdrop) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.rootView.background.image = image
                    UIView.animate(withDuration: 0.3) {
                        self.rootView.background.alpha = 1
                    }
                    
                case .failure(let error):
                    NSLog("error: \(error)")
                }
            }
        }
        
        rootView.play.addTarget(self, action: #selector(tapPlay), for: .primaryActionTriggered)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func tapPlay() {
        guard let url = ServiceHelpers.url(path: movie.media) else { return }
        let vc = AVPlayerViewController()
        vc.player = AVPlayer(url: url)
        present(vc, animated: true, completion: { [weak vc] in
            vc?.player?.play()
        })
    }
    
}

class MovieView: UIView {
    
    let background = UIImageView()
    let dim = UIView()
    let title = UILabel()
    let overview = UILabel()
    let image = UIImageView()
    let details = UILabel()
    let play = UIButton(type: .system)
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.black
        
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
        
        image.contentMode = .scaleAspectFit
        addSubview(image)
        
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
        let imageWidth = round(w * 0.25)
        let aspect: CGFloat
        if let image = image.image, image.size.width > 0 {
            aspect = image.size.height / image.size.width
        } else {
            aspect = 0
        }
        let imageHeight = round(imageWidth * aspect)
        image.frame = CGRect(x: LayoutHelpers.sideMargins, y: title.frame.maxY + 40, width: imageWidth, height: imageHeight)
        
        // Details under image.
        let detailsTop = image.frame.maxY + 40
        let detailsBottom = h - LayoutHelpers.vertMargins
        let detailsWidth = imageWidth
        let maxDetailsHeight = detailsBottom - detailsTop
        let textDetailsHeight = ceil(details.sizeThatFits(CGSize(width: detailsWidth, height: 999)).height)
        let detailsHeight = min(textDetailsHeight, maxDetailsHeight)
        details.frame = CGRect(x: image.frame.minX, y: detailsTop, width: detailsWidth, height: detailsHeight)
        
        let overviewLeft = image.frame.maxX + LayoutHelpers.sideMargins
        let overviewRight = w - LayoutHelpers.sideMargins
        let overviewTop = image.frame.minY
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
