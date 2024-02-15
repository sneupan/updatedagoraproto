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
