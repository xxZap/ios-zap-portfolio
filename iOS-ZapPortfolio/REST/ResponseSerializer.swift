//
//  ResponseSerializer.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 29/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import Alamofire
import Argo


enum ZErrorCode: Int {
    case unknown

    // connection error
    case noInternetConnection    = 9999

    // server errors

    case badRequest              = 400
    case unauthorized            = 401
    case forbidden               = 403
    case notFound                = 404
    case serverError             = 500
    case serverDown              = 503

    // app errors

    case jsonSerialization       = -6006
    case emptyArray              = -2222

    static func create(withCode code: Int?) -> ZErrorCode {
        return code == nil ? .unknown : (ZErrorCode(rawValue: code!) ?? .unknown)
    }
}

struct ZError: Error {
    let code: ZErrorCode
    let description: String

    init(_ code: ZErrorCode, description aDescription: String) {
        self.code = code
        self.description = aDescription
    }

    init(_ error: NSError) {
        code = ZErrorCode.create(withCode: error.code)
        description = error.description
    }

    init(_ serviceCode: ServiceCode, description aDescription: String) {

        self.description = aDescription
        switch serviceCode {
        default:
            code = .unknown
        }
    }

}

enum Resource<T> {
    case found(T)
    case notFound(ZError)
}

enum ResourceWithError<T, E: ServiceError> {
    case success(T?)
    case clientError (E?)
    case error(ZError)
}

enum Result {
    case success
    case failure(ZError)
}

extension DataRequest {

