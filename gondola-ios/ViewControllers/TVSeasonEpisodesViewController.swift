//
//  TVSeasonEpisodesViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 12/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//
//  This shows the details of a season and the list of episodes to choose from.

import UIKit

class TVSeasonEpisodesViewController: UIViewController {
    
    let show: TVShowMetadata
    let season: TVSeasonMetadata
    let backdrop: UIImage?
    
    init(show: TVShowMetadata, season: TVSeasonMetadata, backdrop: UIImage?) {
        self.show = show
        self.season = season
        self.backdrop = backdrop
        
        super.init(nibName: nil, bundle: nil)

        title = season.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var rootView = TVSeasonEpisodesView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.collection.register(PictureCell.self, forCellWithReuseIdentifier: "cell")
        
        rootView.collection.dataSource = self
        rootView.collection.delegate = self
        
        rootView.overview.text = season.overview
        rootView.background.image = backdrop
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension TVSeasonEpisodesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return season.episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let episode = season.episodes[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCell
        
        cell.label.text = String(episode.episode) + ": " + episode.name
        
        cell.image.image = nil
        cell.imageAspectRatio = 9/16
        
        // TODO use a reusable image view? Or some helper that checks for stale?
        cell.imagePath = episode.image
        ServiceHelpers.imageRequest(path: episode.image) { result in
            DispatchQueue.main.async {
                if cell.imagePath == episode.image { // Cell hasn't been recycled?
                    switch result {
                    case .success(let image):
                        cell.image.image = image
                        
                    case .failure(let error):
                        NSLog("error: \(error)")
                        // TODO show sad cloud image.
                    }
                }
            }
        }
        
        return cell
    }
    
}

extension TVSeasonEpisodesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? PictureCell
        let episode = season.episodes[indexPath.item]
        let vc = TVEpisodeViewController(episode: episode,
                                         show: show,
                                         season: season,
                                         episodeImage: cell?.image.image,
                                         backdrop: rootView.background.image)
        navigationController?.pushViewController(vc, animated: true)
    }
}

class TVSeasonEpisodesView: UIView {
    
    let background = UIImageView()
    let dim = UIView()
    let overview = UILabel()
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let collection: UICollectionView
    let layout = UICollectionViewFlowLayout()
    
    init() {
        let width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        
        layout.scrollDirection = .vertical
        let itemWidth = round(width/2) - LayoutHelpers.sideMargins - LayoutHelpers.paddingH
        let itemHeight = PictureCell.height(forWidth: itemWidth, imageAspectRatio: 9/16)
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = LayoutHelpers.paddingV
        layout.sectionInset = UIEdgeInsets(top: LayoutHelpers.vertMargins,
                                           left: LayoutHelpers.sideMargins,
                                           bottom: LayoutHelpers.vertMargins,
                                           right: LayoutHelpers.sideMargins)
        
        collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collection.backgroundColor = nil
        
        super.init(frame: CGRect.zero)
        
        background.contentMode = .scaleAspectFill
        background.clipsToBounds = true
        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        background.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        background.topAnchor.constraint(equalTo: topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)
        blur.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        collection.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collection)
        collection.widthAnchor.constraint(equalToConstant: layout.itemSize.width + layout.sectionInset.left + layout.sectionInset.right).isActive = true
        collection.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        collection.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        blur.leadingAnchor.constraint(equalTo: collection.leadingAnchor).isActive = true

        dim.backgroundColor = UIColor(white: 0, alpha: 0.6)
        dim.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dim)
        dim.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dim.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dim.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        dim.trailingAnchor.constraint(equalTo: collection.leadingAnchor).isActive = true

        overview.textColor = UIColor.white
        overview.font = UIFont.systemFont(ofSize: 12, weight: .light)
        overview.numberOfLines = 0
        overview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overview)
        overview.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: LayoutHelpers.sideMargins).isActive = true
        overview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: LayoutHelpers.vertMargins).isActive = true
        overview.trailingAnchor.constraint(equalTo: dim.trailingAnchor, constant: -LayoutHelpers.sideMargins).isActive = true
        overview.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -LayoutHelpers.vertMargins).isActive = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
