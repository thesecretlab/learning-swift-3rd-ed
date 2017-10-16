//
//  OverlayStore.swift
//  Selfiegram
//
//  Created by Tim Nugent on 11/10/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import Foundation
// BEGIN overlay_import
import UIKit.UIImage
// END overlay_import

// BEGIN overlay_information_struct
struct OverlayInformation: Codable {
    let icon : String
    let leftImage : String
    let rightImage : String
}
// END overlay_information_struct

// BEGIN overlay_error
enum OverlayManagerError: Error {
    case noDataLoaded
    case cannotParseData(underlyingError: Error)
}
// END overlay_error

// BEGIN overlay_mananger_class
final class OverlayManager {
    // BEGIN overlay_manager_shared
    static let shared = OverlayManager()
    // END overlay_manager_shared
    
    // BEGIN overlay_managed_list
    typealias OverlayList = [OverlayInformation]
    private var overlayInfo : OverlayList
    // END overlay_managed_list
    
    // BEGIN overlay_manager_urls
    static let downloadURLBase = URL(string: "https://raw.githubusercontent.com/"
        + "thesecretlab/learning-swift-3rd-ed/master/Data/")!
    static let overlayListURL = URL(string: "overlays.json",
                                    relativeTo: OverlayManager.downloadURLBase)!
    // END overlay_manager_urls
    
    // BEGIN overlay_manager_cache_url
    static var cacheDirectoryURL : URL {
        guard let cacheDirectory =
            FileManager.default.urls(for: .cachesDirectory,
                                     in: .userDomainMask).first else {
            fatalError("Cache directory not found! This should never happen on iOS!")
        }
        return cacheDirectory
    }
    static var cachedOverlayListURL : URL {
        return cacheDirectoryURL.appendingPathComponent("overlays.json", isDirectory: false)
    }
    // END overlay_manager_cache_url
    
    // BEGIN overlay_manager_asset_url
    // Returns the URL for downloading a named image file.
    func urlForAsset(named assetName: String) -> URL? {
        return URL(string: assetName, relativeTo: OverlayManager.downloadURLBase)
    }
    
    // Returns the URL for the cached version of an image file.
    func cachedUrlForAsset(named assetName: String) -> URL? {
        return URL(string: assetName, relativeTo: OverlayManager.cacheDirectoryURL)
    }
    // END overlay_manager_asset_url
    
    // BEGIN overlay_manager_init
    init() {
        do {
            let overlayListData = try Data(contentsOf: OverlayManager.cachedOverlayListURL)
        self.overlayInfo = try JSONDecoder().decode(OverlayList.self, from: overlayListData)

        } catch {
            self.overlayInfo = []
        }
    }
    // END overlay_manager_init
    
    // BEGIN overlay_availableOverlays
    func availableOverlays() -> [Overlay] {
        return overlayInfo.flatMap { Overlay(info: $0) }
    }
    // END overlay_availableOverlays
    
    // BEGIN overlay_refresh
    func refreshOverlays(completion: @escaping (OverlayList?, Error?) -> Void) {
        // Create a data task to download it.
        URLSession.shared.dataTask(with: OverlayManager.overlayListURL) { (data, response, error) in
            
            // Report if we got an error, or for some other reason data is nil
            if let error = error {
                NSLog("Failed to download \(OverlayManager.overlayListURL): \(error)")
                completion(nil, error)
                return
            }
            
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
    // END overlay_refresh
    
    // BEGIN overlay_image_download
    // A group for coordinating multiple simultaneous downloads.
    private let loadingDispatchGroup = DispatchGroup()
    
    // Downloads all assets used by overlays. If 'refresh' is true, the list of overlays
    // is updated first.
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
    // END overlay_image_download
}
// END overlay_mananger_class

// BEGIN overlay_struct
// An Overlay is a container for the images used to present
// an eyebrow choice to the user.
struct Overlay {
    
    // The image to show in the list of eyebrow choices
    let previewIcon: UIImage
    
    // The images to draw on top of the left and right eyebrows
    let leftImage : UIImage
    let rightImage : UIImage
    
    // Creates an Overlay given the names of images to use.
    // The images must be downloaded and stored in the cache,
    // or this initialiser will return nil.
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
// END overlay_struct
