//
//  Result.swift
//  Gondola TVOS
//
//  Created by Chris Hulbert on 8/2/17.
//  Copyright © 2017 Chris Hulbert. All rights reserved.
//

import Foundation

enum Result<SuccessType> {
    case success(SuccessType)
    case failure(Error)
}
