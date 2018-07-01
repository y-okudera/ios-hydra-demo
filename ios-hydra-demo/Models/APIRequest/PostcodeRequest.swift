//
//  PostcodeRequest.swift
//  ios-hydra-demo
//
//  Created by YukiOkudera on 2018/07/01.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Alamofire
import Hydra
import LSSLogger

struct PostcodeSearchError: Error {

    enum ErrorKind {
        case empty
        case searchfailed
        case unreachable
    }

    let kind: ErrorKind

    var message: String {
        switch kind {
        case .empty:
            return "該当の住所が見つかりませんでした。"
        case .searchfailed:
            return "住所の検索に失敗しました。"
        case .unreachable:
            return "通信環境の良い場所で再度お試しください。";
        }
    }
}

final class PostcodeRequest: Request {
    
    init(postcode: String) {
        self.postcode = postcode
    }
    
    var general = true
    var office = true
    var postcode = ""
    
    typealias ResponseComponent = Postcode
    typealias Response = Postcodes
    typealias ErrorType = PostcodeSearchError
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/api/postcode"
    }
    
    var parameters: [String : Any] {
        return [
            "general": general ? "true" : "false",
            "office": office ? "true" : "false",
            "postcode": postcode
        ]
    }
    
    func sendAPIRequest() -> Promise<Response> {
        
        func determineAPIErrorType(apiError: APIError) -> PostcodeSearchError {
            
            switch apiError {
            case .connectionError(let error):
                
                if error.isOffline {
                    LSSLogger.console.debug(message: "isOffline")
                    return PostcodeSearchError(kind: .unreachable)
                }
                if error.isTimeout {
                    LSSLogger.console.debug(message: "isTimeout")
                    return PostcodeSearchError(kind: .unreachable)
                }
                return PostcodeSearchError(kind: .searchfailed)
                
            case .invalidResponse:
                return PostcodeSearchError(kind: .searchfailed)
                
            case .parseError(let responseData):
                
                LSSLogger.console.debug(message: "responseData: \(String(data: responseData, encoding: .utf8) ?? "")")
                return PostcodeSearchError(kind: .searchfailed)
            }
        }
        
        return Promise<Response>(in: .background, { resolve, reject, _ in
            
            APIClient.request(request: self)
                .then(in: .background, { result in
                    
                    LSSLogger.console.debug(message: "APIClient.request: success")
                    
                    if result.size == 0 {
                        reject(PostcodeSearchError(kind: .empty))
                        return
                    }
                    resolve(result)
                })
                .catch(in: .background, { error in
                    
                    LSSLogger.console.debug(message: "APIClient.request: failure")
                    LSSLogger.console.debug(message: "error: \(error)")
                    
                    guard let apiError = error as? APIError else {
                        reject(PostcodeSearchError(kind: .searchfailed))
                        return
                    }
                    reject(determineAPIErrorType(apiError: apiError))
                })
                .always {
                    LSSLogger.console.debug(message: "done")
            }
        })
    }
}
