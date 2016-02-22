//
//  ViewController.swift
//  SelfieGIF
//
//  Created by Anthony Devincenzi on 2/22/16.
//  Copyright © 2016 Anthony Devincenzi. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import AssetsLibrary
import Regift
import Gifu


class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var delegate : AVCaptureFileOutputRecordingDelegate?
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var imageGifView: AnimatableImageView!
    var generatedGifPath:String!
    
    override func viewWillAppear(animated: Bool) {
        //
        //        captureSession = AVCaptureSession()
        //        captureSession!.sessionPreset = AVCaptureSessionPresetHigh
        //
        //        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        //
        //        var error: NSError?
        //        var input: AVCaptureDeviceInput!
        //        do {
        //            input = try AVCaptureDeviceInput(device: backCamera)
        //        } catch let error1 as NSError {
        //            error = error1
        //            input = nil
        //        }
        //
        //        if error == nil && captureSession!.canAddInput(input) {
        //            captureSession!.addInput(input)
        //
        //            stillImageOutput = AVCaptureStillImageOutput()
        //            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        //            if captureSession!.canAddOutput(stillImageOutput) {
        //                captureSession!.addOutput(stillImageOutput)
        //
        //                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        //                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        //                previewView.layer.addSublayer(previewLayer!)
        //
        //                captureSession!.startRunning()
        //            }
        //        }
        //
        //        let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
        //
        //        var videoFileOutput = AVCaptureMovieFileOutput()
        //        captureSession?.addOutput(videoFileOutput)
        //
        //        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        //        let filePath = documentsURL.URLByAppendingPathComponent("test1.mp4")
        //
        //        //videoFileOutput.startRecordingToOutputFileURL(filePath, recordingDelegate: recordingDelegate)
        //
        //        delay(1) { () -> () in
        //            //videoFileOutput.stopRecording()
        //        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //previewLayer!.frame = previewView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickRecord(sender: AnyObject) {
        
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var captureDevice:AVCaptureDevice
        
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            
            for device in videoDevices{
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.Front {
                    captureDevice = device
                }
            }
            
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            imagePicker.videoMaximumDuration = 5
            
            presentViewController(imagePicker, animated: true, completion: { () -> Void in
                //
            })
            
        } else {
            print("the camera is not available")
        }
    }
    
    func prepareGIF()
    {
        
        print("making gif")
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent("test.mp4")
        
        let videoAsset = (AVAsset(URL: NSURL(fileURLWithPath: dataPath)))
        let playerItem = AVPlayerItem(asset: videoAsset)
        
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        let frameCount = 16
        let delayTime  = Float(0.2)
        let loopCount  = 0
        let regift = Regift(sourceFileURL: NSURL(fileURLWithPath: dataPath), frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)
        regift.createGif()
        
        let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(),isDirectory: true)
        let fileURL = tmpDirURL.URLByAppendingPathComponent("regift").URLByAppendingPathExtension("gif")
        
        
        let gifData = NSData(contentsOfURL: fileURL)
        let bundlePath = NSBundle.mainBundle().bundlePath
        gifData?.writeToFile(bundlePath, atomically: false)
        
        //Remember: I edited animateWithImage to not prefer the main bundle
        self.imageGifView.animateWithImage(named: "regift.gif")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            
            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, nil, nil)
            
            let videoData = NSData(contentsOfURL: pickedVideo)
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            let dataPath = documentsDirectory.stringByAppendingPathComponent("test.mp4")
            videoData?.writeToFile(dataPath, atomically: true)
        }
        
        imagePicker.dismissViewControllerAnimated(true) { () -> Void in
            
            self.prepareGIF()
            
        }
        
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("stop recording")
        prepareGIF()
        return
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("recording!")
        return
    }
}

