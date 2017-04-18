//
//  ImageDownloader.swift
//  ImageLoadTest
//
//  Created by Rui Ong on 15/04/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

//Cache
//Cache is cleared at AppDelegate, everytime user enters into background.

//Downloader
//If cache is not available, new UrlRequest will be created.
//Each source that request for the same Url will have a unique receiptID.
//All receiptIDs are appended to an array attached to the UrlRequest.
//Cancellation is done by removing receiptID from the array. Cancellation should not be done by removing the entire UrlRequest which will affect other sources.
//At completion, each source with a valid receiptID (if not cancelled) will be returned with the downloaded image/json etc.


import Foundation
import UIKit

public let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
public var currentDatatask : URLSessionDataTask?
public var urlCache = NSCache<NSString, AnyObject>()
public var requestsOnQueue : [Downloader.Request] = []

open class Downloader {
    
    public init(){}
    
    open class Request {
        var stringUrl : String?
        var request : URLRequest?
        var recieptIDs = [String]()
        var reuseableData : Data?
    }
    
    func retrieveUrlRequest(url : String) -> Request? {
        
        var urlRequest : URLRequest?
        
        for eachRequest in requestsOnQueue {
            if url == eachRequest.stringUrl {
                urlRequest = eachRequest.request
                
                return eachRequest
            }
        }
        return nil
    }
    
    func createNewUrlRequest(stringUrl : String) -> Request {
        
        let validUrl = URL(string: stringUrl)
        
        let newRequest = Request()
        newRequest.stringUrl = stringUrl
        newRequest.request = URLRequest(url: validUrl!)
        requestsOnQueue.append(newRequest)
        
        return newRequest
    }
    
    open func fetchDataFromUrl(stringUrl : String, completionHandler: @escaping (_ object : AnyObject?) -> ()){
        
        var receiptID = ""
        var currentRequest : Request?
        var validRequest : URLRequest?
        
        //1. Display cached image if available
        if let cachedObject = urlCache.object(forKey: stringUrl as NSString) {
            
            completionHandler(cachedObject as AnyObject?)
            print ("found cachedObject")
            
        } else {
            
            //2. Check if there is already a request for the same Url
            
            let request = retrieveUrlRequest(url: stringUrl)
            
            if request == nil {
                
                //Create a new UrlRequest if unavailable
                currentRequest = createNewUrlRequest(stringUrl: stringUrl)
                
                receiptID = "\(String(arc4random()))"
                currentRequest?.recieptIDs.append(receiptID)
                
                validRequest = currentRequest?.request
                print ("created new request, appended \(receiptID)")
                
                
                //Download and save data to the request
                currentDatatask = defaultSession.dataTask(with: validRequest!, completionHandler: { (data, response, error) in
                    
                    if error != nil {
                        print (error)
                    }
                    
                    currentRequest?.reuseableData = data
                    print ("data saved")
                    
                    print ("datadownloaded, receipts count is \(currentRequest?.recieptIDs.count)")
                    
                })
                
            } else {
                
                //If request for the same Url is already on queue, add to the request with a unique receiptID
                
                currentRequest = request
                receiptID = "1000000\(String(arc4random()))"
                request?.recieptIDs.append(receiptID)
                
                validRequest = request?.request
                print ("found request existed, appended \(receiptID)")
                
            }
            
            //3. Convert data to image/json etc.
            //4. Save to cache
            DispatchQueue.main.async {
                
                if let data = currentRequest?.reuseableData {
                    
                    urlCache.totalCostLimit = 60_000_000
                    
                    if let image = UIImage(data: data) {
                        
                        urlCache.setObject(image, forKey: stringUrl as NSString)
                        
                        //Return completion to all sources requested for the same image
                        for each in (currentRequest?.recieptIDs)! {
                            
                            if each == receiptID {
                                
                                completionHandler(image as AnyObject?)
                                print ("for \(receiptID), image downloaded")
                                
                            } else {
                                
                                completionHandler(nil)
                                print ("for \(receiptID), image not requested")
                                
                            }
                        }
                    }
                    
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                        
                        urlCache.setObject(json as AnyObject, forKey: stringUrl as NSString)
                        
                        for each in (currentRequest?.recieptIDs)! {
                            if each == receiptID {
                                
                                completionHandler(json as AnyObject?)
                                print ("for \(receiptID), json downloaded")
                                
                            } else {
                                
                                completionHandler(nil)
                                print ("for \(receiptID), json not requested")
                                
                            }
                        }
                    }
                }
                
                //5. Remove request from requestsOnQueue when download is completed
                if let i = requestsOnQueue.index(where: { _ in (currentRequest != nil) }) {
                    requestsOnQueue.remove(at: i)
                    
                }
            }
            currentDatatask?.resume()
        }
    }
    
    
    open func cancelRequest(receiptID : String){
        
        for eachRequest in requestsOnQueue{
            for eachID in eachRequest.recieptIDs{
                if eachID == receiptID{
                    if let i = eachRequest.recieptIDs.index(where: { _ in (eachID != nil) }) {
                        eachRequest.recieptIDs.remove(at: i)
                    }
                }
            }
        }
    }
    
}

