import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/views/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/discount_constant.dart';
import '../models/product.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  List<Product> _products = [];
  final List<String> _categories = ['All'];
  List<Product> _suggestedProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortOrder = 'low_to_high';
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final voiceSearch = TextEditingController();
  List<Product> _recentSearches = []; // To store recent searches

  @override
  void initState() {
    super.initState();

    // Fetch categories and products
    DbServices().getCategories().listen((categories) {
      setState(() {
        _categories.addAll(categories);
      });
    });

    DbServices().getProducts().listen((products) {
      setState(() {
        _products = products;
        _suggestedProducts = products;
      });
    });

    _loadRecentSearches(); // Load recent searches from SharedPreferences
  }

  // Load recent searches from SharedPreferences
  /*_loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }*/

  /*// Save recent searches to SharedPreferences
  _saveRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recent_searches', _recentSearches);
  }*/
// Load recent searches from SharedPreferences
  _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the stored JSON strings
    List<String>? recentSearchesJson = prefs.getStringList('recent_searches');

    if (recentSearchesJson != null) {
      // Convert the JSON strings back into Product objects
      setState(() {
        _recentSearches = recentSearchesJson
            .map((jsonStr) => Product.fromFirestore(json.decode(jsonStr)))
            .toList();
      });
    } else {
      setState(() {
        _recentSearches = [];
      });
    }
  }

// Save recent searches to SharedPreferences
  _saveRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert Product objects to JSON strings
    List<String> recentSearchesJson = _recentSearches
        .map((product) => json.encode(product.toJson()))
        .toList();

    // Save the JSON strings to SharedPreferences
    prefs.setStringList('recent_searches', recentSearchesJson);
  }

