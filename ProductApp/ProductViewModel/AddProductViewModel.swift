//
//  AddProductViewModel.swift
//  ProductApp
//
//  Created by Preity Singh on 28/07/24.
//

import Foundation
import Combine
import UIKit

class AddProductViewModel: ObservableObject {
    @Published var productName: String = ""
    @Published var productType: String = ""
    @Published var price: String = ""
    @Published var tax: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var isSubmitting: Bool = false
    @Published var submissionResult: String?
    
    private var cancellables = Set<AnyCancellable>()
  
  func clearFields(){
     productName = ""
     productType = ""
     price = ""
     tax = ""
     selectedImage = nil
  }
    
    func submitProduct() {
        guard validateFields() else {
            submissionResult = "Please fill all fields correctly."
            return
        }
        
        isSubmitting = true
        let url = URL(string: "https://app.getswipe.in/api/public/add")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "product_name": productName,
            "product_type": productType,
            "price": price,
            "tax": tax
        ]
        
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        if let image = selectedImage {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"image.jpg\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            }
        }
        
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SubmitResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isSubmitting = false
                switch completion {
                case .failure(let error):
                    self.submissionResult = "Error submitting product: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.submissionResult = response.message
              self?.clearFields()
            })
            .store(in: &cancellables)
    }
    
    private func validateFields() -> Bool {
        return !productName.isEmpty && !productType.isEmpty && Double(price) != nil && Double(tax) != nil
    }
}

struct SubmitResponse: Codable {
    let message: String
    let success: Bool
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
