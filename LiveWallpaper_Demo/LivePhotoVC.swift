//
//  LivePhotoVC.swift
//  LiveWallpaper Demo
//
//  Created by VTS AppsTeam on 1/24/19.
//  Copyright © 2019 VTS AppsTeam. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

class LivePhotoVC: UIViewController {
    
    @IBOutlet weak var cancelBttn: UIButton!
    @IBOutlet weak var downloadBttn: UIButton!
    var livePhoto: PHLivePhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelBttn.layer.cornerRadius = 5
        downloadBttn.layer.cornerRadius = 5
        presentView()
    }
    
    @IBAction func cancelBttnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadBttnPressed(_ sender: Any) {
        exportLivePhoto()
    }
    func presentView() {
        let livePhotoView: PHLivePhotoView = PHLivePhotoView.init(frame: self.view.bounds)
        livePhotoView.livePhoto = livePhoto
        livePhotoView.contentMode = .scaleAspectFill
        self.view.addSubview(livePhotoView)
        self.view.sendSubviewToBack(livePhotoView)
    }
    
    func exportLivePhoto () {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            
            
            creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), options: options)
            creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG"), options: options)
            
        }, completionHandler: { (success, error) -> Void in
            if !success {
                NSLog((error?.localizedDescription)!)
                LivePhotoVC.displayInformation(self, title: "Photo not saved", message: "Please try again.")
            } else if success {
                LivePhotoVC.displayInformation(self, title: "Download successful", message: "Live photo saved to gallery.")
            }
        })
    }
    
    static func displayInformation(_ viewController: UIViewController, title: String, message: String)
    {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
}
