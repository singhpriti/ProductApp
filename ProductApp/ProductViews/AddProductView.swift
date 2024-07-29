//
//  AddProductView.swift
//  ProductApp
//
//  Created by Preity Singh on 28/07/24.
//

import SwiftUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    var productTypes: [String]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("**Product Details**")
                        .font(.title)
                        .padding(.top, 20)
                    
                    Section {
                        CustomPicker(selection: $viewModel.productType, options: productTypes, placeholder: "Select Product Type")
                        
                        CustomTextField(placeholder: "Product Name", text: $viewModel.productName)
                        CustomTextField(placeholder: "Price", text: $viewModel.price, keyboardType: .decimalPad)
                        CustomTextField(placeholder: "Tax", text: $viewModel.tax, keyboardType: .decimalPad)
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Select Image")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                        
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                                .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                    
                    Section {
                        Button(action: {
                            viewModel.submitProduct()
                        }) {
                            Text("Submit")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.isSubmitting)
                        
                        if viewModel.isSubmitting {
                            ProgressView()
                                .padding(.top)
                        }
                        
                        if let result = viewModel.submissionResult {
                            Text(result)
                                .foregroundColor(result.contains("Error") ? .red : .green)
                                .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                }
               // .navigationTitle("Add Product")
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: $inputImage)
                }
                .onChange(of: inputImage) { _ in loadImage() }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        viewModel.selectedImage = inputImage
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .keyboardType(keyboardType)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

struct CustomPicker: View {
    @Binding var selection: String
    var options: [String]
    var placeholder: String
    
    var body: some View {
        HStack {
            Text(selection.isEmpty ? placeholder : selection)
                .foregroundColor(selection.isEmpty ? .gray : .primary)
                .padding()
            Spacer()
            Image(systemName: "chevron.down")
                .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
        .onTapGesture {
            // Present picker options in an action sheet
            showPicker()
        }
    }
    
    private func showPicker() {
        let alertController = UIAlertController(title: placeholder, message: nil, preferredStyle: .actionSheet)
        
        for option in options {
            let action = UIAlertAction(title: option, style: .default) { _ in
                selection = option
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView(productTypes: ["Type1", "Type2", "Type3"])
    }
}

