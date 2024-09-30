//
//  RxAlamofire+Multipart.swift
//  MGAPIService
//
//  Created by Tuan Truong on 4/5/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import Alamofire
import RxSwift

extension Reactive where Base: Session {
//    func upload(to url: URLConvertible,
//                method: HTTPMethod = .post,
//                headers: HTTPHeaders = [:],
//                data: @escaping (MultipartFormData) -> Void) -> Observable<UploadRequest> {
//        return Observable.create { observer in
//            self.base.upload(multipartFormData: data,
//                             to: url,
//                             method: method,
//                             headers: headers,
//                             encodingCompletion: { result in
//                                switch result {
//                                case .failure(let error):
//                                    observer.onError(error)
//                                case .success(let request, _, _):
//                                    observer.onNext(request)
//                                    observer.onCompleted()
//                                }
//            })
//            
//            return Disposables.create()
//        }
//    }
}
