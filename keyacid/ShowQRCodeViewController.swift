//
//  ShowQRCodeViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/24/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class ShowQRCodeViewController: UIViewController {

    @IBOutlet weak var QRCode: UIImageView!

    static var publicKey: String = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let filter: CIFilter = CIFilter.init(name: "CIQRCodeGenerator", withInputParameters: [
            "inputMessage" : NSData.init(data: ShowQRCodeViewController.publicKey.data(using: String.Encoding.utf8)!),
            "inputCorrectionLevel" : "H"
            ])!
        let image: CIImage = filter.outputImage!
        var scale: CGFloat = min(QRCode.bounds.width, QRCode.bounds.height) / UIImage.init(ciImage: image).size.width
        scale = CGFloat.init(ceilf(Float.init(scale)))
        let transform: CGAffineTransform = CGAffineTransform.init(scaleX: scale, y: scale)
        QRCode.image = UIImage.init(ciImage: image.applying(transform))
    }

    @IBAction func saveClicked() {
        let originalImage: UIImage = QRCode.image!
        UIGraphicsBeginImageContext(originalImage.size)
        originalImage.draw(in: CGRect.init(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let saveError: UIAlertController = UIAlertController.init(title: "Error", message: "Unable to save the QR Code to your Photos!", preferredStyle: .alert)
            let OKButton: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            saveError.addAction(OKButton)
            present(saveError, animated: true, completion: nil)
        } else {
            let saveSucceed: UIAlertController = UIAlertController.init(title: "Success", message: "The QR Code is saved to your Photos!", preferredStyle: .alert)
            let OKButton: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            saveSucceed.addAction(OKButton)
            present(saveSucceed, animated: true, completion: nil)
        }
    }
}
