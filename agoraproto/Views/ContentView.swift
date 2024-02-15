//
//  ContentView.swift
//  agoraproto
//
//  Created by Saskriti Neupane  on 7/23/23.
//


import SwiftUI



struct ContentView: View {
    @State private var events: [Event] = []
    @State private var showingAlert = false
    @State private var errorMessage = ""


    var body: some View {
        NavigationView {
            List(events, id: \.id) { event in
                Section(header: Text(event.name)) {
                    Text("Description: \(event.descr.plain)")
                    Text("Start Date: \(event.startDate)")
                    Text("End Date: \(event.endDate)")
                }
            }
            .navigationTitle("Course Schedule")
        }
        .onAppear {
            fetchData()
        }

        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func fetchData() {
        Task {
            do {
                let topLevelData = try await performAPICall()

                let eventsData = topLevelData.flatMap { $0.events }
                DispatchQueue.main.async {

                    self.events = eventsData
                }
            } catch {

                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showingAlert = true

                }

            }

        }

    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

    }

}
