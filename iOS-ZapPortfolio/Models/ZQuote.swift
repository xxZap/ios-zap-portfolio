//
//  ZQuote.swift
//  ZapAnimatableCell
//
//  Created by Alessio Boerio on 29/03/2019.
//  Copyright © 2019 Alessio Boerio. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

//{
//    "tags":
//    [
//        "science",
//        "analogy",
//        "ai"
//    ],
//    "quote": "bla bla bla bla bla bla bla bla",
//    "lang": "en",
//    "author": "Stuart Russell, Peter Norvig"
//}

class ZQuote: NSObject, Argo.Decodable {

    let tags: [String]
    let quote: String?
    let lang: String?
    let author: String?

    init(tags: [String], quote: String?, lang: String?, author: String?) {
        self.tags = tags
        self.quote = quote
        self.lang = lang
        self.author = author
    }

    static func decode(_ j: JSON) -> Decoded<ZQuote> {
        let a = curry(ZQuote.init)
            <^> j <|| "tags"
            <*> j <|? "quote"
            <*> j <|? "lang"
            <*> j <|? "author"

        return a
    }
}
