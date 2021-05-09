//
//  SetBookmarkService.swift
//  gondola-ios
//
//  Created by Chris on 9/5/21.
//  Copyright © 2021 Gondola. All rights reserved.
//

import Foundation

struct SetBookmarkService {
    static func postBookmark(item: String, time: Int) {
        let url = URL(string: "http://gondola.local:35248/bookmark/set")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let itemEncoded = item.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        request.httpBody = "item=\(itemEncoded)&time=\(time)".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (_, _, _) in })
        task.resume()
    }
}
