//
//  RemoteProfileTableViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/22/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class RemoteProfileTableViewController: UITableViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var publicKey: UITextField!

    static var showProfile: RemoteProfile? = nil
    static var scannedString: String? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if RemoteProfileTableViewController.showProfile != nil {
            name.text = RemoteProfileTableViewController.showProfile?.name
            publicKey.text = RemoteProfileTableViewController.showProfile?.publicKey.base64EncodedString()
        }
        if RemoteProfileTableViewController.scannedString != nil {
            publicKey.text = RemoteProfileTableViewController.scannedString
            RemoteProfileTableViewController.scannedString = nil
        }
    }

    @IBAction func cancelClicked() {
        RemoteProfileTableViewController.showProfile = nil
        self.navigationController?.popViewController(animated: true)
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
        if publicKeyData != nil {
            let tmpRemoteProfile: RemoteProfile = RemoteProfile.init()
            tmpRemoteProfile.name = name.text!
            tmpRemoteProfile.publicKey = publicKeyData!
            if tmpRemoteProfile.isValidKey() {
                if RemoteProfileTableViewController.showProfile == nil {
                    ProfilesTableViewController.remoteProfiles.append(tmpRemoteProfile)
                } else {
                    RemoteProfileTableViewController.showProfile?.name = tmpRemoteProfile.name
                    RemoteProfileTableViewController.showProfile?.publicKey = tmpRemoteProfile.publicKey
                }
                RemoteProfileTableViewController.showProfile = nil
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
        let invalidPublicKey: UIAlertController = UIAlertController.init(title: "Error", message: "You entered an invalid public key!", preferredStyle: .alert)
        let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            self.publicKey.text = ""
            self.publicKey.becomeFirstResponder()
        })
        invalidPublicKey.addAction(OKAction)
        self.present(invalidPublicKey, animated: true, completion: nil)
    }

    @IBAction func nameDone() {
        publicKey.becomeFirstResponder()
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

    @IBAction func showQRCodeClicked() {
        self.performSegue(withIdentifier: "ShowShowQRCode", sender: self)
    }
}
