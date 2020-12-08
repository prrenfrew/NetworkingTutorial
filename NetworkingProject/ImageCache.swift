//
//  ImageCache.swift
//  NetworkingProject
//
//  Created by MAC on 12/8/20.
//

import Foundation

final class ImageCache {
  
  static let shared = ImageCache()
  
  private let cache = NSCache<NSURL, NSData>()
  
  private init() { }
  
  func saveImageData(data: Data, with url: URL) {
    self.cache.setObject(data as NSData,
                         forKey: url as NSURL)
  }
  
  func getImageData(from url: URL) -> Data? {
    return self.cache.object(forKey: url as NSURL) as Data?
  }
}
