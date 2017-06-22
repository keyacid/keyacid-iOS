//
//  Crypto.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/21/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Sodium

class Crypto {

    static func encrypt(data: Data, from: LocalProfile, to: RemoteProfile) -> Data {
        if !from.isValidKey() || !to.isValidKey() {
            return Data.init()
        }
        var nonce: Data = Data.init(count: crypto_box_noncebytes())
        nonce.withUnsafeMutableBytes { (noncePtr: UnsafeMutablePointer<UInt8>) -> Void in
            randombytes_buf(noncePtr, nonce.count)
        }
        var ret: Data = Data.init(count: crypto_box_macbytes() + data.count)
        if (ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Int32 in
            return data.withUnsafeBytes({ (dataPtr: UnsafePointer<UInt8>) -> Int32 in
                return nonce.withUnsafeBytes({ (nonce: UnsafePointer<UInt8>) -> Int32 in
                    return to.curve25519PublicKey().withUnsafeBytes({ (to: UnsafePointer<UInt8>) -> Int32 in
                        return from.curve25519PrivateKey().withUnsafeBytes({ (from: UnsafePointer<UInt8>) -> Int32 in
                            return crypto_box_easy(ret, dataPtr, UInt64.init(data.count), nonce, to, from)
                        })
                    })
                })
            })
        }) == 0 {
            return nonce + ret
        }
        return Data.init()
    }

    static func decrypt(data: Data, from: RemoteProfile, to: LocalProfile) -> Data {
        if !from.isValidKey() || !to.isValidKey() {
            return Data.init()
        }
        if data.count < crypto_box_noncebytes() + crypto_box_macbytes() {
            return Data.init()
        }
        var ret: Data = Data.init(count: data.count - crypto_box_noncebytes() - crypto_box_macbytes())
        if (ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Int32 in
            return data.withUnsafeBytes({ (dataPtr: UnsafePointer<UInt8>) -> Int32 in
                return from.curve25519PublicKey().withUnsafeBytes({ (from: UnsafePointer<UInt8>) -> Int32 in
                    return to.curve25519PrivateKey().withUnsafeBytes({ (to: UnsafePointer<UInt8>) -> Int32 in
                        return crypto_box_open_easy(ret, dataPtr + crypto_box_noncebytes(), UInt64.init(data.count - crypto_box_noncebytes()), dataPtr, from, to)
                    })
                })
            })
        }) == 0 {
            return ret
        }
        return Data.init()
    }

    static func sealedEncrypt(data: Data, to: RemoteProfile) -> Data {
        if !to.isValidKey() {
            return Data.init()
        }
        var ret: Data = Data.init(count: crypto_box_sealbytes() + data.count)
        if (ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Int32 in
            return data.withUnsafeBytes({ (dataPtr: UnsafePointer<UInt8>) -> Int32 in
                return to.curve25519PublicKey().withUnsafeBytes({ (to: UnsafePointer<UInt8>) -> Int32 in
                    return crypto_box_seal(ret, dataPtr, UInt64.init(data.count), to)
                })
            })
        }) == 0 {
            return ret
        }
        return Data.init()
    }

    static func sealedDecrypt(data: Data, to: LocalProfile) -> Data {
        if !to.isValidKey() {
            return Data.init()
        }
        if data.count < crypto_box_sealbytes() {
            return Data.init()
        }
        var ret: Data = Data.init(count: data.count - crypto_box_sealbytes())
        if (ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Int32 in
            return data.withUnsafeBytes({ (dataPtr: UnsafePointer<UInt8>) -> Int32 in
                return to.curve25519PublicKey().withUnsafeBytes({ (toPublicKey: UnsafePointer<UInt8>) -> Int32 in
                    return to.curve25519PrivateKey().withUnsafeBytes({ (toPrivateKey: UnsafePointer<UInt8>) -> Int32 in
                        return crypto_box_seal_open(ret, dataPtr, UInt64.init(data.count), toPublicKey, toPrivateKey)
                    })
                })
            })
        }) == 0 {
            return ret
        }
        return Data.init()
    }

    static func sign(data: Data, from: LocalProfile) -> Data {
        if !from.isValidKey() {
            return Data.init()
        }
        var ret: Data = Data.init(count: crypto_sign_bytes())
        ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Void in
            data.withUnsafeBytes({ (dataPtr: UnsafePointer<UInt8>) -> Void in
                from.privateKey.withUnsafeBytes({ (from: UnsafePointer<UInt8>) -> Void in
                    crypto_sign_detached(ret, nil, dataPtr, UInt64.init(data.count), from)
                })
            })
        }
        return ret
    }

    static func verify(data: Data, signature: Data, from: RemoteProfile) -> Bool {
        if !from.isValidKey() {
            return false
        }
        if signature.count != crypto_sign_bytes() {
            return false
        }
        if (signature.withUnsafeBytes { (signature: UnsafePointer<UInt8>) -> Int32 in
            return data.withUnsafeBytes({ (dataPtr: UnsafePointer<UInt8>) -> Int32 in
                return from.publicKey.withUnsafeBytes({ (from: UnsafePointer<UInt8>) -> Int32 in
                    return crypto_sign_verify_detached(signature, dataPtr, UInt64.init(data.count), from)
                })
            })
        }) == 0 {
            return true
        }
        return false
    }
}
