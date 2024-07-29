//
//  ProductListView.swift
//  ProductApp
//
//  Created by Preity Singh on 28/07/24.
//

import SwiftUI

struct ProductListView: View {
  @StateObject var viewModel = ProductListViewModel()
  
  
  var body: some View {
    NavigationView {
      VStack {
        TextField("Search products...", text: $viewModel.searchQuery)
          .padding()
          .background(Color(.systemGray6))
          .cornerRadius(8)
          .padding(.horizontal)
          .transition(.move(edge: .top).combined(with: .opacity))
          .animation(.easeInOut(duration: 0.3), value: viewModel.searchQuery)
        
        if viewModel.isLoading {
          ProgressView("Loading...")
            .padding()
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
        }
        
        List(viewModel.products) { product in
           let imageUrl = if product.image.isEmpty {
           "https://vx-erp-product-images.s3.ap-south-1.amazonaws.com/9_1721665932_0_pic.jpg"
           }
           else{
              product.image
           }
          HStack(spacing: 20){
            AsyncImage(url: URL(string: imageUrl)) {
              Image(systemName: "photo")
                .resizable()
            } image: { image in
              Image(uiImage: image)
                .resizable()
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 5)
            .animation(.easeInOut(duration: 0.3), value: product.image)
            
            VStack(alignment: .leading, spacing: 8) {
              Text(product.productName)
                .font(.headline)
                .foregroundColor(.primary)
              Text(product.productType)
                .font(.subheadline)
                .foregroundColor(.secondary)
              Text("Price: ₹\(product.price, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.secondary)
              Text("Tax: \(product.tax, specifier: "%.2f")%")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
          }
          .padding(.vertical, 4)
          .background(Color(.systemBackground))
          .cornerRadius(8)
          .animation(.easeInOut(duration: 0.3), value: product)
        }
        .listStyle(PlainListStyle())
        .transition(.slide)
        .animation(.easeInOut(duration: 0.3), value: viewModel.products)
        
        let uniqueProductTypes = Array(Set(viewModel.products.map { $0.productType }))
        
        NavigationLink(destination: AddProductView(productTypes: uniqueProductTypes)) {
          Text("Add Product")
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding()
        }
      }
      .navigationTitle("Products")
      .onAppear {
        viewModel.fetchProducts()
      }
    }
  }
}

#Preview {
  ProductListView()
}
