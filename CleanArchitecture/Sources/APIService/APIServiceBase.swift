//
//  APIServiceBase.swift
//  MGAPIService
//
//  Created by Tuan Truong on 4/5/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import RxSwift
import RxAlamofire

public typealias JSONDictionary = [String: Any]
public typealias JSONArray = [JSONDictionary]
public typealias ResponseHeader = [AnyHashable: Any]

public protocol JSONData {
    init()
    static func equal(left: JSONData, right: JSONData) -> Bool
}

extension JSONDictionary: JSONData {
    public static func equal(left: JSONData, right: JSONData) -> Bool {
        // swiftlint:disable:next force_cast
        let equal = NSDictionary(dictionary: left as! JSONDictionary).isEqual(to: right as! JSONDictionary)
        return equal
    }
}

extension JSONArray: JSONData {
    public static func equal(left: JSONData, right: JSONData) -> Bool {
        let leftArray = left as! JSONArray  // swiftlint:disable:this force_cast
        let rightArray = right as! JSONArray  // swiftlint:disable:this force_cast
        
        guard leftArray.count == rightArray.count else { return false }
        
//        for i in 0..<leftArray.count {
//            if !JSONDictionary.equal(left: leftArray[i], right: rightArray[i]) {
//                return false
//            }
//        }
        
        return true
    }
}

open class APIBase {
   
    public var manager: Alamofire.Session
    public var logOptions = LogOptions.default
    
