//
//  ProductListViewModel.swift
//  ProductApp
//
//  Created by Preity Singh on 28/07/24.
//

import Foundation
import Combine

class ProductListViewModel: ObservableObject {
   @Published var products: [Product] = []
   @Published var searchQuery: String = ""
   @Published var isLoading: Bool = false
   
   private var cancellables = Set<AnyCancellable>()
   
   init() {
      fetchProducts()
      setupSearch()
   }
   
   func fetchProducts() {
      isLoading = true
      let url = URL(string: "https://app.getswipe.in/api/public/get")!
      
      URLSession.shared.dataTaskPublisher(for: url)
         .map { $0.data }
         .decode(type: [Product].self, decoder: JSONDecoder())
         .receive(on: DispatchQueue.main)
         .sink(receiveCompletion: { completion in
            self.isLoading = false
            switch completion {
            case .failure(let error):
               print("Error fetching products: \(error)")
            case .finished:
               break
            }
         }, receiveValue: { products in
            self.products = products
         })
         .store(in: &cancellables)
   }
   
   private func setupSearch() {
      $searchQuery
         .debounce(for: 0.3, scheduler: DispatchQueue.main)
         .sink { [weak self] query in
            self?.filterProducts(query: query)
         }
         .store(in: &cancellables)
   }
   
   private func filterProducts(query: String) {
      if query.isEmpty{
         fetchProducts()
      }
      else{
         products = products.filter {
            $0.productName.lowercased().contains(query.lowercased())
            
         }
      }
      
   }
}

