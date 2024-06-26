//
//  SignInGoogleHelper.swift
//  agoraproto
//
//  Created by Saskriti Neupane  on 8/1/23.
//


import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}


final class SignInGoogleHelper {
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString

        print("Access Token: \(accessToken)")

        return GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
    }
}

