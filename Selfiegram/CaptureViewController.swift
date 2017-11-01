//
//  CaptureViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 6/10/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
import AVKit

/// A custom UIView to display a camera preview
class PreviewView : UIView {
    /// layer to show the camera content
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    /// takes an existing capture session and displays it onto previewLayer
    /// - parameter session: the capture session to display
    func setSession(_ session: AVCaptureSession) {
        // Ensure that we only ever do this once for this view
        guard self.previewLayer == nil else {
            NSLog("Warning: \(self.description) attempted to set its preview layer more than once. This is not allowed.")
            return
        }
        
        // Create a preview layer that gets its content from the
        // provided capture session
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        // Fill the contents of the layer, preserving the original
        // aspect ratio.
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        // Add the preview layer to our layer
        self.layer.addSublayer(previewLayer)
        
        // Store a reference to the layer
        self.previewLayer = previewLayer
        
        // Ensure that the sublayer is laid out
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        previewLayer?.frame = self.bounds
    }
    
    /// sets the previewLayer orientation
    /// to be called when the device orientation changes
    /// - parameter orientation: the new orientation for the previewLayer
    func setCameraOrientation(_ orientation : AVCaptureVideoOrientation) {
        previewLayer?.connection?.videoOrientation = orientation
    }
}

/// Responsible for handling all camera related content.
/// From here:
/// * the camera can be previewed
/// * a selfie photo can be taken
/// * the editing view controller is called once a photo is taken
class CaptureViewController: UIViewController {

    typealias CompletionHandler = (UIImage?) -> Void
    /// completion handler once the user has both taken the photo and finished editing it
    var completion : CompletionHandler?
    
    /// the current camera session
    let captureSession = AVCaptureSession()
    /// the output of the camera.
    /// To be used when taking a photo
    let photoOutput = AVCapturePhotoOutput()
    
    /// the view responsible for showing the camera preview
    @IBOutlet weak var cameraPreview: PreviewView!
    
    /// maps the video orientation to the device orientation
    var currentVideoOrientation : AVCaptureVideoOrientation {
        let orientationMap : [UIDeviceOrientation:AVCaptureVideoOrientation] = [
            .portrait: .portrait,
            .landscapeLeft: .landscapeRight,
            .landscapeRight: .landscapeLeft,
            .portraitUpsideDown: .portraitUpsideDown
        ]
        
        let currentOrientation = UIDevice.current.orientation
        
        let videoOrientation = orientationMap[currentOrientation, default: .portrait]
        
        return videoOrientation
    }
    
    override func viewDidLoad() {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.front)
        
        // Get the first available device; bail if we can't find one
        guard let captureDevice = discovery.devices.first else {
            NSLog("No capture devices available.")
            self.completion?(nil)
            return
        }
        
        // Attempt to add this device to the capture session
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch let error {
            NSLog("Failed to add camera to capture session: \(error)")
            self.completion?(nil)
        }
        
        // Configure the camera to use high-resolution
        // capture settings
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        // Begin the capture session
        captureSession.startRunning()
        
        // Add the photo output to the session, so that
        // it can receive photos when it wants them
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        self.cameraPreview.setSession(captureSession)
        
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        // keep the video preview and device orientations together
        self.cameraPreview?.setCameraOrientation(currentVideoOrientation)
    }
    
    /// called when the user taps on the camera preview
    /// will take the current camera image and save this
    /// - parameter sender: the object that triggered this event
    @IBAction func takeSelfie(_ sender: Any) {
        // Get a connection to the output
        guard let videoConnection = photoOutput.connection(with: AVMediaType.video) else {
            NSLog("Failed to get camera connection")
            return
        }
        
        // Set its orientation, so that the image is oriented correctly
        videoConnection.videoOrientation = currentVideoOrientation
        
        // Indicate that we want the data it captures to be in JPEG format
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        // Begin capturing a photo; it will call photoOutput(_, didFinishProcessingPhoto:, error:)
        // when done
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    /// called when the user exits the camera without taking a photo
    @IBAction func close(_ sender: Any) {
        self.completion?(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? EditingViewController else {
            fatalError("The destination view controller is not configured correctly.")
        }
        
        guard let image = sender as? UIImage else {
            fatalError("Expected to receive an image.")
        }
        
        // Give the view controller the image we just captured, and the completion handler
        // it should call when the user has finished editing the image.
        destination.image = image
        destination.completion = self.completion
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // restarting the session if necessary
        if !self.captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
}

extension CaptureViewController : AVCapturePhotoCaptureDelegate {
    // called when AVKit has finished capturing the photo
    // moves to the editing view controller once complete
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            NSLog("Failed to get the photo: \(error)")
            return
        }
        // collecting a JPEG from the camera
        guard let jpegData = photo.fileDataRepresentation(),
              let image = UIImage(data: jpegData) else {
                NSLog("Failed to get image from encoded data")
                return
        }
        
        // seguing to the editing view controller
        self.captureSession.stopRunning()
        self.performSegue(withIdentifier: "showEditing", sender: image)
    }
}
