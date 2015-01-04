//
//  SequenceAdditions.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

/// Convert any generator into a sequence
private class GeneratorWrapper<G : GeneratorType> : SequenceType {
    typealias GeneratorType = G
    
    let generator : G
    
    init(generator : G) {
        self.generator = generator;
    }
    func generate() -> GeneratorType {
        return self.generator
    }
}

public func reduce1<S : SequenceType>(sequence : S, combine: (S.Generator.Element, S.Generator.Element) -> S.Generator.Element) -> S.Generator.Element? {
    var generator = sequence.generate()
    if let head = generator.next() {
        return reduce(GeneratorWrapper(generator : generator), head, combine)
    }
    else {
        return nil
    }
}

public func sortedMap<K : Comparable, V, Result> (dictionary : [K : V], combine : (K, V) -> Result) -> [Result] {
    return sorted(dictionary.keys).map {key in
        let value = dictionary[key]!
        return combine(key, value)
    }
}

extension Array {
    func mapOrFail<A> (f: T -> A?) -> [A]? {
        return reduce([]) {(acc : [A]?, cur) in
            if let a = acc {
                if let r = f(cur) {
                    var ma = a
                    ma.append(r)
                    return ma
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }
}

extension Optional {
    func bind<U> (f : T -> U?) -> U? {
        if let y = self {
            return f(y)
        }
        else {
            return nil
        }
    }
}

extension Dictionary {
    static func fromArray(a : [(Key, Value)]) -> Dictionary<Key, Value> {
        var r = Dictionary()
        a.map {(k, v) in
            r[k] = v
        }
        return r
    }
}

extension Array {
    func concatMap<U>(f : T -> [U]) -> [U] {
        var result : [U] = []
        for i in self {
            result.extend(f(i))
        }
        return result
    }
}