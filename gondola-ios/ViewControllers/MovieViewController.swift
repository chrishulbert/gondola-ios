//
//  MovieViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 15/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//
//  This shows the details of a movie and lets you play it.

import UIKit

class MovieViewController: UIViewController {
    
    let movie: MovieMetadata
    let image: UIImage?
    
    init(movie: MovieMetadata, image: UIImage?) {
        self.movie = movie
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
        
        title = movie.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(tapPlay))
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
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @objc func tapPlay() {
        pushPlayer(media: movie.media)
    }
    
}

class MovieView: UIView {
    
    let background = UIImageView()
    let dim = UIView()
    let overview = UILabel()
    let image = UIImageView()
    let details = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.black
        
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
        
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: LayoutHelpers.sideMargins).isActive = true
        image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: LayoutHelpers.vertMargins).isActive = true
        image.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25, constant: 0).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 16/9, constant: 0).isActive = true
        image.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5).isActive = true

        details.textColor = UIColor(white: 1, alpha: 0.7)
        details.numberOfLines = 0
        details.font = UIFont.systemFont(ofSize: 11, weight: .light)
        details.translatesAutoresizingMaskIntoConstraints = false
        addSubview(details)
        details.leadingAnchor.constraint(equalTo: image.leadingAnchor).isActive = true
        details.trailingAnchor.constraint(equalTo: image.trailingAnchor).isActive = true
        details.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        
        overview.textColor = UIColor.white
        overview.font = UIFont.systemFont(ofSize: 12, weight: .light)
        overview.numberOfLines = 0
        overview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overview)
        overview.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: LayoutHelpers.sideMargins).isActive = true
        overview.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -LayoutHelpers.sideMargins).isActive = true
        overview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: LayoutHelpers.vertMargins).isActive = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
