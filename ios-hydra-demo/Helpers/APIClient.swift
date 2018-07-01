//
//  APIClient.swift
//  ios-hydra-demo
//
//  Created by YukiOkudera on 2018/07/01.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Alamofire
import Hydra
import LSSLogger

enum APIError: Error {
    case connectionError(Error)
    case invalidResponse
    case parseError(Data)
}

struct APIClient {

    static func request<T: Request>(request: T) -> Promise<T.Response> {

        let endPoint = request.baseURL.absoluteString + request.path
        let method = request.method
        let parameters = request.parameters
        let headers = request.httpHeaderFields

        return Promise<T.Response>(in: .background, { resolve, reject, _ in
            
            let apiRequest = Alamofire.request(endPoint,
                                               method: method,
                                               parameters: parameters,
                                               encoding: URLEncoding.default,
                                               headers: headers)
                .validate(statusCode: 200 ..< 300)
                .responseData(completionHandler: { response in

                    if let error = response.result.error {
                        reject(APIError.connectionError(error))
                        return
                    }

                    guard
                        let responseData = response.result.value,
                        let urlResponse = response.response else {
                            reject(APIError.invalidResponse)
                            return
                    }

                    guard let model = request.responseFromData(data: responseData, urlResponse: urlResponse) else {
                        reject(APIError.parseError(responseData))
                        return
                    }

                    resolve(model)
                })
            LSSLogger.console.debug(message: "\(apiRequest)")
            LSSLogger.console.debug(message: apiRequest.debugDescription)
        })
    }
}