// Add a Product to recent searches
  _addToRecentSearches(Product product) {
    if (!_recentSearches.contains(product)) {
      if (_recentSearches.length >= 5) {
        _recentSearches.removeAt(0); // Keep only the last 5 searches
      }
      setState(() {
        _recentSearches.add(product);
      });
      _saveRecentSearches(); // Save the updated list to SharedPreferences
    }
  }

  /*// Add a search to recent searches
  _addToRecentSearches(String searchQuery) {
    if (!_recentSearches.contains(searchQuery)) {
      if (_recentSearches.length >= 5) {
        _recentSearches.removeAt(0); // Keep only the last 5 searches
      }
      _recentSearches.add(searchQuery);
      _saveRecentSearches();
    }
    print(_recentSearches.length);
  }*/

  // Voice search method
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        setState(() {
          _searchQuery = result.recognizedWords;
        });
      });
    }
    setState(() {
      _isListening = true;
    });
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            height: 400,
            width: 400,
            color: Colors.grey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_voice,
                  size: 40,
                ),
                _searchQuery.isEmpty
                    ? Text('Listening ....')
                    : Text("${_searchQuery.toString()}"),
              ],
            ),
          );
        });
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
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Sort by price
    if (_sortOrder == 'low_to_high') {
      filteredProducts.sort((a, b) => a.newPrice.compareTo(b.newPrice));
    } else if (_sortOrder == 'high_to_low') {
      filteredProducts.sort((a, b) => b.newPrice.compareTo(a.newPrice));
    }

    return filteredProducts;
  }

  // Suggestions based on the query
  List<Product> _getSuggestions() {
    return _products
        .where((product) =>
            product.name.toLowerCase().startsWith(_searchQuery.toLowerCase()))
        .toList();
  }

  // Display recommendations (could be based on any criteria, here random ones)
  List<Product> _getRecommendations() {
    return _products.take(5).toList();
  }

  // Display related products
  List<Product> _getRelatedProducts() {
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //Search Bar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextField(
                  //controller: voiceSearch,
                  decoration: InputDecoration(
                    labelText:
                        _isListening ? 'Listening...' : 'Search Products',
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                      print("Query: ${_searchQuery}");
                      _suggestedProducts = _getSuggestions();
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              CircleAvatar(
                child: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic,
                      color: _isListening ? Colors.red : Colors.green),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
            ],
          ),
          if (_searchQuery.isEmpty) ...[
            //Recently Search
            _recentSearches.isNotEmpty
                ? SizedBox(
                    height: size.height * .23,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Recently Searches',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          height: size.height * .18,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _recentSearches.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailScreen(
                                                    product: _recentSearches[
                                                        index])));
                                    _addToRecentSearches(
                                        _recentSearches[index]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, left: 8, right: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  _recentSearches[index].image),
                                        ),
                                        SizedBox(
                                            width: size.width * .2,
                                            child: Text(
                                              _recentSearches[index].name,
                                              maxLines: 2,
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            //Related Search
            SizedBox(
              height: size.height * .245,
              width: double.infinity,
              //color: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Related Searches',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: size.height * .2,
                    width: double.infinity,
                    child: GridView.builder(
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final related = _getRelatedProducts()[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                        product: _products[index])));
                            _addToRecentSearches(_getRelatedProducts()[index]);
                          },
                          child: Container(
                            color: Colors.grey.shade400,
                            height: size.height * .1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CachedNetworkImage(
                                    imageUrl: related.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                    width: 100,
                                    child: Text(
                                      related.name,
                                      maxLines: 2,
                                    ))
                              ],
                            ),
                          ),
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Recommended Stores for You
            SizedBox(
              height: size.height * .34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Recommended Stores For You',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: size.height * .28,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                          product: _products[index])));
                              _addToRecentSearches(_products[index]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 5.0, left: 8, right: 8),
                              child: Container(
                                width: size.width * .290,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: const Border(
                                      right: BorderSide(width: 1),
                                      left: BorderSide(width: 1),
                                      top: BorderSide(width: 1),
                                      bottom: BorderSide(width: 1),
                                    )),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                        height: size.height * .22,
                                        width: size.width * .24,
                                        child: CachedNetworkImage(
                                          imageUrl: _getRecommendations()[index]
                                              .image,
                                          fit: BoxFit.contain,
                                        )),
                                    SizedBox(
                                        width: size.width * .2,
                                        child: Text(
                                          _getRecommendations()[index].category,
                                          maxLines: 2,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
            //Popular Products
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Popular  Products',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: size.height * .9,
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 5,
                              childAspectRatio: 0.58),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                        product: _products[index])));
                            _addToRecentSearches(_products[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 5.0, left: 8, right: 8),
                            child: Container(
                              width: size.width * .290,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: const Border(
                                    right: BorderSide(width: 1),
                                    left: BorderSide(width: 1),
                                    top: BorderSide(width: 1),
                                    bottom: BorderSide(width: 1),
                                  )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: SizedBox(
                                        height: size.height * .15,
                                        width: size.width * .24,
                                        child: CachedNetworkImage(
                                          imageUrl: _products[index].image,
                                          fit: BoxFit.fill,
                                        )),
                                  ),
                                  SizedBox(
                                    height: size.height * .012,
                                  ),
                                  SizedBox(
                                      width: size.width * .2,
                                      child: Text(
                                        _products[index].name,
                                        maxLines: 1,
                                      )),
                                  SizedBox(
                                      width: size.width * .2,
                                      child: Text(
                                        _products[index].category,
                                        maxLines: 1,
                                        style: TextStyle(color: Colors.grey),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ],
          if (_searchQuery.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<String>(
                    hint: const Text('Sort'),
                    value: _sortOrder,
                    items: const [
                      DropdownMenuItem(
                          value: 'low_to_high',
                          child: Text('Price: Low to High')),
                      DropdownMenuItem(
                          value: 'high_to_low',
                          child: Text('Price: High to Low')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value!;
                      });
                    },
                  ),
                  DropdownButton<String>(
                    hint: const Text('Category'),
                    value: _selectedCategory,
                    items: _categories
                        .map((category) => DropdownMenuItem(
                            value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * .75,
              width: double.infinity,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product)),
                      );
                      _addToRecentSearches(product);
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
                                image: DecorationImage(
                                    image: NetworkImage(product.image),
                                    fit: BoxFit.fitHeight),
                              ),
                            ),
                          ),
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
                                    decoration: TextDecoration.lineThrough),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "₹ ${product.newPrice}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.green,
                                size: 1,
                              ),
                              Text(
                                "${discountPercent(product.oldPrice, product.newPrice)} %",
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
            SizedBox(
              height: size.height * .2,
              child: Text(
                "Total Products: ${_sortAndFilterProducts(_products).length}",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          ]
        ],
      ))),
      //bottomNavigationBar: buildTotalProducts(),
    );
  }

  /*Widget buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
                height: 100,
                child: ListView.builder(
                    itemCount: _recentSearches.length,
                    itemBuilder: (context,index){
                      if(_recentSearches.isEmpty){
                        return const SizedBox();
                      }
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(_recentSearches[index].image),
                        ),
                        title: SizedBox(
                            width: 50,
                            child: Text(_recentSearches[index].name,maxLines: 1,)),
                        onTap: () {
                          setState(() {
                            _searchQuery = _recentSearches[index].name;
                            _suggestedProducts = _getSuggestions();
                          });
                        },
                      );
                    })
              ),
      ],
    );
  }

  Widget buildTotalProducts() {
    return SizedBox(
    height: 50,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Total Products: ${_sortAndFilterProducts(_products).length}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  }

  Widget buildSuggest() {
    return Expanded(
              child: ListView.builder(
                itemCount: _suggestedProducts.length,
                itemBuilder: (context, index) {
                  final product = _suggestedProducts[index];
                  return ListTile(
                    leading: IconButton(
                      onPressed: (){
                        _suggestedProducts.remove(index);
                      },icon: const Icon(Icons.remove_outlined)),
                    title: Text(product.name,maxLines: 1,),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
                      );
                      setState(() {
                        _searchQuery = product.name;
                        _addToRecentSearches(_searchQuery.toString() as Product); // Add to recent searches
                      });
                    },
                  );
                },
              ),
            );
  }

  Widget buildRecommendedSearch() {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.only(top: 0),
        decoration: const BoxDecoration(
            color: Colors.white
        ),
        height: 265,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 18.0,left: 10),
              child: SizedBox(child: Text('Recommended Store For You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: 3,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow position
                        ),
                      ]
                      //color: Colors.white
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CachedNetworkImage(imageUrl: _products[index].image,fit: BoxFit.cover,),
                        Text(_products[index].category,style: const TextStyle(color: Colors.grey),)
                      ],
                    ),
                  ),
                );
              })
            ),
          ],
        )
    );
  }
  Widget buildRelatedSearch() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100
      ),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 18.0,left: 10),
            child: SizedBox(child: Text('Related Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          SizedBox(
            height: 250,
            child: GridView.builder(
              itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context,index){
                   final related = _getRelatedProducts()[index];
                  if(_getRelatedProducts().isEmpty){
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: related)),
                        );
                      },
                      child: Container(
                        width: 100,
                        color: Colors.grey.shade300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 50,
                              height: 50,
                              child: CachedNetworkImage(imageUrl: related.image,fit: BoxFit.cover,),
                            ),
                            const SizedBox(width: 10,),
                            SizedBox(
                              width: 100,
                                child: Text(related.name,maxLines: 2,))
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      )
    );
  }

  Widget buildProductCard() {
    return Container(
      child: Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
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
                                image: DecorationImage(
                                    image: NetworkImage(product.image),
                                    fit: BoxFit.fitHeight
                                ),
                              ),
                            ),
                          ),
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
                                    decoration: TextDecoration.lineThrough
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "₹ ${product.newPrice}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.green,
                                size: 1,
                              ),
                              Text(
                                "${discountPercent(product.oldPrice, product.newPrice)} %",
                                style: const TextStyle(fontSize: 14, color: Colors.green),
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
    );
  }

  Widget buildSortAndFilter() {
    return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                hint: const Text('Sort'),
                value: _sortOrder,
                items: const [
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
                hint: const Text('Category'),
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
          );
  }

  Widget buildSearchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(onPressed: () { Navigator.pop(context); }, icon: const Icon(Icons.arrow_back_ios)),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextField(
            controller: voiceSearch,
            decoration: InputDecoration(
              labelText: _isListening ? 'Listening...' : 'Search Products',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(40))
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
                _suggestedProducts = _getSuggestions();
              });
            },
          ),
        ),
        const SizedBox(width: 10,),
        CircleAvatar(
          child: IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: _isListening ? Colors.red : Colors.green),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
        ),
      ],
    );
  }*/
}
