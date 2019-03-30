//
//  QuoteService.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 29/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import Alamofire

typealias QuoteCallback = ((Resource<ZQuote>) -> Void)
typealias QuotesCallback = ((Resource<[ZQuote]>) -> Void)

///Class that handle all APIs call related to Quote object
class QuoteService: NSObject {

    func getRandomQuote(completion: @escaping QuotesCallback) {
        let request = QuoteRouter.getRandomQuote
        SessionManager.default.request(request).responseCollection(arrayName: "quotes") { (response: DataResponse<[ZQuote]>) in
            switch response.result {
            case .success(let quotes):
                completion(.found(quotes))
            case .failure(let error):
                completion(.notFound(error as! ZError))
            }

        }
    }
}
