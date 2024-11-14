import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/constants/search_container.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List _allResults=[];
  List _resultList=[];
  final _searchController=TextEditingController();
  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }
  _onSearchChanged(){
    print("Flutter: ${_searchController.text}");
    searchResultList();
  }
  //Search List
  searchResultList(){
    var showsResults=[];
    if(_searchController.text!=""){
      for(var productSnapshot in _allResults){
        var name = productSnapshot['name'].toString().toLowerCase();
        if(name.contains(_searchController.text.toLowerCase())){
          showsResults.add(productSnapshot);
        }
      }
    }else{
      showsResults=List.from(_allResults);
    }
    setState(() {
      _resultList=showsResults;
    });
  }

  getProductStream()async{
    var data =await DbServices().fetchProducts();
    setState(() {
      _allResults=data.docs;
    });
    searchResultList();
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    getProductStream();
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CupertinoSearchTextField(
          controller: _searchController,
        ),
      ),
      body: ListView.builder(
        itemCount: _resultList.length,
          itemBuilder: (context,index){
            final product = _resultList[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
              context, "/view_product",
              arguments: product),
          child: ListTile(
            leading: SizedBox(
              height: 80,
              width: 80,
              child: CachedNetworkImage(imageUrl: _resultList[index]['image']),
            ),
            title: Text(_resultList[index]['name'],maxLines: 2,),
            subtitle: Text(_resultList[index]['category']),
            trailing: Text("₹ ${_resultList[index]['new_price'].toString()}"),
          ),
        );
      })
    );
  }
}
