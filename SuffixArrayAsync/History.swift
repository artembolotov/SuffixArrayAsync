//
//  History.swift
//  SuffixArrayAsync
//
//  Created by artembolotov on 04.03.2023.
//

import Foundation
import SwiftUI

final class HistoryViewModel: ObservableObject {
    @AppStorage("history") var history = [SuffixData]()
}

extension [SuffixData]: RawRepresentable {
    public init?(rawValue: String) {
            guard let data = rawValue.data(using: .utf8),
                let result = try? JSONDecoder().decode([SuffixData].self, from: data)
            else {
                return nil
            }
            self = result
        }

    public var rawValue: String {
        
        guard let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
