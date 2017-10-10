//
//  CaptureViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 6/10/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
// BEGIN capture_view_import
import AVKit
// END capture_view_import

// BEGIN capture_view_custom_class
class PreviewView : UIView {
    // BEGIN capture_view_previewLayer
    var previewLayer : AVCaptureVideoPreviewLayer?
    // END capture_view_previewLayer
    
    // BEGIN capture_view_setSession
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
    // END capture_view_setSession
    
    // BEGIN capture_view_layout
    override func layoutSubviews() {
        previewLayer?.frame = self.bounds
    }
    // END capture_view_layout
    
    // BEGIN capture_view_layer_orientation
    func setCameraOrientation(_ orientation : AVCaptureVideoOrientation) {
        previewLayer?.connection?.videoOrientation = orientation
    }
    // END capture_view_layer_orientation
}
// END capture_view_custom_class

class CaptureViewController: UIViewController {

    // BEGIN capture_view_completion_handler
    typealias CompletionHandler = (UIImage?) -> Void
    var completion : CompletionHandler?
    // END capture_view_completion_handler
    
    // BEGIN capture_view_avkit_properties
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    // END capture_view_avkit_properties
    
    @IBOutlet weak var cameraPreview: PreviewView!
    
    // BEGIN capture_view_orientation_property
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
    // END capture_view_orientation_property
    
    // BEGIN capture_view_viewDidLoad
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
    // END capture_view_viewDidLoad
    
    // BEGIN capture_view_layout
    override func viewWillLayoutSubviews() {
        self.cameraPreview?.setCameraOrientation(currentVideoOrientation)
    }
    // END capture_view_layout
    
    @IBAction func takeSelfie(_ sender: Any) {
        // BEGIN capture_view_takeSelfie
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
        // END capture_view_takeSelfie
    }
    @IBAction func close(_ sender: Any) {
        // BEGIN capture_view_close_button
        self.completion?(nil)
        // END capture_view_close_button
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// BEGIN capture_view_extension
extension CaptureViewController : AVCapturePhotoCaptureDelegate {
    // BEGIN capture_view_extension_method
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            NSLog("Failed to get the photo: \(error)")
            return
        }
        
        guard let jpegData = photo.fileDataRepresentation(),
              let image = UIImage(data: jpegData) else {
                NSLog("Failed to get image from encoded data")
                return
        }
        
        self.completion?(image)
    }
    // END capture_view_extension_method
}
// END capture_view_extension
