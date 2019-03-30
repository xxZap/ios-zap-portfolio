//
//  QuoteRouter.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 29/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import Alamofire

enum QuoteRouter: URLRequestConvertible {
    case getRandomQuote

    var method: HTTPMethod {
        switch self {
        case .getRandomQuote:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getRandomQuote:
            return "quotes"
        }
    }

    var baseUrl: URL {
        switch self {
        case .getRandomQuote:
            return URL(string: "https://opinionated-quotes-api.gigalixirapp.com/v1/")!
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = baseUrl
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
        case .getRandomQuote:
            urlRequest = try JSONEncoding.prettyPrinted.encode(urlRequest, with: nil)

        default:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        }

        return urlRequest
    }
}
