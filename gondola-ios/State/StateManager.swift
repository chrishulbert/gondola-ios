//
//  StateManager.swift
//  Gondola TVOS
//
//  Created by Chris on 9/02/2017.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//

import UIKit

class StateManager {
    
    static let shared = StateManager()
    
    var metadata: GondolaMetadata!
    
    var rootNav: UINavigationController!
    
    func appLaunch(loading: LoadingViewController) {
        let start = CACurrentMediaTime()
        requestMetadataUntilSuccess { metadata in
            DispatchQueue.main.async {
                self.metadata = metadata

                // This usually finishes before the intro fade animation does, so allow it to finish.
                let end = CACurrentMediaTime()
                let duration = end - start
                let remainingDelay = 0.5 - duration
                let effectiveDelay = max(0, remainingDelay)
                DispatchQueue.main.asyncAfter(deadline: .now() + effectiveDelay) {
                    let tv = TVViewController(metadata: metadata)
                    let movies = MoviesViewController(metadata: metadata)
                    let tab = UITabBarController()
                    tab.viewControllers = [movies, tv]
                    self.rootNav.setViewControllers([tab], animated: true)
                }
            }
        }
    }

    /// Completes on any thread.
    fileprivate func requestMetadataUntilSuccess(completion: @escaping (GondolaMetadata) -> ()) {
        MetadataService.request {
            switch $0 {
            case .success(let metadata):
                completion(metadata)
                
            case .failure:
                // Wait a second between retries.
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    self.requestMetadataUntilSuccess(completion: completion)
                }
            }
        }
    }
    
}
