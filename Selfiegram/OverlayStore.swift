//
//  OverlayStore.swift
//  Selfiegram
//
//  Created by Tim Nugent on 11/10/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import Foundation
import UIKit.UIImage

/// Holds names of the images that comprise an overlay.
/// Used to load the images later shown to the user
struct OverlayInformation: Codable {
    let icon : String
    let leftImage : String
    let rightImage : String
}

/// Different types of errors that can occur with an overlay.
/// There are two possible issues:
/// * unable to load image data
/// * unable to convert image data into an image
enum OverlayManagerError: Error {
    case noDataLoaded
    case cannotParseData(underlyingError: Error)
}

/// Singleton responsible for downloading and handling overlay images.
final class OverlayManager {
    /// The singleton instance property, is the interface into this class
    static let shared = OverlayManager()
    
    /// the list of all known overlays
    typealias OverlayList = [OverlayInformation]
    private var overlayInfo : OverlayList
    
    /// the base URL where overlay information and images can be found.
    /// Used to build up the specific URLs for images and data files.
    static let downloadURLBase = URL(string: "https://raw.githubusercontent.com/"
        + "thesecretlab/learning-swift-3rd-ed/master/Data/")!
    /// the URL to the JSON file that describes all the different overlays
    static let overlayListURL = URL(string: "overlays.json",
                                    relativeTo: OverlayManager.downloadURLBase)!
    
    /// the URL of the cache folder.
    /// This is where overlay images and data will be saved after download
    static var cacheDirectoryURL : URL {
        guard let cacheDirectory =
            FileManager.default.urls(for: .cachesDirectory,
                                     in: .userDomainMask).first else {
            fatalError("Cache directory not found! This should never happen on iOS!")
        }
        return cacheDirectory
    }
    /// the URL of the cached JSON file that describes the overlays.
    /// will be propogated with information from overlayListURL
    static var cachedOverlayListURL : URL {
        return cacheDirectoryURL.appendingPathComponent("overlays.json", isDirectory: false)
    }
    
    /// creates a URL for a specific file to then later be downloaded.
    /// - parameter assetName: the name of the asset to be downloaded
    /// - returns: the URL to be used for downloading the asset
    func urlForAsset(named assetName: String) -> URL? {
        return URL(string: assetName, relativeTo: OverlayManager.downloadURLBase)
    }
    
    /// creates a URL for a specific file that has already been downloaded.
    /// Functionally identical to the above, but uses the cache directory instead of the download directly to build its URL.
    /// - parameter assetName: the name of the cached asset
    /// - returns: the URL that points to the cached asset
    func cachedUrlForAsset(named assetName: String) -> URL? {
        return URL(string: assetName, relativeTo: OverlayManager.cacheDirectoryURL)
    }
    
    /// Base initialiser for the class.
    /// Sets up overlayInfo property to have the cached information if it exists.
    init() {
        do {
            let overlayListData = try Data(contentsOf: OverlayManager.cachedOverlayListURL)
        self.overlayInfo = try JSONDecoder().decode(OverlayList.self, from: overlayListData)

        } catch {
            self.overlayInfo = []
        }
    }
    
    /// Turns the list of overlay information into overlays.
    /// - returns: an array of overlay objects ready to be displayed
    func availableOverlays() -> [Overlay] {
        return overlayInfo.flatMap { Overlay(info: $0) }
    }
    
    /// Downloads all overlays and recaches them
    /// - parameter completion: the closure to be run when download completes
    func refreshOverlays(completion: @escaping (OverlayList?, Error?) -> Void) {
        // Create a data task to download it.
        URLSession.shared.dataTask(with: OverlayManager.overlayListURL) { (data, response, error) in
            
            // Report if we got an error, or for some other reason data is nil
            if let error = error {
                NSLog("Failed to download \(OverlayManager.overlayListURL): \(error)")
                completion(nil, error)
                return
            }
            // ensuring we have data
            guard let data = data else {
                completion(nil, OverlayManagerError.noDataLoaded)
                return
            }
            
            // Cache the data we got
            do {
                try data.write(to: OverlayManager.cachedOverlayListURL)
            } catch let error {
                NSLog("Failed to write data to \(OverlayManager.cachedOverlayListURL); reason: \(error)")
                completion(nil, error)
            }
            
            // Parse the data and store it locally
            do {
                let overlayList = try JSONDecoder().decode(OverlayList.self, from: data)
                
                self.overlayInfo = overlayList
                
                completion(self.overlayInfo, nil)
                return
                
            } catch let decodeError {
                completion(nil, OverlayManagerError.cannotParseData(underlyingError: decodeError))
            }
            
            }.resume()
    }
    
