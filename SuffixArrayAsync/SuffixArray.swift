//
//  SuffixArray.swift
//  SuffixArray
//
//  Created by artembolotov on 22.02.2023.
//

import Foundation

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
        
        let suffixArray = await withTaskGroup(of: [SuffixElement].self, body: { group -> [SuffixElement] in
            words.forEach { word in
                group.addTask {
                    await word.createSuffixArray()
                }
            }
            
            return await group.reduce(into: [], { partialResult, suffixArray in
                partialResult += suffixArray
            })
        })
        
        var counts = [String: Int]()
        var searchTimes = [String: TimeInterval]()
        
        suffixArray.forEach { suffix in
            let strSuffix = suffix.suffix
            counts[strSuffix, default: 0] += 1
            
            let searchTime = searchTimes[strSuffix, default: Double.greatestFiniteMagnitude]
            searchTimes[strSuffix] =  min(searchTime, suffix.searchTime)
        }
        
        result = SuffixData(
            text: text,
            suffixes: counts.keys.sorted(),
            counts: counts,
            topTriads: counts.filter { $0.key.count == 3 }.sorted { $0.value > $1.value }.prefix(10).map { String($0.key) },
            searchTimes: searchTimes
        )
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
}

struct SuffixElement {
    let suffix: String
    let searchTime: TimeInterval
}

extension String {
    func createSuffixArray() async -> [SuffixElement] {
        let start = Date()
        
        let result = await withTaskGroup(of: SuffixElement.self) { group -> [SuffixElement] in
            for i in (1...count) {
                group.addTask {
                    let suffix = String(self.suffix(i))
                    let searchTime = Date().timeIntervalSince(start)
                    
                    return SuffixElement(suffix: suffix, searchTime: searchTime)
                }
            }
            
            return await group.reduce(into: [], { partialResult, suffixElement in
                partialResult.append(suffixElement)
            })
        }
        return result
    }
}
