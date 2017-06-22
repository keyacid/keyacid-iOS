//
//  LocalProfile.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/21/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Sodium

class LocalProfile: RemoteProfile {

    var privateKey: Data = Data.init(count: crypto_sign_ed25519_secretkeybytes())

    override func isValidKey() -> Bool {
        if !super.isValidKey() {
            return false
        }
        if privateKey.count != crypto_sign_ed25519_secretkeybytes() {
            return false
        }
        var tmpPublicKey: Data = Data.init(count: crypto_sign_ed25519_publickeybytes())
        tmpPublicKey.withUnsafeMutableBytes { (tmpPublicKey: UnsafeMutablePointer<UInt8>) -> Void in
            privateKey.withUnsafeBytes({ (privateKey: UnsafePointer<UInt8>) -> Void in
                crypto_sign_ed25519_sk_to_pk(tmpPublicKey, privateKey)
            })
        }
        return tmpPublicKey == publicKey
    }

    func generateKeyPair() {
        publicKey = Data.init(count: crypto_sign_ed25519_publickeybytes())
        privateKey = Data.init(count: crypto_sign_ed25519_secretkeybytes())
        publicKey.withUnsafeMutableBytes { (publicKey: UnsafeMutablePointer<UInt8>) -> Void in
            privateKey.withUnsafeMutableBytes({ (privateKey: UnsafeMutablePointer<UInt8>) -> Void in
                crypto_sign_ed25519_keypair(publicKey, privateKey)
            })
        }
    }

    func generatePublicKey() -> Bool {
        if privateKey.count != crypto_sign_ed25519_secretkeybytes() {
            return false
        }
        publicKey = Data.init(count: crypto_sign_ed25519_publickeybytes())
        publicKey.withUnsafeMutableBytes { (publicKey: UnsafeMutablePointer<UInt8>) -> Void in
            privateKey.withUnsafeBytes({ (privateKey: UnsafePointer<UInt8>) -> Void in
                crypto_sign_ed25519_sk_to_pk(publicKey, privateKey)
            })
        }
        return true
    }

    func curve25519PrivateKey() -> Data {
        if !isValidKey() {
            return Data.init()
        }
        var curve: Data = Data.init(count: crypto_scalarmult_curve25519_bytes())
        if (curve.withUnsafeMutableBytes { (curve: UnsafeMutablePointer<UInt8>) -> Int32 in
            return privateKey.withUnsafeBytes({ (privateKey: UnsafePointer<UInt8>) -> Int32 in
                return crypto_sign_ed25519_sk_to_curve25519(curve, privateKey)
            })
        }) == 0 {
            return curve
        }
        return Data.init()
    }
}
