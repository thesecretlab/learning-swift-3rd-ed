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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
