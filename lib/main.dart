import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Jokes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: JokesHomeScreen(),
    );
  }
}

class JokesHomeScreen extends StatefulWidget {
  @override
  _JokesHomeScreenState createState() => _JokesHomeScreenState();
}

class _JokesHomeScreenState extends State<JokesHomeScreen> {
  List<String> jokeTypes = [];

  @override
  void initState() {
    super.initState();
    fetchJokeTypes();
  }

  Future<void> fetchJokeTypes() async {
    final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/types'));
    if (response.statusCode == 200) {
      setState(() {
        jokeTypes = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load joke types');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joke Types'),
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb),
            onPressed: () async {
              final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/random_joke'));
              if (response.statusCode == 200) {
                final joke = json.decode(response.body);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RandomJokeScreen(joke: joke),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: jokeTypes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: jokeTypes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(jokeTypes[index], style: TextStyle(fontSize: 18.0)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JokesByTypeScreen(type: jokeTypes[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class JokesByTypeScreen extends StatefulWidget {
  final String type;
  JokesByTypeScreen({required this.type});

  @override
  _JokesByTypeScreenState createState() => _JokesByTypeScreenState();
}

class _JokesByTypeScreenState extends State<JokesByTypeScreen> {
  List jokes = [];

  @override
  void initState() {
    super.initState();
    fetchJokesByType();
  }

  Future<void> fetchJokesByType() async {
    final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/jokes/${widget.type}/ten'));
    if (response.statusCode == 200) {
      setState(() {
        jokes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load jokes of type ${widget.type}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type} Jokes')),
      body: jokes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: jokes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(jokes[index]['setup'], style: TextStyle(fontSize: 16.0)),
                    subtitle: Text(jokes[index]['punchline'], style: TextStyle(fontSize: 14.0)),
                  ),
                );
              },
            ),
    );
  }
}

class RandomJokeScreen extends StatelessWidget {
  final Map joke;
  RandomJokeScreen({required this.joke});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Random Joke of the Day')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(joke['setup'], style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 20.0),
              Text(joke['punchline'], style: TextStyle(fontSize: 16.0), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
