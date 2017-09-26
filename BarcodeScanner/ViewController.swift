//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Ross Bower and Kyra Mawell on 9/25/17.
//  Copyright © 2017 Ross Bower and Kyra Maxwell. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {     var cameraView: CameraView!
    
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if (videoDevice != nil) {
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice)
            
            if (videoDeviceInput != nil) {
                if (session.canAddInput(videoDeviceInput)) {
                    session.addInput(videoDeviceInput)
                }
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                
                metadataOutput.metadataObjectTypes = [
                    AVMetadataObjectTypeEAN13Code,
                    AVMetadataObjectTypeQRCode
                ]
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
        }
        
        session.commitConfiguration()
        
        cameraView.layer.session = session
        cameraView.layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        let videoOrientation: AVCaptureVideoOrientation
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            videoOrientation = .portrait
            
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
            
        case .landscapeLeft:
            videoOrientation = .landscapeLeft
            
        case .landscapeRight:
            videoOrientation = .landscapeRight
            
        default:
            videoOrientation = .portrait
        }
        
        cameraView.layer.connection.videoOrientation = videoOrientation
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadView() {
        cameraView = CameraView()
        
        view = cameraView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sessionQueue.async {
            self.session.stopRunning()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Update camera orientation
        let videoOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            videoOrientation = .portrait
            
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
            
        case .landscapeLeft:
            videoOrientation = .landscapeRight
            
        case .landscapeRight:
            videoOrientation = .landscapeLeft
            
        default:
            videoOrientation = .portrait
        }
        
        cameraView.layer.connection.videoOrientation = videoOrientation
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if (metadataObjects.count > 0 && metadataObjects.first is AVMetadataMachineReadableCodeObject) {
            let scan = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            let barcode_number = scan.stringValue
            var itemName = "Sorry, could not find this object"
            
//            print(barcode_number as Any)
            
//            let baseApi = "http://api.upcdatabase.org/json/a3d445a016d7c34a61b83ff1594ab361/"
            let baseApi = "http://api.walmartlabs.com/v1/items?apiKey=638zffcrmt5gnm994msryvas&upc="
            
            let walmartSubstring = String(describing: barcode_number!.dropFirst()) //Only 12 digits
            
            let tempUrl = baseApi + walmartSubstring
            
//            print("TEMP URL", tempUrl)
        
            
            let urlString = URL(string: tempUrl)
            
            if let url = urlString {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        print(error)
                    } else {
                        if let usableData = data {
                            //print(usableData)
                            
                            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                            
                            if let jsonDict = json as? [String: [Any]] {
//                                print("DICT", jsonDict)
                                if let items = jsonDict["items"] as? [[String:Any]], !items.isEmpty {
                                    itemName = items[0]["name"]! as! String
//                                    print("ITEM", itemName)

                                }
                                
                                let alertMessage = "Barcode Number: " + barcode_number! + "\n" + itemName
                                let alertController = UIAlertController(title: "Barcode Scanned", message: alertMessage, preferredStyle: .alert)
                                
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    
                }
                
            task.resume()
        }
    }
    }}

class CameraView: UIView {
    override class var layerClass: AnyClass {
        get {
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    override var layer: AVCaptureVideoPreviewLayer {
        get {
            return super.layer as! AVCaptureVideoPreviewLayer
        }
    }
}
