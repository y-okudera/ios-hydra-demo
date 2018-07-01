//
//  Error+Helper.swift
//  ios-hydra-demo
//
//  Created by YukiOkudera on 2018/07/01.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation

extension Error {
    
    var isOffline: Bool {
        return (self as NSError).domain == NSURLErrorDomain && (self as NSError).code == NSURLErrorNotConnectedToInternet
    }
    
    var isTimeout: Bool {
        return (self as NSError).domain == NSURLErrorDomain && (self as NSError).code == NSURLErrorTimedOut
    }
}
