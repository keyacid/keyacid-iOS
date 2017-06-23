//
//  LocalProfileTableViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/22/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class LocalProfileTableViewController: UITableViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var privateKey: UITextField!
    @IBOutlet weak var publicKey: UITextField!

    static var showProfile: LocalProfile? = nil

    override func viewWillAppear(_ animated: Bool) {
        if LocalProfileTableViewController.showProfile != nil {
            name.text = LocalProfileTableViewController.showProfile?.name
            publicKey.text = LocalProfileTableViewController.showProfile?.publicKey.base64EncodedString()
            privateKey.text = LocalProfileTableViewController.showProfile?.privateKey.base64EncodedString()
        }
    }

    @IBAction func cancelClicked() {
        LocalProfileTableViewController.showProfile = nil
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func generateKeyPairClicked() {
        let tmpLocalProfile: LocalProfile = LocalProfile.init()
        tmpLocalProfile.generateKeyPair()
        privateKey.text = tmpLocalProfile.privateKey.base64EncodedString()
        publicKey.text = tmpLocalProfile.publicKey.base64EncodedString()
    }

    @IBAction func generatePublicKeyClicked() {
        let tmpLocalProfile: LocalProfile = LocalProfile.init()
        let privateKeyData: Data? = Data.init(base64Encoded: privateKey.text!)
        if privateKeyData != nil {
            tmpLocalProfile.privateKey = privateKeyData!
            if tmpLocalProfile.generatePublicKey() {
                publicKey.text = tmpLocalProfile.publicKey.base64EncodedString()
                return
            }
        }
        let invalidPrivateKey: UIAlertController = UIAlertController.init(title: "Error", message: "You entered an invalid private key!", preferredStyle: .alert)
        let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            self.privateKey.text = ""
            self.privateKey.becomeFirstResponder()
        })
        invalidPrivateKey.addAction(OKAction)
        self.present(invalidPrivateKey, animated: true, completion: nil)
    }

    @IBAction func showQRCodeClicked() {
        self.performSegue(withIdentifier: "ShowShowQRCode", sender: self)
    }

    @IBAction func saveClicked() {
        if name.text == "" {
            let emptyName: UIAlertController = UIAlertController.init(title: "Error", message: "An empty name is not acceptable!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.name.becomeFirstResponder()
            })
            emptyName.addAction(OKAction)
            self.present(emptyName, animated: true, completion: nil)
            return
        }
        let publicKeyData: Data? = Data.init(base64Encoded: publicKey.text!)
        let privateKeyData: Data? = Data.init(base64Encoded: privateKey.text!)
        if publicKeyData != nil && privateKeyData != nil {
            let tmpLocalProfile: LocalProfile = LocalProfile.init()
            tmpLocalProfile.name = name.text!
            tmpLocalProfile.publicKey = publicKeyData!
            tmpLocalProfile.privateKey = privateKeyData!
            if tmpLocalProfile.isValidKey() {
                if LocalProfileTableViewController.showProfile == nil {
                    ProfilesTableViewController.localProfiles.append(tmpLocalProfile)
                } else {
                    LocalProfileTableViewController.showProfile?.name = tmpLocalProfile.name
                    LocalProfileTableViewController.showProfile?.publicKey = tmpLocalProfile.publicKey
                    LocalProfileTableViewController.showProfile?.privateKey = tmpLocalProfile.privateKey
                }
                LocalProfileTableViewController.showProfile = nil
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
        let invalidKey: UIAlertController = UIAlertController.init(title: "Error", message: "You entered invalid keys!", preferredStyle: .alert)
        let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        invalidKey.addAction(OKAction)
        self.present(invalidKey, animated: true, completion: nil)
    }

    @IBAction func nameDone() {
        privateKey.becomeFirstResponder()
    }

    @IBAction func privateKeyDone() {
        privateKey.resignFirstResponder()
    }

    @IBAction func publicKeyDone() {
        publicKey.resignFirstResponder()
    }

    @IBAction func copyPublicKeyClicked() {
        UIPasteboard.general.string = publicKey.text!
        let copied: UIAlertController = UIAlertController.init(title: "Success", message: "The public key is copied!", preferredStyle: .alert)
        let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        copied.addAction(OKAction)
        self.present(copied, animated: true, completion: nil)
    }
}
