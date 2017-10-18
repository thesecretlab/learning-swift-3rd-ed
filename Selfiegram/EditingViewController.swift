//
//  EditingViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 17/10/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
// BEGIN editing_controller_import
import Vision
// END editing_controller_import

// An image view that shows the preview icon of an overlay.
// When tapped, it calls a closure it stores as a property.
// BEGIN editing_overlay_view_class
class OverlaySelectionView : UIImageView {
    
    // BEGIN editing_overlay_view_property
    let overlay : Overlay
    // END editing_overlay_view_property
    
    // BEGIN editing_overlay_view_handler
    typealias TapHandler = () -> Void
    let tapHandler : TapHandler
    // END editing_overlay_view_handler
    
    // BEGIN editing_overlay_view_init
    init(overlay: Overlay, tapHandler: @escaping TapHandler) {
        
        self.overlay = overlay
        self.tapHandler = tapHandler
        
        super.init(image: overlay.previewIcon)
        
        self.isUserInteractionEnabled = true
        
        // The method we'll be calling when tapped
        let tappedMethod = #selector(OverlaySelectionView.tapped(tap:))
        
        // Create and add a tap recognizer that runs the desired method when tapped
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: tappedMethod)
        self.addGestureRecognizer(tapRecognizer)
    }
    // END editing_overlay_view_init
    
    // BEGIN editing_overlay_view_bad_init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // END editing_overlay_view_bad_init
    
    // BEGIN editing_overlay_view_tap
    @objc func tapped(tap: UITapGestureRecognizer) {
        self.tapHandler()
    }
    // END editing_overlay_view_tap
}
// END editing_overlay_view_class

class EditingViewController: UIViewController {
    
    // BEGIN editing_controller_helpers
    // There are two kinds of eyebrows: the left, and the right
    enum EyebrowType { case left, right }
    
    // An eyebrow is a combination of its type and its position
    typealias EyebrowPosition = (type: EyebrowType, position: CGPoint)
    
    // DetectionResult represents either a successful detection or a failure;
    // it uses associated values to carry additional context
    enum DetectionResult {
        case error(Error)
        case success([EyebrowPosition])
    }
    // We have one type of error: we didn't find any eyebrows
    enum DetectionError : Error { case noResults }
    
    // A detection completion is a closure that's used to receive a detection result
    typealias DetectionCompletion = (DetectionResult) -> Void
    // END editing_controller_helpers

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var optionsStackView: UIStackView!
    
    // BEGIN editing_controller_images
    // The image we received from the CaptureViewController.
    var image : UIImage?
    
    // The image that we'll create by drawing eyebrows on top.
    var renderedImage : UIImage?
    // END editing_controller_images
    
    // BEGIN editing_controller_eyebrow_list
    // The list of eyebrow positions we detected.
    var eyebrows : [EyebrowPosition] = []
    // END editing_controller_eyebrow_list
    
    // BEGIN editing_controller_overlay_properties
    var overlays : [Overlay] = []
    
    var currentOverlay : Overlay? = nil {
        didSet {
            guard currentOverlay != nil else { return }
            redrawImage()
        }
    }
    // END editing_controller_overlay_properties
    
    // BEGIN editing_controller_handler_property
    var completion : CaptureViewController.CompletionHandler?
    // END editing_controller_handler_property
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BEGIN editing_controller_viewDidLoad_1
        guard let image = image else {
            self.completion?(nil)
            return
        }
        self.imageView.image = image
        
        // setting up the overlay information
        overlays = OverlayManager.shared.availableOverlays()
        
        for overlay in overlays {
            
            let overlayView = OverlaySelectionView(overlay: overlay) {
                self.currentOverlay = overlay
            }
            
            overlays.append(overlay)
            
            optionsStackView.addArrangedSubview(overlayView)
        }
        
        // adding in a done button
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .done,
                                              target: self,
                                              action: #selector(done))
        navigationItem.rightBarButtonItem = addSelfieButton
        // END editing_controller_viewDidLoad_1
        
