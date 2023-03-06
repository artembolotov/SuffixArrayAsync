//
//  SuffixArray.swift
//  SuffixArray
//
//  Created by artembolotov on 22.02.2023.
//

import Foundation

struct SuffixArray: Sequence {
    let string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    func makeIterator() -> SuffixIterator {
        return SuffixIterator(string)
    }
}

struct SuffixIterator: IteratorProtocol {
    var current: String.SubSequence?
    init(_ string: String) {
        self.current = string.lowercased().suffix(from: string.startIndex)
    }

    mutating func next() -> String.SubSequence? {
        guard let thisCurrent = current,
                thisCurrent.count > 0 else { return nil }
        let index = thisCurrent.index(thisCurrent.startIndex, offsetBy: 1)
        current = thisCurrent.suffix(from: index)
        return thisCurrent
    }
}

struct SuffixData: Codable, Identifiable {
    var id = UUID().uuidString
    
    let text: String
    let suffixes: [String]
    let counts: [String: Int]
    let topTriads: [String]
    let searchTimes: [String: TimeInterval]
}

actor SuffixArrayActor {
    let result: SuffixData
    
    init(for text: String) async {
        
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let words = text.components(separatedBy: separators).filter { !$0.isEmpty }
        
        let suffixArray = await withTaskGroup(of: SuffixArray.self, body: { group -> [Substring] in
            words.forEach { word in
                group.addTask {
                    SuffixArray(word)
                }
            }
            
            return await group.reduce(into: [], { partialResult, suffixArray in
                partialResult += suffixArray
            })
        })
        
        var counts = [String: Int]()
        
        suffixArray.forEach { suffix in
            let strSuffix = String(suffix)
            let count = counts[strSuffix] ?? 0
            counts[strSuffix] = count + 1
        }
        
        result = SuffixData(
            text: text,
            suffixes: counts.keys.sorted(),
            counts: counts,
            topTriads: counts.filter { $0.key.count == 3 }.sorted { $0.value > $1.value }.prefix(10).map { String($0.key) },
            searchTimes: [:]
        )
    }
    
    private static func suffixArray(for text: String) -> [Substring] {
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let words = text.components(separatedBy: separators).filter { !$0.isEmpty }
        
        return words.reduce(into: []) { partialResult, word in
            partialResult += SuffixArray(word)
        }
    }
}


extension SuffixData {
    
    static func createEmpty() -> SuffixData {
        SuffixData(
            text: "",
            suffixes: [],
            counts: [:],
            topTriads: [],
            searchTimes: [:]
        )
    }
    
    static func createSync(for text: String) -> SuffixData {
        
        let suffixArray = suffixArray(for: text)
        
        var counts = [String: Int]()
        
        suffixArray.forEach { suffix in
            let strSuffix = String(suffix)
            let count = counts[strSuffix] ?? 0
            counts[strSuffix] = count + 1
        }
        
        return SuffixData(
            text: text,
            suffixes: counts.keys.sorted(),
            counts: counts,
            topTriads: counts.filter { $0.key.count == 3 }.sorted { $0.value > $1.value }.prefix(10).map { String($0.key) },
            searchTimes: [:]
        )
        
        func suffixArray(for text: String) -> [Substring] {
            let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = text.components(separatedBy: separators).filter { !$0.isEmpty }
            
            return words.reduce(into: []) { partialResult, word in
                partialResult += SuffixArray(word)
            }
        }
    }
}
