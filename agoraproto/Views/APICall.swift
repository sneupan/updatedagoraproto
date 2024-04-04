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
                completion(nil, nil)
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
        guard let accessToken = AuthenticationManager.shared.googleAccessToken else {
            let noAccessTokenError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token is not available"])
            print("APICall - Error: \(noAccessTokenError.localizedDescription)")
            completion(false, noAccessTokenError)
            return
        }
        print("APICall - Using Access Token: \(accessToken)")
        
        let urlString = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
        guard let url = URL(string: urlString) else {
            let badURLError = URLError(.badURL)
            print("APICall - URL Error: \(badURLError.localizedDescription)")
            completion(false, badURLError)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "summary": event.summary,
            "location": event.location,
            "start": ["dateTime": event.startDateTime],
            "end": ["dateTime": event.endDateTime]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                if let error = error {
                    print("APICall - Upload Task Error: \(error.localizedDescription)")
                    completion(false, error)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("APICall - Event added successfully")
                        completion(true, nil)
                    } else {
                        let failedToAddEventError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add event, HTTP Status Code: \(httpResponse.statusCode)"])
                        print("APICall - HTTP Error: \(failedToAddEventError.localizedDescription)")
                        completion(false, failedToAddEventError)
                    }
                } else {
                    let unexpectedResponseError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response from the server"])
                    print("APICall - Unexpected Response Error: \(unexpectedResponseError.localizedDescription)")
                    completion(false, unexpectedResponseError)
                }
            }
            task.resume()
        } catch {
            print("APICall - JSON Serialization Error: \(error.localizedDescription)")
            completion(false, error)
        }
    }
}

    
    
    func performAPICall() async throws -> [TopLevelObject] {
        guard let url = URL(string: "http://localhost:8080/waitlist/waitlistactivityofferings?personId=90000003&termId=kuali.atp.FA2023-2024") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([TopLevelObject].self, from: data)
    }

