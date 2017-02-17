//
//  LoadingViewController.swift
//  Gondola TVOS
//
//  Created by Chris on 9/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var rootView = LoadingView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        rootView.indicator.startAnimating()
    }
    
}

class LoadingView: UIView {
    
    let background = UIImageView(image: UIImage(named: "LaunchImage"))
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    init() {
        super.init(frame: CGRect.zero)
        
        addSubview(background)
        addSubview(indicator)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = bounds.height
        
        background.frame = bounds
        indicator.center = CGPoint(x: w/2, y: round(h*3/4))
    }
    
}
