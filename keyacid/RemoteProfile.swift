//
//  RemoteProfile.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/21/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Sodium

class RemoteProfile {

    var name: String = ""
    var publicKey: Data = Data.init(count: crypto_sign_ed25519_publickeybytes())

    func isValidKey() -> Bool {
        return publicKey.count == crypto_sign_ed25519_publickeybytes()
    }

    func curve25519PublicKey() -> Data {
        if !isValidKey() {
            return Data.init()
        }
        var curve: Data = Data.init(count: crypto_scalarmult_curve25519_bytes())
        if (curve.withUnsafeMutableBytes { (curve: UnsafeMutablePointer<UInt8>) -> Int32 in
            return publicKey.withUnsafeBytes({ (publicKey: UnsafePointer<UInt8>) -> Int32 in
                return crypto_sign_ed25519_pk_to_curve25519(curve, publicKey)
            })
        }) == 0 {
            return curve
        }
        return Data.init()
    }

    func toDict() -> [String : String] {
        return [
            "name" : name,
            "publicKey" : publicKey.base64EncodedString()
        ]
    }

    class func fromDict(dict: [String : String]) -> RemoteProfile {
        let ret: RemoteProfile = RemoteProfile.init()
        ret.name = dict["name"]!
        ret.publicKey = Data.init(base64Encoded: dict["publicKey"]!)!
        return ret
    }
}
