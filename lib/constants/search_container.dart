import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchContainer extends StatefulWidget {
  const SearchContainer({super.key});

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> recent = [
      {'name': "apple", "category": "mobile", "des": "More Secure"},
      {'name': "MSI", "category": "laptop", "des": "More Secure"},
      {'name': "BoAt AirBud", "category": "airduds", "des": "More Secure"},
    ];
    List<Map<String, dynamic>> _found = [];
    void _runFilter(String keyboardText) {
      List<Map<String, dynamic>> result = [];
      print(result);
      if (keyboardText.isEmpty) {
        result = recent;
      } else {
        result = result
            .where((product) => product['name']
                .toLowerCase()
                .contains(keyboardText.toLowerCase()))
            .toList();
      }
      setState(() {
        _found = result;
      });
    }

    TextEditingController _searchController = TextEditingController();
    return Container(
      child: Column(
        children: [
          TextField(
            onChanged: (value) => _runFilter(value),
            //controller: _searchController,
            decoration: InputDecoration(
                prefixIcon: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back)),
                hintText: 'Search for Products, Brands and More',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.only(bottom: 20, top: 5),
                suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        _searchController.text = "";
                      });
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.grey.shade400,
                    ))),
          ),
          _found != ""
              ? SizedBox()
              : Container(
                  height: 400,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.refresh),
                          title: Text(recent[index]['name']),
                          trailing: IconButton(
                              onPressed: () {}, icon: Icon(Icons.arrow_upward)),
                        );
                      }),
                )
        ],
      ),
    );
  }
}
