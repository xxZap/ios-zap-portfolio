//
//  ServiceResult.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 29/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

enum ServiceCode: String {
    case ok = "OK"
    case unknown = "UNKNOWN"
}

protocol ServiceError: Argo.Decodable {

}

/// A class that conforms service error to be used in service result when no service error is needed. It's a fake class to make a concrete ServiceResult (or ServiceResultCollection) without errors.
class BlankServiceError: ServiceError {

    static func decode(_ json: JSON) -> Decoded<BlankServiceError> {
        return .success(BlankServiceError())
    }
}

/// A class used if a service result does not have a Response field
class BlankServiceResult: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<BlankServiceResult> {
        return .success(BlankServiceResult())
    }
}

class ServiceResult<T: Argo.Decodable, E: ServiceError> where T == T.DecodedType, E == E.DecodedType {
    let success: Bool
    let description: String
    let response: T?
    var errors: E?

    init(success: Bool, description: String, response: T?, errors: E?) {
        self.success = success
        self.description = description
        self.response = response
        self.errors = errors
    }
}

extension ServiceResult: Argo.Decodable {
    static func decode(_ j: JSON) -> Decoded<ServiceResult> {
        let a = curry(ServiceResult.init)
            <^> j <| "success"
            <*> j <| "message"
        return a
            <*> j <|? "response"
            <*> j <|? "errors"
    }
}




class ServiceResultCollection<T: Argo.Decodable, E: ServiceError> where T == T.DecodedType, E == E.DecodedType {
    let success: Bool
    let description: String
    let response: [T]?
    let errors: E?

    init(success: Bool, description: String, response: [T]?, errors: E?) {
        self.success = success
        self.description = description
        self.response = response
        self.errors = errors
    }
}

extension ServiceResultCollection: Argo.Decodable {
    static func decode(_ j: JSON) -> Decoded<ServiceResultCollection> {
        let a = curry(ServiceResultCollection.init)
            <^> j <| "success"
            <*> j <| "message"
        return a
            <*> j <||? "response"
            <*> j <|? "errors"
    }
}
