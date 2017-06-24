//
//  ScanQRCodeViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/24/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var scanPlaceHolder: UIImageView!
    var captureSession: AVCaptureSession? = nil

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        do {
            let captureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let captureInput: AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: captureDevice)
            captureSession = AVCaptureSession.init()
            captureSession?.addInput(captureInput)
            let captureMetadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput.init()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            let videoPreviewLayer: AVCaptureVideoPreviewLayer? = AVCaptureVideoPreviewLayer.init(session: captureSession)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.frame = scanPlaceHolder.bounds
            scanPlaceHolder.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            let notValid: UIAlertController = UIAlertController.init(title: "Error", message: "Camera access denied!", preferredStyle: .alert)
            let OKButton: UIAlertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            notValid.addAction(OKButton)
            self.present(notValid, animated: true, completion: nil)
            return
        }
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            return
        }
        for metadataObject in metadataObjects {
            if (metadataObject as AnyObject).type == AVMetadataObjectTypeQRCode {
                RemoteProfileTableViewController.scannedString = (metadataObject as! AVMetadataMachineReadableCodeObject).stringValue
                captureSession?.stopRunning()
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
    }

    @IBAction func loadClicked() {
        let picker: UIImagePickerController = UIImagePickerController.init()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var ok:Bool = false
        let chosenImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let detector: CIDetector? = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        let features: [CIFeature]? = detector?.features(in: CIImage.init(image: chosenImage)!)
        if features!.count > 0 {
            for feature in features! {
                if feature.type == CIFeatureTypeQRCode {
                    RemoteProfileTableViewController.scannedString = (feature as! CIQRCodeFeature).messageString
                    ok = true
                    break
                }
            }
        }
        dismiss(animated: true) {
            if ok {
                self.navigationController?.popViewController(animated: true)
            } else {
                let qrFailed: UIAlertController = UIAlertController.init(title: "Error", message: "No QR Code is detected!", preferredStyle: .alert)
                let OKButton: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                qrFailed.addAction(OKButton)
                self.present(qrFailed, animated: true, completion: nil)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