    /// A dispatch group for coordinating the multiple simultaneous downloads we'll be using to download overlay information and images from the server.
    private let loadingDispatchGroup = DispatchGroup()
    
    /// Downloads all assets used by overlays
    /// - parameter refresh: if true the list of overlays is first refreshed
    /// - parameter completion: the handler to run once the download has finished
    func loadOverlayAssets(refresh : Bool = false, completion: @escaping () -> Void) {
        
        // If we're told to refresh, then do that, and re-run this function with 'refresh' set to false
        if (refresh) {
            self.refreshOverlays(completion: { (overlays, error) in
                self.loadOverlayAssets(refresh:  false, completion: completion)
            })
            return
        }
        
        // For each overlay we know about, download its assets
        for info in overlayInfo {
            
            // Each overlay has three assets; we need to download each one
            let names = [info.icon, info.leftImage, info.rightImage]
            
            // For each asset, we need to figure out:
            // 1. where to get it from
            // 2. where to put it
            typealias TaskURL = (source: URL, destination: URL)
            
            // Create an array of these tuples
            let taskURLs : [TaskURL] = names.flatMap {
                guard let sourceURL
                    = URL(string: $0,
                          relativeTo: OverlayManager.downloadURLBase)
                else {
                    return nil
                }
                
                guard let destinationURL
                    = URL(string: $0,
                          relativeTo: OverlayManager.cacheDirectoryURL)
                else {
                    return nil
                }
                
                return (source: sourceURL, destination: destinationURL)
            }
            
            // Now we know what we need to do, start doing it
            for taskURL in taskURLs {
                // 'enter' causes the dispatch group to register that a job is not yet done
                loadingDispatchGroup.enter()
                
                // Begin the download
                URLSession.shared.dataTask(with: taskURL.source, completionHandler: { (data, response, error) in
                    
                    defer {
                        // This job is now done, so indicate that to the dispatch group
                        self.loadingDispatchGroup.leave()
                    }
                    
                    guard let data = data else {
                        NSLog("Failed to download \(taskURL.source): \(error!)")
                        return
                    }
                    
                    // Grab the data and cache it
                    do {
                        try data.write(to: taskURL.destination)
                    } catch let error {
                        NSLog("Failed to write to \(taskURL.destination): \(error)")
                    }
                }).resume()
            }
        }
        
        // Wait for all downloads to finish and then run the completion block
        loadingDispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}

/// Container object for the three images that make up an overlay.
/// Intended to be displayed to the user and not stored
struct Overlay {
    
    /// The image to show in the list of eyebrow choices to the user
    let previewIcon: UIImage
    
    /// The image to draw on top of the left eyebrow
    let leftImage : UIImage
    /// The image to draw on top of the right eyebrow
    let rightImage : UIImage
    
    /// Failiable initialiser, creates an Overlay given the names of images to use.
    /// The images must be already downloaded and stored in the cache, or this initialiser will return nil.
    /// - parameter info: the information necessary to create the overlay images
    init?(info: OverlayInformation) {
        // Construct the URLs that would point to the cached images.
        guard
            let previewURL = OverlayManager.shared.cachedUrlForAsset(named: info.icon),
            let leftURL = OverlayManager.shared.cachedUrlForAsset(named: info.leftImage),
            let rightURL = OverlayManager.shared.cachedUrlForAsset(named: info.rightImage) else {
                return nil
        }
        
        // Attempt to get the images. If any of them fail, we return nil.
        guard
            let previewImage = UIImage(contentsOfFile: previewURL.path),
            let leftImage = UIImage(contentsOfFile: leftURL.path),
            let rightImage = UIImage(contentsOfFile: rightURL.path) else {
                return nil
        }
        
        // We've got the images, so store them.
        self.previewIcon = previewImage
        self.leftImage = leftImage
        self.rightImage = rightImage
    }
}
