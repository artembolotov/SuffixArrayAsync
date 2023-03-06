//
//  ContentView.swift
//  SuffixArray
//
//  Created by artembolotov on 20.02.2023.
//

import SwiftUI

struct MainScreen: View {
    @State private var text = "Abracadabra"
    
    @State private var isTextEditPresented = false
    @State private var isResultsPresented = false
    @State private var isPending = false
    @State private var results = SuffixData.createEmpty()
    
    @ObservedObject var historyViewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text(text)
                            .lineLimit(10)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTextEditPresented = true
                    }
                    .disabled(isPending)
                } header: {
                    Text("Enter a text for suffix array")
                }
                
                Section {
                    Button(action: createSuffixArray) {
                        HStack {
                            Text("Create suffix array")
                            Spacer()
                            ProgressView()
                                .opacity(isPending ? 1 : 0)
                        }
                    }
                    .disabled(text.isEmpty || isPending)
                }
                
                if !historyViewModel.history.isEmpty {
                    Section {
                        ForEach(historyViewModel.history) { suffixData in
                            Button(suffixData.text) {
                                results = suffixData
                                isResultsPresented = true
                            }
                            .foregroundColor(.primary)
                            .disabled(isPending)
                        }
                        
                        Button("Clear") {
                            historyViewModel.history.removeAll()
                        }
                        .disabled(isPending)
                    } header: {
                        Text("Search History")
                    }
                }
            }
            .navigationTitle("Suffix array")
            .sheet(isPresented: $isTextEditPresented) {
                EnterTextScreen(text: $text, isPresented: $isTextEditPresented)
            }
            .sheet(isPresented: $isResultsPresented) {
                SuffixesScreen(suffixData: $results, isPresented: $isResultsPresented)
            }
        }
        
    }
    
    private func createSuffixArray() {
        Task { @MainActor in
            isPending = true
            results = await SuffixArrayActor(for: text).result
            historyViewModel.history.insert(results, at: 0)
            isResultsPresented = true
            isPending = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
