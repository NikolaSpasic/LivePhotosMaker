//
//  ViewController.swift
//  LiveWallpaper_Demo
//
//  Created by VTS AppsTeam on 1/30/19.
//  Copyright © 2019 VTS AppsTeam. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import PhotosUI
import MobileCoreServices

struct FilePaths {
    static let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask,true)[0] as AnyObject
    struct VidToLive {
        static var livePath = FilePaths.documentsPath.appending("/")
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var imageHolder: UIImageView!
    @IBOutlet weak var makeLPButton: UIButton!
    
    var livePhotoDone: PHLivePhoto?
    var numberOfExecutedTimes = 0
    var stillImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeLPButton.layer.cornerRadius = 5
        stillImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "beachpic", ofType:"jpeg")!)
        imageHolder.image = stillImage
    }

    @IBAction func makePhotoTapped(_ sender: Any) {
        let overlay = ViewController.makeOverlay(over: self)
        if livePhotoDone == nil {
            numberOfExecutedTimes = 0
            guard let imgPath =  Bundle.main.path(forResource: "beachpic", ofType:"jpeg") else {
                debugPrint("pic not found")
                return
            }
            guard let path = Bundle.main.path(forResource: "beachvid1080", ofType:"mov") else {
                debugPrint("vid not found")
                return
            }
            let urlForVid = URL(fileURLWithPath: path)
            let vidResolution = resolutionForLocalVideo(url: urlForVid)
            if vidResolution!.height > vidResolution!.width && stillImage!.size.height > stillImage!.size.width {
                
                let output = FilePaths.VidToLive.livePath
                let assetIdentifier = UUID().uuidString
                
                let _ = try? FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true, attributes: nil)
                do {
                    try FileManager.default.removeItem(atPath: output + "/IMG.JPG")
                    try FileManager.default.removeItem(atPath: output + "/IMG.MOV")
                    
                } catch {
                    
                }
                
                JPEG(path: imgPath).write(output + "/IMG.JPG",
                                          assetIdentifier: assetIdentifier)
                QuickTimeMov(path: path).write(output + "/IMG.MOV",
                                               assetIdentifier: assetIdentifier)
                makeLivePhoto(completion: {
                    if self.numberOfExecutedTimes == 2 {
                        overlay.removeFromSuperview()
                        self.performSegue(withIdentifier: "previewPhoto", sender: nil)
                    }
                })
            } else {
                overlay.removeFromSuperview()
            }
        } else {
            overlay.removeFromSuperview()
            performSegue(withIdentifier: "previewPhoto", sender: nil)
        }
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
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is LivePhotoVC {
            let vc = segue.destination as? LivePhotoVC
            vc?.livePhoto = livePhotoDone
        }
    }
    
    func makeLivePhoto(completion: @escaping () -> ()) {
        PHLivePhoto.request(withResourceFileURLs: [ URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG")],
                            placeholderImage: nil,
                            targetSize: CGSize.zero,//self.view.bounds.size,
            contentMode: PHImageContentMode.aspectFit,
            resultHandler: { (livePhoto, info) -> Void in
                self.livePhotoDone = livePhoto
                self.numberOfExecutedTimes += 1
                completion()
        })
    }
    
    class func makeOverlay(over viewController: UIViewController, uiEnabled: Bool = true) -> UIView {
        if !uiEnabled
        {
            viewController.view.isUserInteractionEnabled = false
            viewController.navigationController?.view.isUserInteractionEnabled = false
        }
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        let backgroundView = UIView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        backgroundView.backgroundColor = UIColor(red: 000, green: 000, blue: 000, alpha: 0.7)
        
        backgroundView.addSubview(indicator)
        
        backgroundView.center = viewController.view.center
        backgroundView.layer.cornerRadius = 10
        
        let overlay = UIView()
        overlay.frame = viewController.view.window!.frame
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        overlay.addSubview(backgroundView)
        overlay.center = viewController.view.window!.center
        
        viewController.view.window!.addSubview(overlay)
        
        UIView.transition(with: viewController.view.window!, duration: 0.25, options: .transitionCrossDissolve, animations: {
            viewController.view.window!.addSubview(overlay)
        }, completion: nil)
        
        indicator.startAnimating()
        
        return overlay
    }
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}

