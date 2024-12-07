import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class ProductSearchPage extends StatefulWidget {
  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch products and recommendations from Firestore
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
      context.read<ProductProvider>().fetchRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
        actions: [
          Icon(Icons.search),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search Products...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                provider.fetchSuggestions(query);
                provider.searchProducts(query);
              },
            ),
          ),
          if (_controller.text.isEmpty)
          // Show recommendations when the search bar is empty
            Expanded(
              child: ListView.builder(
                itemCount: provider.suggestions.length,
                itemBuilder: (context, index) {
                  final product = provider.suggestions[index];
                  return ListTile(
                    leading: Image.network(product.image),
                    title: Text(product.name,maxLines: 2,),
                    subtitle: Text('\$${product.newPrice}'),
                  );
                },
              ),
            )
          else
          // Show search results when a query is entered
            Expanded(
              child: ListView.builder(
                itemCount: provider.searchResults.length,
                itemBuilder: (context, index) {
                  final product = provider.searchResults[index];
                  return ListTile(
                    leading: Image.network(product.image),
                    title: Text(product.name),
                    subtitle: Text('\$${product.newPrice}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
