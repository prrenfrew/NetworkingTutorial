//
//  NetworkingManager.swift
//  NetworkingProject
//
//  Created by MAC on 12/8/20.
//

import Foundation

enum NetworkError: Error {
  case invalidURLString
  case badData
}


/*
 2 different kinds of networking calls
 
 1. SOAP - more of a protocol. XML
 2. RESTful - more of an architecture. JSON
 
 
 Most of the time, you will be using Restful APIs for a few reasons.
 
 1. nobody likes XML
 2. JSON is generally easier to parse and is not as heavy
 Technically Rest can use XML, there are just benfits from using JSON
 
 
 TCP vs UDP
 
 TCP requires a connection. Important when we need to make sure we get all the data.
 
 UDP does not require a persistent connection. This allows for faster speeds, but the possibility of dropped packets is there when it would be absent in TCP.
 
 Web Sockets - generally not going to be used in projects, but something to be aware of.
 
 Web sockets are good when you need a kind of 2 way connection. For example, chat applications would use web sockets. Another example would be minute by minute stock updates
 
 wss == https
 wss://somewebserver
 */

final class NetworkingManager {
  
  static let shared = NetworkingManager()
  
  private init() { }
  
  /*
   escaping vs nonescaping closure
   
   escaping can be executed outside of the scope of the function it was passed into
   */
  
  /*
   Kinds of requests:
   
   GET - gets information/data. Something to note: Will not use request body. If a get request wants to have different options, then it needs to use query items
   POST - creation of some resource, the new resource is generally defined in the request body
   DELETE - deletes some resource
   PUT - edit/update a resource
   PATCH - edit/updates a resource
   
   Put vs Patch - What is the difference? Put basically replaces the existing object with a new updated object.
   
   Patch is more of a in-place update
   
   Parts of a request:
   
   URL - query items are part of the url
   Body - this will be represented by pure data. The data is generally going to be JSON
   HTTP Verb
   Headers
   */
  
  func getDecodedObject<T: Decodable>(from urlString: String, completion: @escaping (T?, Error?) -> Void) {
    guard let url = URL(string: urlString) else {
      completion(nil, NetworkError.invalidURLString)
      return
    }
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard let data = data else {
        completion(nil, error)
        return
      }
//      guard let pokemon = try? JSONDecoder().decode(T.self, from: data) else {
//        completion(nil, NetworkError.badData)
//        return
//      }
      do {
        let decodedObject = try JSONDecoder().decode(T.self, from: data)
        completion(decodedObject, nil)
      } catch {
        completion(nil, error)
      }
    }.resume()
  }
  
  func getImageData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
    if let imageData = ImageCache.shared.getImageData(from: url) {
      completion(imageData, nil)
      return
    }
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let data = data {
        ImageCache.shared.saveImageData(data: data, with: url)
      }
      completion(data, error)
    }.resume()
  }
}
