//
//  ContentView.swift
//  agoraproto
//
//  Created by Saskriti Neupane  on 7/23/23.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        Button("Add Events to Calendar") {
            APICall.shared.fetchEventData { events, error in
                guard let events = events else {
                    print("Failed to fetch events: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                for event in events {
                    APICall.shared.addEventToGoogleCalendar(event: event) { success, error in
                        if success {
                            print("Event added successfully")
                        } else {
                            print("Failed to add event: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
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
