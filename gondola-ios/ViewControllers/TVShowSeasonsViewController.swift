//
//  TVShowSeasonsViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 12/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//
//  This is the show details with a list of seasons.

import UIKit

class TVShowSeasonsViewController: UIViewController {
    
    let show: TVShowMetadata
    
    init(show: TVShowMetadata) {
        self.show = show
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var rootView = TVShowSeasonsView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.collection.register(PictureCell.self, forCellWithReuseIdentifier: "cell")
        
        rootView.collection.dataSource = self
        rootView.collection.delegate = self
        
        rootView.title.text = show.name
        rootView.overview.text = show.overview
        
        // Load the backdrop.
        ServiceHelpers.imageRequest(path: show.backdrop) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.rootView.background.image = image
                    UIView.animate(withDuration: 0.3) {
                        self.rootView.background.alpha = 1
                    }
                }
                
            case .failure(let error):
                NSLog("Error loading backdrop: \(error)")
            }
        }
    }
    
}

extension TVShowSeasonsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return show.seasons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let season = show.seasons[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCell
        
        cell.label.text = season.name
        
        cell.image.image = nil
        cell.imageAspectRatio = 1.5
        
        // TODO use a reusable image view? Or some helper that checks for stale?
        cell.imagePath = season.image
        ServiceHelpers.imageRequest(path: season.image) { result in
            DispatchQueue.main.async {
                if cell.imagePath == season.image { // Cell hasn't been recycled?
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

extension TVShowSeasonsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let season = show.seasons[indexPath.item]
        let vc = TVSeasonEpisodesViewController(show: show, season: season, backdrop: rootView.background.image)
        navigationController?.pushViewController(vc, animated: true)
    }
}

class TVShowSeasonsView: UIView {
    
    let background = UIImageView()
    let dim = UIView()
    let title = UILabel()
    let overview = UILabel()
    let collection: UICollectionView
    let layout = UICollectionViewFlowLayout()
    
    init() {
        // TODO have a layout helper.
        layout.scrollDirection = .horizontal
        let itemWidth = PictureCell.width(forHeight: K.itemHeight, imageAspectRatio: 1.5)
        layout.itemSize = CGSize(width: itemWidth, height: K.itemHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: LayoutHelpers.sideMargins, bottom: LayoutHelpers.vertMargins, right: LayoutHelpers.sideMargins)
        
        collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collection.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        
        super.init(frame: CGRect.zero)
        
        background.contentMode = .scaleAspectFill
        background.alpha = 0
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
        
        addSubview(collection)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = bounds.height
        
        background.frame = bounds
        
        let collectionHeight = K.itemHeight + layout.sectionInset.top + layout.sectionInset.bottom
        collection.frame = CGRect(x: 0, y: h - collectionHeight, width: w, height: collectionHeight)
        
        dim.frame = CGRect(x: 0, y: 0, width: w, height: collection.frame.minY)
        
        title.frame = CGRect(x: LayoutHelpers.sideMargins, y: LayoutHelpers.vertMargins,
                             width: w - 2*LayoutHelpers.sideMargins, height: ceil(title.font.lineHeight))
        
        let overviewTop = title.frame.maxY + 40
        let overviewBottom = collection.frame.minY - LayoutHelpers.vertMargins
        let overviewWidth = (w - LayoutHelpers.sideMargins)/2
        let maxOverviewHeight = overviewBottom - overviewTop
        let textOverviewHeight = ceil(overview.sizeThatFits(CGSize(width: overviewWidth, height: 999)).height)
        let overviewHeight = min(textOverviewHeight, maxOverviewHeight)
        overview.frame = CGRect(x: LayoutHelpers.sideMargins,
                                y: overviewTop,
                                width: overviewWidth,
                                height: overviewHeight)
    }
    
    struct K {
        static let itemUnfocusedHeightToScreenHeightRatio: CGFloat = 0.3
        static let itemHeight: CGFloat = {
            return round(UIScreen.main.bounds.height * itemUnfocusedHeightToScreenHeightRatio)
        }()
    }
    
}
