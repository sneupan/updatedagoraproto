//
//  AuthenticationViewModel.swift
//  agoraproto
//
//  Created by Saskriti Neupane  on 8/1/23.
//

import Foundation


@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    func signInGoogle() async -> Bool {
        let helper = SignInGoogleHelper()
        do {
            let tokens = try await helper.signIn()
            let _ = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
            return true  // Sign-in was successful
        } catch {
            print(error)
            return false  // Sign-in failed
        }
    }
}
