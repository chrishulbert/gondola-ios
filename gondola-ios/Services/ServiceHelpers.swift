//
//  ServiceHelpers.swift
//  Gondola TVOS
//
//  Created by Chris Hulbert on 8/2/17.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//

import Foundation
import UIKit

struct ServiceHelpers {
    
    typealias JsonResult = Result<[AnyHashable: Any]>
    typealias ImageResult = Result<UIImage>
    
    /// Returns on any thread.
    static func jsonRequest(path: String, completion: @escaping (JsonResult) -> ()) {
        guard let url = url(path: path) else {
            completion(.failure(ServiceError.badUrl))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            completion(jsonResult(data: data, response: response, error: error))
        }
        task.resume()
    }
    
    static func imageRequest(path: String, completion: @escaping (ImageResult) -> ()) {
        guard let url = url(path: path) else {
            completion(.failure(ServiceError.badUrl))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            completion(imageResult(data: data, response: response, error: error))
        }
        task.resume()
    }
    
    static func url(path: String) -> URL? {
        guard let encoded = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else { return nil }
        return URL(string: encoded, relativeTo: K.baseUrl)
    }
    
    fileprivate static func jsonResult(data: Data?, response: URLResponse?, error: Error?) -> JsonResult {
        if let error = error {
            return .failure(error)
        }
        if let response = response as? HTTPURLResponse, response.statusCode > 400 {
            return .failure(ServiceError.httpError(response.statusCode))
        }
        guard let data = data else {
            return .failure(ServiceError.noData)
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return .failure(ServiceError.notJson)
        }
        guard let dict = json as? [AnyHashable: Any] else {
            return .failure(ServiceError.notDictionary)
        }
        return .success(dict)
    }

    fileprivate static func imageResult(data: Data?, response: URLResponse?, error: Error?) -> ImageResult {
        if let error = error {
            return .failure(error)
        }
        if let response = response as? HTTPURLResponse, response.statusCode > 400 {
            return .failure(ServiceError.httpError(response.statusCode))
        }
        guard let data = data else {
            return .failure(ServiceError.noData)
        }
        guard let image = UIImage(data: data) else {
            return .failure(ServiceError.notImage)
        }
        // TODO load the image to the GPU.
        return .success(image)
    }

    struct K {
        static let baseUrl = URL(string: "http://gondola")!
    }

    enum ServiceError: Error {
        case badUrl
        case httpError(Int)
        case noData
        case notJson
        case notDictionary
        case notImage
    }

}
