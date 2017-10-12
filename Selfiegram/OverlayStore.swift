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
    
    // BEGIN overlay_manager_method_stubs
    func availableOverlays() -> [Overlay] { return [] }
    func refreshOverlays(completion: @escaping (OverlayList?, Error?) -> Void){}
    func loadOverlayAssets(refresh : Bool = false, completion: @escaping () -> Void) {}
    // END overlay_manager_method_stubs
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
