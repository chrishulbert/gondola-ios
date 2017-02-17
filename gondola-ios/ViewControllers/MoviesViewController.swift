//
//  MoviesViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 14/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//
//  Lists the movies.

import UIKit

class MoviesViewController: UIViewController {
    
    let metadata: GondolaMetadata
    
    init(metadata: GondolaMetadata) {
        self.metadata = metadata
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Movies"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var rootView = MoviesView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.collection.register(PictureCell.self, forCellWithReuseIdentifier: "cell")
        
        rootView.collection.dataSource = self
        rootView.collection.delegate = self
    }
    
}

extension MoviesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metadata.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = metadata.movies[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCell
        
        cell.label.text = movie.name
        
        cell.image.image = nil
        cell.imageAspectRatio = 1.5
        
        // TODO use a reusable image view? Or some helper that checks for stale?
        cell.imagePath = movie.image
        ServiceHelpers.imageRequest(path: movie.image) { result in
            DispatchQueue.main.async {
                if cell.imagePath == movie.image { // Cell hasn't been recycled?
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

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? PictureCell
        let movie = metadata.movies[indexPath.item]
        let vc = MovieViewController(movie: movie, image: cell?.image.image)
        navigationController?.pushViewController(vc, animated: true)
    }
}

class MoviesView: UIView {
    
    let collection: UICollectionView
    
    init() {
        let size = UIScreen.main.bounds.size
        
        // TODO have a layout helper.
        let columns = 5
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemWidth = floor((size.width - 2*LayoutHelpers.sideMargins) / CGFloat(columns))
        let itemHeight = PictureCell.height(forWidth: itemWidth, imageAspectRatio: 1.5)
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
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
