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
        
        rootView.help.addTarget(self, action: #selector(tapHelp), for: .primaryActionTriggered)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start animating in the blurred version.
        UIView.animate(withDuration: 0.4) {
            self.rootView.launchImage.alpha = 0
        }
        
        // Spin if it takes ages.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.rootView.indicator.alpha = 0
            self.rootView.indicator.startAnimating()
            UIView.animate(withDuration: 0.3) {
                self.rootView.indicator.alpha = 1
            }
        }
        
        // Display the help button after a while.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.rootView.help.alpha = 0
            self.rootView.addSubview(self.rootView.help)
            UIView.animate(withDuration: 0.3, animations: {
                self.rootView.help.alpha = 1
            }, completion: { _ in
                self.setNeedsFocusUpdate()
            })
        }
        
    }
    
    func tapHelp() {
        let a = UIAlertController(title: "Help",
                                  message: "Gondola is a media player that connects to a local server.\nIf you'd like to find more information about how to set up your server, please feel free to review the instructions at:\n\nsplinter.com.au/gondola",
                                  preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        present(a, animated: true, completion: nil)
    }
    
}

class LoadingView: UIView {
    
    let blurImage = UIImageView(image: #imageLiteral(resourceName: "Background"))
    let logoImage = UIImageView(image: #imageLiteral(resourceName: "LaunchLogo"))
    let launchImage = UIImageView(image: UIImage(named: "LaunchImage"))
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let help = UIButton(type: .system)
    
    init() {
        super.init(frame: CGRect.zero)

        addSubview(blurImage)
        
        logoImage.contentMode = .center
        addSubview(logoImage)
        
        addSubview(launchImage)
        addSubview(indicator)
        
        help.setTitle("Help", for: .normal)
        // Don't add it yet, only after a while.
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = bounds.height
        
        blurImage.frame = bounds
        logoImage.frame = bounds
        launchImage.frame = bounds
        indicator.center = CGPoint(x: w/2, y: round(h*3/4))
        
        // Center bottom.
        let helpSize = help.intrinsicContentSize
        help.frame = CGRect(origin: CGPoint(x: round(w/2 - helpSize.width/2),
                                            y: round(h - LayoutHelpers.vertMargins - helpSize.height - 8)), // -8 to compensate for focus growth
            size: helpSize)

    }
    
}
