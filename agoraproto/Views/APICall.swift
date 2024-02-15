//
//  APICall.swift
//  agoraproto
//
//  Created by Saskriti Neupane  on 2/1/24.
//

import Foundation

struct TopLevelObject: Codable {
    let activityOffering: ActivityOffering
    let term: Term
    let scheduleNames: [String]
    let activitySeatCount: ActivitySeatCount
    let events: [Event]
}

struct ActivityOffering: Codable {
    let name: String
    let instructors: [Instructor]
}

struct Instructor: Codable {
    let personName: String
}

struct Term: Codable {
    let name: String
}

struct ActivitySeatCount: Codable {
    let total: Int
    let used: Int
    let available: Int
}

struct Event: Codable {
    let name: String
    let descr: Description
    let id: String
    let startDate: String
    let endDate: String
    let locationDescription: String
    let roomId: String
}

struct Description: Codable {
    let plain: String
    let formatted: String
}

struct CalendarEvent {
    let summary: String
    let location: String
    let startDateTime: String
    let endDateTime: String
}

class APICall {
    static let shared = APICall()

    func fetchEventData(completion: @escaping ([CalendarEvent]?, Error?) -> Void) {
        guard let url = URL(string: "http://localhost:8080/waitlist/waitlistactivityofferings?personId=90000003&termId=kuali.atp.FA2023-2024") else {
            completion(nil, URLError(.badURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, nil) // Handle no data returned
                return
            }

            do {
                let topLevelObjects = try JSONDecoder().decode([TopLevelObject].self, from: data)
                let events = topLevelObjects.flatMap { topLevelObject in
                    topLevelObject.events.map { event in
                        CalendarEvent(
                            summary: event.name,
                            location: event.locationDescription,
                            startDateTime: event.startDate,
                            endDateTime: event.endDate
                        )
                    }
                }
                completion(events, nil)
            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }

        func addEventToGoogleCalendar(event: CalendarEvent, completion: @escaping (Bool, Error?) -> Void) {
               guard let accessToken = AuthenticationManager.shared.accessToken else {
                   completion(false, nil) // No access token available
                   return
               }

               let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events")!
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")

               let eventData: [String: Any] = [
                   "summary": event.summary,
                   "location": event.location,
                   "start": ["dateTime": event.startDateTime],
                   "end": ["dateTime": event.endDateTime]
               ]

               do {
                   let jsonData = try JSONSerialization.data(withJSONObject: eventData, options: [])
                   request.httpBody = jsonData
               } catch {
                   completion(false, error)
                   return
               }

               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   if let error = error {
                       completion(false, error)
                       return
                   }

                   guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                       completion(false, nil) // Handle non-200 responses
                       return
                   }

                   completion(true, nil)
               }

               task.resume()
           }
       }
