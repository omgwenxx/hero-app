import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

String url = 'https://superheroapi.com/api/10157312339637696';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Center(
          child: HeroList(),
        ),
      ),
    );
  }
}

class HeroState extends State<HeroList> {
  Future<List<Hero>> heroesFuture;
  Set<Hero> fighter = Set<Hero>();
  final _biggerFont = const TextStyle(fontSize: 20.0);

  @override
  void initState() {
    super.initState();
    heroesFuture = generateHeroes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Heroes (Choose two Heroes to fight)', style: TextStyle(fontSize: 15.0)), actions: <Widget>[
        new FlatButton(
          child: Text(
            "Fight",
            style: const TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          onPressed: _showFight,
        )
      ]),
      body: _buildHeroes(),
    );
  }

  void _showFight() {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Hero Fight'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(fighter.elementAt(0).fight(fighter.elementAt(1))),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroes() {
    return FutureBuilder(
      future: heroesFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Container(
              alignment: Alignment.center,
              child: Text("Loading..."),
            );
            break;
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Container(
                alignment: Alignment.center,
                child: Text("Error: ${snapshot.error}"),
              );
            }
            var data = snapshot.data;
            return new ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: false,
              itemBuilder: (_, int index) => _buildRow(data[index]),
              itemCount: data.length,
            );
            break;
        }
      },
    );
  }

  Widget _buildRow(Hero hero) {
    final bool alreadySaved = fighter.contains(hero);
    return ListTile(
      leading: ClipOval(
        child: Image.network(
          hero.image,
          width: 70,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(hero.name, style: _biggerFont),
        trailing: Icon(   // Add the lines from here...
          alreadySaved ? Icons.add_circle : Icons.add_circle_outline,
          color: alreadySaved ? Colors.black : null,
        ),
      onTap: () {      // Add 9 lines from here...
        setState(() {
          if (alreadySaved) {
            fighter.remove(hero);
          } else if (fighter.length < 2) {
            fighter.add(hero);
          }
        });
      },
    );
  }
}

class HeroList extends StatefulWidget {
  @override
  HeroState createState() => HeroState();
}

Future<Hero> generateHero() async {
  int randomHero = new Random().nextInt(731);
  final response = await http.get(url + '/' + randomHero.toString());

  if (response.statusCode == 200) {
    return await Hero.fromJson(json.decode(response.body));
  } else {
    throw await Exception('Failed to load post');
  }
}

Future<List<Hero>> generateHeroes() async {
  List<Hero> heroes = <Hero>[];
  for (int i = 0; i <= 20; i++) {
    int randomHero = new Random().nextInt(731);
    final response = await http.get(url + '/' + randomHero.toString());

    if (response.statusCode == 200) {
      heroes.add(await Hero.fromJson(json.decode(response.body)));
    } else {
      throw await Exception('Failed to load post');
    }
  }
  return heroes;
}

class Hero {
  final String name;
  final String image;
  final dynamic powerstats;

  Hero({this.name, this.image, this.powerstats});

  String fight(Hero opponent) {
    int randomPower = new Random().nextInt(5);
    List<String> keys = this.powerstats.keys.toList();
    String power = keys[randomPower];
    if (int.parse(this.powerstats[power]) >
        int.parse(opponent.powerstats[power])) {
      return this.name + ' won the fight! With '+this.powerstats[power]+' '+power;
    } else {
      return opponent.name + ' won the fight! With '+opponent.powerstats[power]+' '+power;
    }
  }

  factory Hero.fromJson(Map<String, dynamic> json) {
    var imageMap = json['image'].values.toList();
    var imageUrl = imageMap[0];

    if (imageUrl == null) {
      imageUrl = 'https://via.placeholder.com/150';
    }

    var powerstatsMap = json['powerstats'];
    return Hero(name: json['name'], image: imageUrl, powerstats: powerstatsMap);
  }
}
