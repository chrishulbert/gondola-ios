//
//  MetadataService.swift
//  Gondola TVOS
//
//  Created by Chris Hulbert on 8/2/17.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//

import Foundation

struct MetadataService {
    
    typealias MetadataResult = Result<GondolaMetadata>
    
    static func request(completion: @escaping (MetadataResult) -> ()) {
        ServiceHelpers.jsonRequest(path: "metadata.json") {
            switch $0 {
            case .success(let json):
                completion(.success(GondolaMetadata.parse(from: json)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
