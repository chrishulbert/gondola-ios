//
//  GetBookmarkService.swift
//  gondola-ios
//
//  Created by Chris on 9/5/21.
//  Copyright © 2021 Gondola. All rights reserved.
//

import Foundation

struct GetBookmarkService {
    // Returns on any thread.
    static func getBookmark(item: String, completion: @escaping (Int) -> ()) {
        let originalUrl = URL(string: "http://gondola.local:35248/bookmark/get")!
        let compsO = URLComponents(url: originalUrl, resolvingAgainstBaseURL: true)
        guard var comps = compsO else { completion(0); return }
        comps.queryItems = [URLQueryItem(name: "item", value: item)]
        let urlO = comps.url
        guard let url = urlO else { completion(0); return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 1
        ServiceHelpers.jsonRequest(request: request, completion: { result in
            switch result {
            case .success(let json):
                let time = json["time"] as? Int ?? 0
                completion(time)

            case .failure(let err):
                print("GetBookmarkService failure: \(err)")
                completion(0)
            }
        })
    }
}
