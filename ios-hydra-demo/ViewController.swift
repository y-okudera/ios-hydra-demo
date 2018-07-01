//
//  ViewController.swift
//  ios-hydra-demo
//
//  Created by YukiOkudera on 2018/07/01.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import UIKit
import LSSLogger

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        requestAPI()
    }

    private func requestAPI() {
        let request = PostcodeRequest(postcode: "1000001")

        request.sendAPIRequest()
            .then(in: .background, { result in

                LSSLogger.console.debug(message: "PostcodeRequest sendAPIRequest(): success")
                LSSLogger.console.debug(message: "data: \(result.data)")
                LSSLogger.console.debug(message: "size: \(result.size)")
                LSSLogger.console.debug(message: "limit: \(result.limit)")
                LSSLogger.console.debug(message: "version: \(result.version)")
            })
            .catch(in: .background, { error in

                LSSLogger.console.debug(message: "PostcodeRequest sendAPIRequest(): failure")
                LSSLogger.console.debug(message: "error: \(error)")

                if let postcodeSearchError = error as? PostcodeSearchError {
                    LSSLogger.console.debug(message: "error message: \(postcodeSearchError.message)")
                }
            })
    }
}

