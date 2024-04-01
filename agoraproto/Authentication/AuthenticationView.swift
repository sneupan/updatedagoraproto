//
//  AuthenticationView.swift
//  agoraproto
//
//  Created by Saskriti Neupane  on 8/1/23.
//


import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var isUserAuthenticated: Bool

    var body: some View {
        VStack {
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    let success = await viewModel.signInGoogle()
                    isUserAuthenticated = success
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Sign-In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(isUserAuthenticated: .constant(false))
        }
    }
}