        // BEGIN editing_controller_viewDidLoad_2
        self.detectEyebrows(image: image, completion: { (eyebrows) in
            self.eyebrows = eyebrows
        })
        // END editing_controller_viewDidLoad_2
    }
    
    // BEGIN editing_controller_done_func
    @objc func done(){
        let imageToReturn = self.renderedImage ?? self.image
        
        self.completion?(imageToReturn)
    }
    // END editing_controller_done_func
    
    // BEGIN editing_controller_redraw
    func redrawImage(){
        // Ensure that we have an overlay to draw, and an image to draw it on
        guard let overlay = self.currentOverlay,
              let image = self.image else {
            return
        }
        
        // Start drawing and when we're done, make sure we cleanly stop drawing.
        UIGraphicsBeginImageContext(image.size)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        // Start by drawing the base image
        image.draw(at: CGPoint.zero)
        
        // For each eyebrow that we know about, draw it
        for eyebrow in self.eyebrows {
            
            // Pick the appropriate image to use, based on which eyebrow it is
            let eyebrowImage : UIImage
            
            switch eyebrow.type {
            case .left:
                eyebrowImage = overlay.leftImage
            case .right:
                eyebrowImage = overlay.rightImage
            }
            
            // The coordinates we receive are flipped (ie (0,0) is at the bottom-right,
            // not the top-left), so we flip them account for that.
            var position = CGPoint(x: image.size.width - eyebrow.position.x,
                                   y: image.size.height - eyebrow.position.y)
            
            // Drawing an image at a position places that image's top-left
            // corner at that position. We want the image to be centered on the
            // position, so we adjust by 50% of the width and height.
            position.x -= eyebrowImage.size.width / 2.0
            position.y -= eyebrowImage.size.height / 2.0
            
            // We're finally ready to draw this eyebrow!
            eyebrowImage.draw(at: position)
        }
        
        // We're now done drawing the eyebrows, so grab the image and store it
        self.renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Also display the image in the image view
        self.imageView.image = self.renderedImage
    }
    // END editing_controller_redraw
    
    // BEGIN editing_controller_detect_eyebrows
    func detectEyebrows(image: UIImage, completion: @escaping ([EyebrowPosition])->Void) {
        detectFaceLandmarks(image: image) { (result) in
            switch result {
            case .error(let error):
                // Just pass back the original image
                NSLog("Error detecting eyebrows: \(error)")
                completion([])
            case .success(let results):
                completion(results)
            }
        }
    }
    // END editing_controller_detect_eyebrows
    
    // BEGIN editing_controller_eyebrow_handler
    private func locateEyebrowsHandler(_ request: VNRequest,
                                       imageSize: CGSize,
                                       completion: DetectionCompletion) {
        
        // If we don't have one, then we have no eyebrows to detect, and must error out.
        guard let firstFace = request.results?.first as? VNFaceObservation else {
            completion(.error(DetectionError.noResults))
            return
        }
        
        // Landmark regions contain multiple points, which describe their contour. In
        // this app, we just want to know where to stick the eyebrow image, so we don't
        // need the whole contour, just an idea of 'where' the eyebrow is. We can get that
        // by taking the average of all points. This internal function does that.
        func averagePosition(for landmark: VNFaceLandmarkRegion2D) -> CGPoint {
            
            // Get all of the points in the image
            let points = landmark.pointsInImage(imageSize: imageSize)
            
            // Add up all the points
            var averagePoint = points.reduce(CGPoint.zero, {
                return CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)
            })
            
            // And divide by the number of points, producing the average point
            averagePoint.x /= CGFloat(points.count)
            averagePoint.y /= CGFloat(points.count)
            
            return averagePoint
        }
        
        // Start building a list of eyebrows
        var results : [EyebrowPosition] = []
        
        // Try and get each eyebrow, calculate its position, and store it in
        // the list of results
        if let leftEyebrow = firstFace.landmarks?.leftEyebrow {
            let position = averagePosition(for: leftEyebrow)
            results.append( (type: .left, position: position) )
        }
        
        if let rightEyebrow = firstFace.landmarks?.rightEyebrow {
            let position = averagePosition(for: rightEyebrow)
            results.append( (type: .right, position: position) )
        }
        
        // We're done! Pass a value indicating success, with its associated results.
        completion(.success(results))
    }
    // END editing_controller_eyebrow_handler
    
    // BEGIN editing_controller_detect_landmarks
    // Given an image, detect eyebrows and pass it back to a completion handler
    func detectFaceLandmarks(image: UIImage, completion: @escaping DetectionCompletion) {
        
        // Prepare a request to detect face landmarks (eg facial features like
        // nose, eyes, eyebrows, etc)
        let request = VNDetectFaceLandmarksRequest { [unowned self] request, error in
            
            if let error = error {
                completion(.error(error))
                return
            }
            
            // The request now contains the face landmark data. Pass it off to our handler
            // function which will extract the specific info this app cares about.
            self.locateEyebrowsHandler(request,
                                       imageSize: image.size,
                                       completion: completion)
        }
        
        // Create a handler that uses the image we care about
        let handler = VNImageRequestHandler(cgImage: image.cgImage!,
                                            orientation: .leftMirrored,
                                            options: [:])
        
        // Attempt to perform the request on the hander, and catch any error
        do {
            try handler.perform([request])
        }
        catch {
            completion(.error(error))
        }
        
    }
    // END editing_controller_detect_landmarks

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
