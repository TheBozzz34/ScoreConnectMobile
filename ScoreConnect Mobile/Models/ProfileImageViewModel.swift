//
//  ProfileImageViewModel.swift
//  ScoreConnect Mobile
//
//  Created by Ethan James on 12/3/23.
//

import Foundation
import FirebaseAuth

class ProfileImageViewModel: ObservableObject {
    @Published var profileImage: UIImage?

    func fetchImage() {
        if let url = Auth.auth().currentUser?.photoURL {
            fetchImage(from: url) { imageData in
                DispatchQueue.main.async {
                    if let data = imageData {
                        self.profileImage = UIImage(data: data)
                    }
                }
            }
        }
    }

    private func fetchImage(from url: URL, completionHandler: @escaping (_ data: Data?) -> ()) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching the image! 😢 \(error.localizedDescription)")
                completionHandler(nil)
            } else {
                completionHandler(data)
            }
        }
        dataTask.resume()
    }
}
