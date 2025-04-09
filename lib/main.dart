import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CatFactApp());
}

class CatFactApp extends StatelessWidget {
  const CatFactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: FactHomePage());
  }
}

class FactHomePage extends StatefulWidget {
  const FactHomePage({super.key});

  @override
  FactHomePageState createState() => FactHomePageState();
}

class FactHomePageState extends State<FactHomePage> {
  String currentLanguage = 'English';
  String currentFact = '';
  List<String> savedFacts = [];
  bool loadingFact = false;
  List<String> languageOptions = ['English', 'Spanish', 'French'];

  Future<void> loadCatFact() async {
    setState(() {
      loadingFact = true;
    });
    String apiUrl = 'https://catfact.ninja/fact';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        currentFact = responseData['fact'];
      });
    } else {
      setState(() {
        currentFact = 'Failed to load cat fact';
      });
    }
    setState(() {
      loadingFact = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCatFact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Random Cat Facts")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(children: [
          DropdownButton<String>(
            value: currentLanguage,
            items: languageOptions.map((lang) {
              return DropdownMenuItem<String>(
                value: lang,
                child: Text(lang),
              );
            }).toList(),
            onChanged: (newLang) {
              setState(() {
                currentLanguage = newLang!;
              });
              loadCatFact();
            },
          ),
          SizedBox(height: 20),
          loadingFact
              ? CircularProgressIndicator()
              : Text(currentFact, style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  savedFacts.add(currentFact);
                  loadCatFact();
                },
                child: Text("Save & Next"),
              ),
              ElevatedButton(
                onPressed: loadCatFact,
                child: Text("Next Fact"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SavedFactsScreen(factsList: savedFacts)),
                  );
                },
                child: Text("Saved Facts"),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Exit App"),
          )
        ]),
      ),
    );
  }
}

class SavedFactsScreen extends StatefulWidget {
  final List<String> factsList;
  const SavedFactsScreen({super.key, required this.factsList});

  @override SavedFactsScreenState createState() => SavedFactsScreenState();
}

class SavedFactsScreenState extends State<SavedFactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Saved Cat Facts")),
      body: ListView.builder(
        itemCount: widget.factsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.factsList[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            widget.factsList.clear();
          });
        },
        child: Icon(Icons.delete_forever),
      ),
    );
  }
}