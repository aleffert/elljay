//
//  SequenceExtensions.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

class GeneratorWrapper<G : Generator> : Sequence {
    typealias GeneratorType = G
    
    let generator : G
    
    init(generator : G) {
        self.generator = generator;
    }
    func generate() -> GeneratorType {
        return self.generator
    }
}

func reduce1<S : Sequence>(sequence : S, combine: (S.GeneratorType.Element, S.GeneratorType.Element) -> S.GeneratorType.Element) -> S.GeneratorType.Element? {
    var generator = sequence.generate()
    if let head = generator.next() {
        return reduce(GeneratorWrapper(generator : generator), head, combine)
    }
    else {
        return nil
    }
}


func sortedMap<K : Comparable, V, Result> (dictionary : [K : V], combine : (K, V) -> Result) -> [Result] {
    return sorted(dictionary.keys).map {key in
        let value = dictionary[key]!
        return combine(key, value)
    }
}