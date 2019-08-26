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
  Hero hero = null;
  final _heros = <Hero>[];
  final _biggerFont = const TextStyle(fontSize: 20.0);

  @override
  initState() {
    super.initState();
    generateHero().then((Hero value) {
      setState(() {
        hero = value;
      });
  });
  }

  @override
  Widget build(BuildContext context) {
    if(hero == null)  {
      return Text(
        'Loading...',
        style: _biggerFont,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Hero List'),
        ),
        body: _buildHeros(),
      );
    }
  }

  Widget _buildHeros() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          if (index >= _heros.length) {
             generateHero().then((Hero value) {
               _heros.add(value);
             });
          }
          return _buildRow(_heros[index]);
        });
  }

  Widget _buildRow(Hero hero) {
    return ListTile(
      title: Text(
        hero.name,
        style: _biggerFont,
      ),
    );
  }
}

class HeroList extends StatefulWidget {
  @override
  HeroState createState() => HeroState();
}

Future<Hero> generateHero() async {
  int randomHero = new Random().nextInt(731);
  final response =
  await http.get(url+'/'+randomHero.toString());

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    return await Hero.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw await Exception('Failed to load post');
  }
}

class Hero {
  //final List<int> powerstats;
  final String name;

  Hero({this.name});

  /*
  Widget fight(Hero opponent) {
    int randomPower = new Random().nextInt(5);
    if(this.powerstats[randomPower] > opponent.powerstats[randomPower]) {
      return Text(this.name + ' won the fight!');
    } else {
      return Text(opponent.name + ' won the fight!');
    }
  }*/

  factory Hero.fromJson(Map<String, dynamic> json) {
    return Hero(
        name: json['name'],
        //powerstats: json['powerstats']
    );
  }
}


