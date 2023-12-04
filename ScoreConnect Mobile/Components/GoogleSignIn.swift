//
//  GoogleSignIn.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 12/3/23.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import SwiftUI

struct GoogleSignInViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GoogleSignInController {
        return GoogleSignInController()
    }
    
    func updateUIViewController(_ uiViewController: GoogleSignInController, context: Context) {}
}


class GoogleSignInController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupGoogleSignIn()
    }
    
    private func setupGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            // Show an error message or log an error if clientID is nil
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let signInButton = GIDSignInButton()
        signInButton.addTarget(self, action: #selector(signInButtonPressed), for: .touchUpInside)
        
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func signInButtonPressed() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            // Handle the sign-in result or error
            if let error = error {
                // Handle the sign-in error
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            if let user = result?.user,
               let idToken = user.idToken?.tokenString  {
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { _, error in
                    if let error = error {
                        // Handle Firebase authentication error
                        print("Firebase authentication error: \(error.localizedDescription)")
                    } else {
                        // Authentication successful, proceed accordingly
                        // For example: dismiss the view controller or navigate to another screen
                        print("Auth success!")
                    }
                }
            }
        }
    }
}

enum SignInError: Error {
    case clientIDNotFound
}
