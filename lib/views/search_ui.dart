import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/views/product_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../constants/discount_constant.dart';
import '../models/product.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  List<Product> _products = [];
  List<String> _categories = ['All']; // Starting with 'All' option
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortOrder = 'low_to_high';
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final voiceSearch=TextEditingController();


  @override
  void initState() {
    super.initState();
    // Fetch categories from Firestore
    DbServices().getCategories().listen((categories){
      setState(() {
        _categories.addAll(categories);
      });
  });
    DbServices().getProducts().listen((products) {
      setState(() {
        _products = products;
      });
    });
  }

  // Voice search method
  void _startListening() async {
    /*showDialog(context: context, builder: (context){
      return Center(child: CupertinoSearchTextField(
        controller: voiceSearch,
      ),);
    });*/
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        setState(() {
          _searchQuery = result.recognizedWords;
        });
      });
    }
    print(_searchQuery);
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Sorting and Filtering method
  List<Product> _sortAndFilterProducts(List<Product> products) {
    List<Product> filteredProducts = products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filteredProducts = filteredProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    filteredProducts = filteredProducts
        .where((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Sort by price
    if (_sortOrder == 'low_to_high') {
      filteredProducts.sort((a, b) => a.newPrice.compareTo(b.newPrice));
    } else if (_sortOrder == 'high_to_low') {
      filteredProducts.sort((a, b) => b.newPrice.compareTo(a.newPrice));
    }

    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.arrow_back_ios)),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *.8,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search Products',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(_isListening ? Icons.mic_off : Icons.mic,color:_isListening?Colors.red: Colors.green,),
                          onPressed: (_isListening=!_isListening) ? _stopListening : _startListening,
                        ),
                      ),
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Sort & Filter Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  hint: Text('Sort'),
                  value: _sortOrder,
                  items: [
                    DropdownMenuItem(value: 'low_to_high', child: Text('Price: Low to High')),
                    DropdownMenuItem(value: 'high_to_low', child: Text('Price: High to Low')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortOrder = value!;
                    });
                  },
                ),
                DropdownButton<String>(
                  hint: Text('Category'),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
            // Product Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _sortAndFilterProducts(_products).length,
                itemBuilder: (context, index) {
                  final product = _sortAndFilterProducts(_products)[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to product detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey.shade200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.shade200,
                                    image: DecorationImage(
                                        image: NetworkImage(product.image),
                                        fit: BoxFit.fitHeight)),
                              )),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "₹ ${product.oldPrice}",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                    decoration:
                                    TextDecoration.lineThrough),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "₹ ${product.newPrice}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.green,
                                size: 1,
                              ),
                              Text(
                                "${discountPercent(product.oldPrice as int , product.newPrice as int )} %",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.green),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
