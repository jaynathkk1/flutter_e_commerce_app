import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> _products = [];
  List<Product> _searchResults = [];
  List<Product> _suggestions = [];
  List<Product> _recentSearches = [];

  List<Product> get products => _products;
  List<Product> get searchResults => _searchResults;
  List<Product> get suggestions => _suggestions;
  List<Product> get recentSearches => _recentSearches;

  // Fetch products from Firebase Firestore
  Future<void> fetchProducts() async {
    try {
      final querySnapshot = await _firestore.collection('shop_products').get();
      _products = querySnapshot.docs.map((doc) => Product.fromFirestore(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // Search products in Firestore
  void searchProducts(String query) {
    _searchResults = _products
        .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _recommendProductsBasedOnSearch(query);
    notifyListeners();
  }

  // Fetch product suggestions based on query
  void fetchSuggestions(String query) {
    _suggestions = _products
        .where((product) => product.name.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  // Fetch recommendations based on search interest (i.e., matching category or keywords)
  void _recommendProductsBasedOnSearch(String query) {
    // First, clear previous suggestions
    _suggestions.clear();

    // Search for products that match the query by category or name
    _suggestions = _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Add the most relevant search results based on the search term
    if (_suggestions.isEmpty) {
      // If no direct match is found, recommend products based on categories or keywords
      _suggestions = _products.where((product) {
        // Recommend products that belong to the same category as the query
        return product.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    // Optionally, you can store recent searches to keep track of the user's search behavior.
    _recentSearches.addAll(_searchResults);
  }

  // Fetch recommendations (can be random or specific products)
  void fetchRecommendations() {
    _suggestions = _products.take(5).toList();  // Show first 5 products as recommendations
    notifyListeners();
  }
}