    public convenience init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        
        self.init(configuration: configuration)
    }
    
    public init(configuration: URLSessionConfiguration) {
        manager = Alamofire.Session(configuration: configuration)
    }
    
    open func request<T: Mappable>(_ input: APIInputBase) -> Observable<APIResponse<T>> {
        let response: Observable<APIResponse<JSONDictionary>> = requestJSON(input)
        
        return response
            .map { apiResponse -> APIResponse<T> in
                if let t = T(JSON: apiResponse.data) {
                    return APIResponse(header: apiResponse.header, data: t)
                }
                
                throw APIInvalidResponseError()
            }
    }
    
    open func request<T: Mappable>(_ input: APIInputBase) -> Observable<T> {
        return request(input).map { $0.data }
    }
    
    open func request<T: Mappable>(_ input: APIInputBase) -> Observable<APIResponse<[T]>> {
        let response: Observable<APIResponse<JSONArray>> = requestJSON(input)
        
        return response
            .map { apiResponse -> APIResponse<[T]> in
                return APIResponse(header: apiResponse.header,
                                   data: Mapper<T>().mapArray(JSONArray: apiResponse.data))
            }
    }
    
    open func request<T: Mappable>(_ input: APIInputBase) -> Observable<[T]> {
        return request(input).map { $0.data }
    }
    
    open func requestJSON<U: JSONData>(_ input: APIInputBase) -> Observable<APIResponse<U>> {
        let user = input.user
        let password = input.password
        
        let urlRequest = preprocess(input)
            .do(onNext: { [unowned self] input in
                if self.logOptions.contains(.request) {
                    print(input.description(isIncludedParameters: self.logOptions.contains(.requestParameters)))
                }
            })
            .map { [unowned self] input -> DataRequest in
                if let uploadInput = input as? APIUploadInputBase {
                    return self.manager.upload(
                        multipartFormData: { (multipartFormData) in
                            input.parameters?.forEach { key, value in
                                if let data = String(describing: value).data(using: .utf8) {
                                    multipartFormData.append(data, withName: key)
                                }
                            }
                            uploadInput.data.forEach({
                                multipartFormData.append(
                                    $0.data,
                                    withName: $0.name,
                                    fileName: $0.fileName,
                                    mimeType: $0.mimeType)
                            })
                        },
                        to: uploadInput.urlString,
                        method: uploadInput.method,
                        headers: uploadInput.headers
                    )
                } else {
                    return self.manager.request(
                        input.urlString,
                        method: input.method,
                        parameters: input.parameters,
                        encoding: input.encoding,
                        headers: input.headers
                    )
                }
            }
            .do(onNext: { (dataRequest) in
                if self.logOptions.contains(.rawRequest) {
                    debugPrint(dataRequest)
                }
            })
            .flatMapLatest { dataRequest -> Observable<(HTTPURLResponse, Data)> in
                if let user = user, let password = password {
                    return dataRequest
                        .authenticate(username: user, password: password)
                        .rx.responseData()
                }
                
                return dataRequest.rx.responseData()
            }
            .map { (dataResponse) -> APIResponse<U> in
                return try self.process(dataResponse)
            }
            .catchError { [unowned self] error -> Observable<APIResponse<U>> in
                return try self.handleRequestError(error, input: input)
            }
            .do(onNext: { response in
                if input.usingCache {
                    DispatchQueue.global().async {
                        try? CacheManager.sharedInstance.write(urlString: input.urlEncodingString,
                                                               data: response.data,
                                                               header: response.header)
                    }
                }
            })
        
        let cacheRequest = Observable.just(input)
            .filter { $0.usingCache }
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .map { input -> (Any, ResponseHeader?) in
                return try CacheManager.sharedInstance.read(urlString: input.urlEncodingString)
            }
            .catchError { [unowned self] error in
                if self.logOptions.contains(.error) {
                    print(error)
                }
                
                return Observable.empty()
            }
            .filter { $0.0 is U }
            .map { data, header -> APIResponse<U> in
                APIResponse(header: header, data: data as! U) // swiftlint:disable:this force_cast
            }
            .do(onNext: { [unowned self] response in
                if self.logOptions.contains(.cache) {
                    print("[CACHE]")
                    print(response.data)
                }
            })
        
        return input.usingCache
            ? Observable.concat(cacheRequest, urlRequest)
            : urlRequest
    }
    
    open func preprocess(_ input: APIInputBase) -> Observable<APIInputBase> {
        return Observable.just(input)
    }
    
    open func process<U: JSONData>(_ response: (HTTPURLResponse, Data)) throws -> APIResponse<U> {
        let (urlResponse, data) = response
        let json: U? = (try? JSONSerialization.jsonObject(with: data, options: [])) as? U
        
        let error: Error
        let statusCode = urlResponse.statusCode
        
        switch statusCode {
        case 200..<300:
            if logOptions.contains(.responseStatus) {
                print("👍 [\(statusCode)] " + (urlResponse.url?.absoluteString ?? ""))
            }
            
            if logOptions.contains(.urlResponse) {
                print(urlResponse)
            }
            
            if logOptions.contains(.responseData) {
                print("[RESPONSE DATA]")
                print(json ?? data)
            }
            
            // swiftlint:disable:next explicit_init
            return APIResponse(header: urlResponse.allHeaderFields, data: json ?? U.init())
        default:
            error = handleResponseError(response: urlResponse, data: data, json: json)
            
            if logOptions.contains(.responseStatus) {
                print("❌ [\(statusCode)] " + (urlResponse.url?.absoluteString ?? ""))
            }
            
            if logOptions.contains(.urlResponse) {
                print(urlResponse)
            }
            
            if logOptions.contains(.error) || logOptions.contains(.responseData) {
                print("[RESPONSE DATA]")
                print(json ?? data)
            }
        }
        throw error
    }
    
    open func handleRequestError<U: JSONData>(_ error: Error,
                                              input: APIInputBase) throws -> Observable<APIResponse<U>> {
        throw error
    }
    
    open func handleResponseError<U: JSONData>(response: HTTPURLResponse, data: Data, json: U?) -> Error {
        if let jsonDictionary = json as? JSONDictionary {
            return handleResponseError(response: response, data: data, json: jsonDictionary)
        } else if let jsonArray = json as? JSONArray {
            return handleResponseError(response: response, data: data, json: jsonArray)
        }
        
        return handleResponseUnknownError(response: response, data: data)
    }
    
    open func handleResponseError(response: HTTPURLResponse, data: Data, json: JSONDictionary?) -> Error {
        return APIUnknownError(statusCode: response.statusCode)
    }
    
    open func handleResponseError(response: HTTPURLResponse, data: Data, json: JSONArray?) -> Error {
        return APIUnknownError(statusCode: response.statusCode)
    }
    
    open func handleResponseUnknownError(response: HTTPURLResponse, data: Data) -> Error {
        return APIUnknownError(statusCode: response.statusCode)
    }
}
