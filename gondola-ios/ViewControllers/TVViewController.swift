//
//  TVViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 9/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//
//  List of all tv shows.

import UIKit

class TVViewController: UIViewController {
    
    let metadata: GondolaMetadata
    
    init(metadata: GondolaMetadata) {
        self.metadata = metadata
        
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem.image = #imageLiteral(resourceName: "TV")
        tabBarItem.title = "TV"
        navigationItem.title = "Gondola"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var rootView = TVView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.collection.register(PictureCell.self, forCellWithReuseIdentifier: "cell")
        
        rootView.collection.dataSource = self
        rootView.collection.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension TVViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metadata.tvShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let show = metadata.tvShows[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCell
        
        cell.label.text = show.name
        
        cell.image.image = nil
        cell.imageAspectRatio = 1.5
        
        // TODO use a reusable image view? Or some helper that checks for stale?
        cell.imagePath = show.image
        ServiceHelpers.imageRequest(path: show.image) { result in
            DispatchQueue.main.async {
                if cell.imagePath == show.image { // Cell hasn't been recycled?
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
    
    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        var firsts: Set<Character> = []
        for show in metadata.tvShows {
            if let c = show.name.first {
                firsts.insert(c)
            }
        }
        return firsts.sorted().map { String($0) }
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        for (i, show) in metadata.tvShows.enumerated() {
            if show.name.hasPrefix(title) {
                return IndexPath(item: i, section: 0)
            }
        }
        return IndexPath(item: 0, section: 0)
    }


}

extension TVViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let show = metadata.tvShows[indexPath.item]
        let vc = TVShowSeasonsViewController(show: show)
        navigationController?.pushViewController(vc, animated: true)
    }
}

class TVView: UIView {
    
    let collection: UICollectionView
    
    init() {
        let width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        
        // TODO have a layout helper.
        let columns = 2
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemWidth = floor((width - 2*LayoutHelpers.sideMargins - LayoutHelpers.paddingH*(CGFloat(columns)-1)) / CGFloat(columns))
        let itemHeight = PictureCell.height(forWidth: itemWidth, imageAspectRatio: 1.5)
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = LayoutHelpers.paddingV
        layout.minimumInteritemSpacing = LayoutHelpers.paddingH
        layout.sectionInset = UIEdgeInsets(top: LayoutHelpers.vertMargins, left: LayoutHelpers.sideMargins, bottom: LayoutHelpers.vertMargins, right: LayoutHelpers.sideMargins)
        
        collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        
        let back = UIImageView(image: #imageLiteral(resourceName: "Background"))
        back.contentMode = .scaleAspectFill
        collection.backgroundView = back
        
        super.init(frame: CGRect.zero)
        
        addSubview(collection)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        collection.frame = bounds
    }
    
}
