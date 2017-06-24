//
//  SignViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/24/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class SignViewController: UIViewController {

    @IBOutlet weak var signature: UITextField!
    @IBOutlet weak var textView: UITextView!

    func getSelectedRemoteProfile() -> RemoteProfile? {
        if ProfilesTableViewController.selectedRemoteProfileIndex == -1 {
            let remoteProfileNotSelected: UIAlertController = UIAlertController.init(title: "Error", message: "You have to select a remote profile!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.performSegue(withIdentifier: "ShowProfiles", sender: self)
            })
            remoteProfileNotSelected.addAction(OKAction)
            self.present(remoteProfileNotSelected, animated: true, completion: nil)
            return nil
        }
        return ProfilesTableViewController.remoteProfiles[ProfilesTableViewController.selectedRemoteProfileIndex]
    }

    func getSelectedLocalProfile() -> LocalProfile? {
        if ProfilesTableViewController.selectedLocalProfileIndex == -1 {
            let localProfileNotSelected: UIAlertController = UIAlertController.init(title: "Error", message: "You have to select a local profile!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.performSegue(withIdentifier: "ShowProfiles", sender: self)
            })
            localProfileNotSelected.addAction(OKAction)
            self.present(localProfileNotSelected, animated: true, completion: nil)
            return nil
        }
        return ProfilesTableViewController.localProfiles[ProfilesTableViewController.selectedLocalProfileIndex]
    }

    @IBAction func signClicked() {
        let localProfile: LocalProfile? = getSelectedLocalProfile()
        if localProfile == nil {
            return
        }
        let sig: String = Crypto.sign(data: textView.text.data(using: String.Encoding.utf8)!, from: localProfile!).base64EncodedString()
        if sig == "" {
            let empty: UIAlertController = UIAlertController.init(title: "Error", message: "Corrupted profile!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            empty.addAction(OKAction)
            self.present(empty, animated: true, completion: nil)
            return
        }
        signature.text = sig
        UIPasteboard.general.string = sig
    }

    @IBAction func verifyClicked() {
        let sig: Data? = Data.init(base64Encoded: signature.text!)
        if sig == nil {
            let notBase64: UIAlertController = UIAlertController.init(title: "Error", message: "Invalid signature!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            notBase64.addAction(OKAction)
            self.present(notBase64, animated: true, completion: nil)
            return
        }
        let remoteProfile: RemoteProfile? = getSelectedRemoteProfile()
        if remoteProfile == nil {
            return
        }
        if Crypto.verify(data: textView.text.data(using: String.Encoding.utf8)!, signature: sig!, from: remoteProfile!) {
            let success: UIAlertController = UIAlertController.init(title: "Success", message: "This message is signed by " + remoteProfile!.name + "!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            success.addAction(OKAction)
            self.present(success, animated: true, completion: nil)
        } else {
            let error: UIAlertController = UIAlertController.init(title: "Error", message: "Wrong profile or tampered data!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            error.addAction(OKAction)
            self.present(error, animated: true, completion: nil)
        }
    }
}
