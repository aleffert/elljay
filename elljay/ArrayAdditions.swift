//
//  Functional.swift
//  elljay
//
//  Created by Akiva Leffert on 10/18/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

func generate<A>(#total : Int, #generator : Int -> A?) -> [A] {
    var result : [A] = []
    for i in 0 ..< total {
        let object = generator(i)
        if let o = object {
            result.append(o)
        }
    }
    return result
}