    @discardableResult func responseObject<T: Argo.Decodable>(keyName: String? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self where T == T.DecodedType {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil, let response = response else {
                let errDesc = error?.localizedDescription ?? "unknown"
                return .failure(ZError(ZErrorCode.unknown, description: errDesc))
            }

            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            //Response contains a valid JSON
            case .success(let value):
                let value = value as AnyObject

                print("\(value)")
                //Status code 2XX: expecting a resource object
                if case 200 ... 299 = response.statusCode {
                    //Process headers
                    //Check if JSON contains a valid resource object
                    let obj: Decoded<T>
                    if keyName != nil, let subValue = value[keyName!], subValue != nil {
                        obj = decode(subValue!)
                    } else {
                        obj = decode(value)
                    }

                    switch (obj) {
                    //Object successfully decoded from JSON
                    case let .success(value):
                        return .success(value)
                    //JSON format unexpected
                    case .failure(let err):
                        return .failure(ZError(.jsonSerialization, description: "JSON format unexpected: \(err.description)"))
                    }
                }
                    //Status code 401: invalid user session
                else if case 401 = response.statusCode {
                    //self.endSession()
                    return .failure(ZError(.unauthorized, description: "401: unauthorized"))
                }
                    //Status code 4XX/5XX: expecting an error object
                else {
                    print("status code \(response.statusCode)")
                    if case 500 ... 599 = response.statusCode {
                        if let vc = UIApplication.z_topViewController() {
                            UIAlertController.z_showOkAlertController(in: vc, withTitle: "Errore", andMessage: "Servizio temporaneamente offline, riprova tra un po'.")
                        }
                    }
                    return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Error code: \(response.statusCode)"))
                }

            //Response does not contain a valid JSON
            case .failure(let error):
                return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Desc: \(error.localizedDescription)"))

            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }


    @discardableResult func responseCollection<T: Argo.Decodable>(arrayName: String = "objects", completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self where T == T.DecodedType {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil, let response = response else {
                let errDesc = error?.localizedDescription ?? "unknown"
                return .failure(ZError(ZErrorCode.unknown, description: errDesc))
            }

            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            //Response contains a valid JSON
            case .success(let value):
                let value = value as AnyObject

                print("\(value)")
                //Status code 2XX: expecting a resource object
                if case 200 ... 299 = response.statusCode {
                    //Process headers
                    //Check if JSON contains a valid resource object
                    if let params = value[arrayName], params != nil {
                        let obj: Decoded<[T]> = decode(params!)
                        switch (obj) {
                        //Object successfully decoded from JSON
                        case let .success(value):
                            return .success(value)
                        //JSON format unexpected
                        case .failure(let err):
                            return .failure(ZError(.jsonSerialization, description: "JSON format unexpected: \(err.description)"))
                        }
                    }
                    print("no objects array found")
                    return .failure(ZError(.jsonSerialization, description: "No objects array found"))
                }
                    //Status code 401: invalid user session
                else if case 401 = response.statusCode {
                    //self.endSession()
                    return .failure(ZError(.unauthorized, description: "401: unauthorized"))
                }
                    //Status code 4XX/5XX: expecting an error object
                else {
                    print("status code \(response.statusCode)")
                    if case 500 ... 599 = response.statusCode {
                        if let vc = UIApplication.z_topViewController() {
                            UIAlertController.z_showOkAlertController(in: vc, withTitle: "Errore", andMessage: "Servizio temporaneamente offline, riprova tra un po'.")
                        }
                    }
                    return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Error code: \(response.statusCode)"))
                }
            //Response does not contain a valid JSON
            case .failure(let error):
                return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Desc: \(error.localizedDescription)"))

            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    @discardableResult func responseArray<T: Argo.Decodable>(completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self where T == T.DecodedType {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil, let response = response else {
                let errDesc = error?.localizedDescription ?? "unknown"
                return .failure(ZError(ZErrorCode.unknown, description: errDesc))
            }

            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            //Response contains a valid JSON
            case .success(let value):

                print("\(value)")
                //Status code 2XX: expecting a resource object
                if case 200 ... 299 = response.statusCode {
                    //Process headers
                    //Check if JSON contains a valid resource object
                    let obj: Decoded<[T]> = decode(value)
                    switch (obj) {
                    //Object successfully decoded from JSON
                    case let .success(value):
                        return .success(value)
                    //JSON format unexpected
                    case .failure(let err):
                        return .failure(ZError(.jsonSerialization, description: "JSON format unexpected: \(err.description)"))
                    }
                }
                    //Status code 401: invalid user session
                else if case 401 = response.statusCode {
                    //self.endSession()
                    return .failure(ZError(.unauthorized, description: "401: unauthorized"))
                }
                    //Status code 4XX/5XX: expecting an error object
                else {
                    print("status code \(response.statusCode)")
                    if case 500 ... 599 = response.statusCode {
                        if let vc = UIApplication.z_topViewController() {
                            UIAlertController.z_showOkAlertController(in: vc, withTitle: "Errore", andMessage: "Servizio temporaneamente offline, riprova tra un po'.")
                        }
                    }
                    return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Error code: \(response.statusCode)"))
                }
            //Response does not contain a valid JSON
            case .failure(let error):
                return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Desc: \(error.localizedDescription)"))

            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    @discardableResult func responseServiceObject<T: Argo.Decodable, E: ServiceError>(completionHandler: @escaping (DataResponse<ServiceResult<T, E>>) -> Void) -> Self where T == T.DecodedType, E == E.DecodedType {
        let responseSerializer = DataResponseSerializer<ServiceResult<T, E>> { request, response, data, error in
            guard error == nil, let response = response else {
                let errDesc = error?.localizedDescription ?? "unknown"
                return .failure(ZError(ZErrorCode.unknown, description: errDesc))
            }

            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            //Response contains a valid JSON
            case .success(let value):
                let value = value as AnyObject

                print("\(value)")

                //Status code 2XX: expecting a resource object
                if case 200 ... 299 = response.statusCode {
                    let decoded: Decoded<ServiceResult<T, E>> = decode(value)
                    switch decoded {
                    case .success(let serviceResult):
                        return .success(serviceResult)

                    case .failure(let err):
                        return .failure(ZError(.jsonSerialization, description: "JSON format unexpected: \(err.description)"))

                    }
                }
                    //Status code 401: invalid user session
                else if case 401 = response.statusCode {
                    //self.endSession()
                    return .failure(ZError(.unauthorized, description: "401: unauthorized"))
                }
                    //Status code 4XX/5XX: expecting an error object
                else {
                    print("status code \(response.statusCode)")
                    if case 500 ... 599 = response.statusCode {
                        if let vc = UIApplication.z_topViewController() {
                            UIAlertController.z_showOkAlertController(in: vc, withTitle: "Errore", andMessage: "Servizio temporaneamente offline, riprova tra un po'.")
                        }
                    }
                    return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Error code: \(response.statusCode)"))
                }
            //Response does not contain a valid JSON
            case .failure(let error):
                return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Desc: \(error.localizedDescription)"))

            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    @discardableResult func responseServiceCollection<T: Argo.Decodable, E: ServiceError>(completionHandler: @escaping (DataResponse<ServiceResultCollection<T, E>>) -> Void) -> Self where T == T.DecodedType, E == E.DecodedType {
        let responseSerializer = DataResponseSerializer<ServiceResultCollection<T, E>> { request, response, data, error in
            guard error == nil, let response = response else {
                let errDesc = error?.localizedDescription ?? "unknown"
                return .failure(ZError(ZErrorCode.unknown, description: errDesc))
            }

            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            //Response contains a valid JSON
            case .success(let value):
                let value = value as AnyObject

                print("\(value)")
                //Status code 2XX: expecting a resource object
                if case 200 ... 299 = response.statusCode {
                    let decoded: Decoded<ServiceResultCollection<T, E>> = decode(value)
                    switch decoded {
                    case .success(let serviceResult):
                        return .success(serviceResult)

                    case .failure(let err):
                        return .failure(ZError(.jsonSerialization, description: "JSON format unexpected: \(err.description)"))

                    }
                }
                    //Status code 401: invalid user session
                else if case 401 = response.statusCode {
                    //self.endSession()
                    return .failure(ZError(.unauthorized, description: "401: unauthorized"))
                }
                    //Status code 4XX/5XX: expecting an error object
                else {
                    print("status code \(response.statusCode)")
                    if case 500 ... 599 = response.statusCode {
                        if let vc = UIApplication.z_topViewController() {
                            UIAlertController.z_showOkAlertController(in: vc, withTitle: "Errore", andMessage: "Servizio temporaneamente offline, riprova tra un po'.")
                        }
                    }
                    return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Error code: \(response.statusCode)"))
                }
            //Response does not contain a valid JSON
            case .failure(let error):
                return .failure(ZError(ZErrorCode(rawValue: response.statusCode) ?? .unknown, description: "Desc: \(error.localizedDescription)"))

            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

