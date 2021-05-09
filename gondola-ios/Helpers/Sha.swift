//
//  Sha.swift
//  gondola-ios
//
//  Created by Chris on 9/5/21.
//  Copyright © 2021 Gondola. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
}
