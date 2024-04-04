//
//  ContentView.swift
//  agoraproto
//
//  Created by Saskriti Neupane  on 7/23/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var isUserAuthenticated: Bool
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
             .toolbar {
                 ToolbarItemGroup(placement: .navigationBarTrailing) {
                     Button("Add Events to Calendar") {
                         addEventsToCalendar()
                     }
                     Button("Sign Out") {
                         signOut()
                     }
                 }
             }
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

    func addEventsToCalendar() {
        //'fetchEventData' is what is fetching events and not calendar events
        APICall.shared.fetchEventData { fetchedEvents, error in
            guard let fetchedEvents = fetchedEvents else {
                self.errorMessage = error?.localizedDescription ?? "Unknown error"
                self.showingAlert = true
                return
            }

            for event in fetchedEvents {
                // Map your fetched event to the CalendarEvent type expected by Google Calendar
                let calendarEvent = CalendarEvent(
                    summary: event.summary,
                    location: event.location,
                    startDateTime: event.startDateTime,
                    endDateTime: event.endDateTime
                )
                
                //calling my 'addEventToGoogleCalendar' to add each event
                APICall.shared.addEventToGoogleCalendar(event: calendarEvent) { success, error in
                    if success {
                        print("Event added successfully")
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = error?.localizedDescription ?? "Failed to add event"
                            self.showingAlert = true
                        }
                    }
                }
            }
        }
    }

    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
            isUserAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
            showingAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isUserAuthenticated: .constant(true))
    }
}
