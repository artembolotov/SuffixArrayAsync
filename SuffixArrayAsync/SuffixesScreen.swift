//
//  SuffixesScreen.swift
//  SuffixArray
//
//  Created by artembolotov on 21.02.2023.
//

import SwiftUI

struct SuffixesScreen: View {
    enum Mode {
        case asc, desc, top
    }
    
    @Binding var suffixData: SuffixData
    @Binding var isPresented: Bool
    
    @State private var mode = Mode.asc
    
    func suffixes(for mode: Mode) -> [String] {
        switch mode {
        case .asc:
            return suffixData.suffixes
        case .desc:
            return suffixData.suffixes.reversed()
        case .top:
            return suffixData.topTriads
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                VStack {
                    HStack(spacing: 10) {
                        Picker("", selection: $mode) {
                            Text("Ascending").tag(Mode.asc)
                            Text("Descending").tag(Mode.desc)
                        }
                        .pickerStyle(.segmented)
                        
                        Picker("", selection: $mode) {
                            Text("Top 10").tag(Mode.top)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: (proxy.size.width - 50) / 3)
                    }
                    .padding(.horizontal)
                    List {
                        let suffixes = suffixes(for: mode)
                        
                        ForEach(suffixes, id: \.self) { suffix in
                            HStack(alignment: .firstTextBaseline) {
                                Text(suffix)
                                Text("- \(suffixData.counts[suffix] ?? 0)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .toolbar {
                Button("Close", action: close)
            }
            .navigationTitle("Suffixes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func close() {
        isPresented = false
    }
}

struct SuffixesScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        SuffixesScreen(suffixData: .constant(SuffixData.createSync(for: "abracadabra")), isPresented: .constant(true))
    }
}
