import 'package:flutter/material.dart';
import 'package:hushhxtinder/data/models/countriesModel.dart';

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({Key? key}) : super(key: key);

  @override
  _CountrySelectionScreenState createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  List<Country> filteredCountries = countries;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCountries = countries
          .where((country) => country.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your country'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterCountries();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                final country = filteredCountries[index];

                return ListTile(
                  leading: Image.asset(
                    "lib/assets/flags/${country.code.toLowerCase()}.png",
                    width: 32,
                    height: 32,
                  ),
                  title: Text(country.name),
                  trailing: Text(country.dialCode),
                  onTap: () {
                    Navigator.pop(context, country);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
