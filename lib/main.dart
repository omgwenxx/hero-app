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
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: AppBar(
              title: Text('Heroes \n(Choose two Heroes to fight)',
                  style: TextStyle(fontSize: 15.0)),
              actions: <Widget>[
                new FlatButton(
                  child: Text(
                    "Fight",
                    style: const TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onPressed: _showFight,
                )
              ])),
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

  /*
  Widget _buildHeroes() {
    return ListView.builder(
        itemCount: 30,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: generateHero(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return _buildRow(snapshot.data);
                  }
              }
            },
          );
        });
  }*/

  Widget _buildRow(Hero hero) {
    final bool alreadySaved = fighter.contains(hero);
    final font = const TextStyle(fontSize: 20.0, color: Colors.white);
    return ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return Container(
                      margin: EdgeInsets.only(top: 80.0),
                      padding: EdgeInsets.all(10.0),
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Text(
                                  'Intelligence: ' +
                                      hero.powerstats['intelligence'],
                                  style: font)),
                          Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Text('Power: ' + hero.powerstats['power'],
                                  style: font)),
                          Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Text(
                                  'Durability: ' +
                                      hero.powerstats['durability'],
                                  style: font)),
                          Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Text('Speed: ' + hero.powerstats['speed'],
                                  style: font)),
                          Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Text(
                                  'Strength: ' + hero.powerstats['strength'],
                                  style: font)),
                          Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Text(
                                  'Combat: ' + hero.powerstats['combat'],
                                  style: font)),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit
                                  .contain, // otherwise the logo will be tiny
                              child: Image.network(
                                hero.image,
                                width: 70,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ));
                },
              ),
            );
          },
          child: ClipOval(
              child: Image.network(
            hero.image,
            width: 70,
            height: 50,
            fit: BoxFit.cover,
          )),
        ),
        title: Text(hero.name, style: _biggerFont),
        trailing: Icon(
          alreadySaved ? Icons.add_circle : Icons.add_circle_outline,
        ),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              fighter.remove(hero);
            } else if (fighter.length < 2) {
              fighter.add(hero);
            }
          });
        });
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
    var heroPower = this.powerstats[power];
    var opponentPower = opponent.powerstats[power];

    if (heroPower == 'null') {
      heroPower = 0;
    } else {
      heroPower = int.parse(this.powerstats[power]);
    }

    if (opponentPower == 'null') {
      opponentPower = 0;
    } else {
      opponentPower = int.parse(opponent.powerstats[power]);
    }

    if (heroPower > opponentPower) {
      return this.name +
          ' won the fight! With ' +
          heroPower.toString() +
          ' ' +
          power.toString() +
          '.';
    } else if (heroPower == opponentPower) {
      return 'Tie! With ' + heroPower.toString() + ' in ' + power+'.';
    } else {
      return opponent.name +
          ' won the fight! With ' +
          opponentPower.toString() +
          ' ' +
          power +
          '.';
    }
  }

  factory Hero.fromJson(Map<String, dynamic> json) {
    var imageMap = json['image'].values.toList();
    var imageUrl = imageMap[0];

    if (imageUrl == null) {
      imageUrl = 'https://via.placeholder.com/150';
    }

    var powerstatsMap = json['powerstats'];

    if (powerstatsMap == null) {
      powerstatsMap = [
        {
          'intelligence': '0',
        },
        {
          'power': '0',
        },
        {
          'speed': '0',
        },
        {
          'durability': '0',
        },
        {
          'combat': '0',
        },
        {
          'strength': '0',
        }
      ];
    }

    return Hero(name: json['name'], image: imageUrl, powerstats: powerstatsMap);
  }
}
