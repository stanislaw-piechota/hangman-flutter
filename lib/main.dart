import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hangman: Reactivation',
      home: JoinPage(title: 'Hangman: Reactivation'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JoinPage extends StatefulWidget {
  const JoinPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<JoinPage> createState() => _JoinPageState();
}

joinGame(String code, String nick) async {
  var resp = await get(Uri.parse(
      'http://hunched-mittens.000webhostapp.com/?join&nick=' +
          nick +
          '&code=' +
          code));
  return resp.body;
}

leaveGame(String code, String nick) async {
  var resp = await get(Uri.parse(
      'http://hunched-mittens.000webhostapp.com/?leave&nick=' +
          nick +
          '&code=' +
          code));
  return resp.body;
}

const br = Color(0xffe5eec5), dr = Color(0xff4d4f47);
const bgDr = TextStyle(color: dr, fontSize: 30, fontWeight: FontWeight.bold);

class _JoinPageState extends State<JoinPage> {
  int index = 0;
  List<Widget> screens = [];
  String nick = '', code = '', points = '';
  Timer? timer;
  bool letterStarted = false, checkAPI = false;
  var start = DateTime.now(), end = DateTime.now(), data = {};

  void eventsLoop() async {
    if (checkAPI) {
      try {
        if (!letterStarted) {
          var resp = await get(Uri.parse(
              'http://hunched-mittens.000webhostapp.com/' + code + '.json'));
          var data = jsonDecode(resp.body);
          if (data['a2SsdaS34']) {
            letterStarted = true;
            start = DateTime.now();
            setState(() {
              index = 2;
            });
          }
        } else {
          var resp = await get(Uri.parse(
              'http://hunched-mittens.000webhostapp.com/' +
                  code +
                  '-time.json'));
          var data = jsonDecode(resp.body);
          if (!data['a2SsdaS34']) {
            letterStarted = false;
            setState(() {
              index = 1;
            });
          }
        }
      } catch (e) {
        checkAPI = false;
        await leaveGame(code, nick);
        setState(() {
          index = 0;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 3), (Timer t) => eventsLoop());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nick = TextEditingController(),
        code = TextEditingController(),
        letter = TextEditingController();
    List<Widget> screens = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Hangman: Reactivation',
            style: bgDr,
          ),
          const SizedBox(height: 150),
          const Text('Podaj swój nick'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: nick,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50),
          const Text('Podaj kod gry'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: code,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              if (nick.text == '' || code.text == '') {
                showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                        content: Text('Wprowadź prawidłowy kod oraz nick')));
              } else {
                this.nick = nick.text;
                this.code = code.text;
                var r = await joinGame(this.code, this.nick);
                if (r == "ok") {
                  setState(() {
                    checkAPI = true;
                    letterStarted = false;
                    points = 'PUNKTY:  0';
                    index = 1;
                  });
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                          content: Text("Nie udało się połączyć z serwerem.")));
                }
              }
            },
            child: const Text('ZATWIERDŹ'),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith((states) => dr),
                foregroundColor:
                    MaterialStateProperty.resolveWith((states) => br)),
          )
        ],
      ),
      Column(
        children: [
          const SizedBox(height: 30),
          Padding(
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) => dr),
                      foregroundColor:
                          MaterialStateProperty.resolveWith((states) => br)),
                  onPressed: () async {
                    var r = await leaveGame(this.code, this.nick);
                    setState(() {
                      if (r == "ok") {
                        checkAPI = false;
                        index = 0;
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                                content: Text('Nie udało się opuścić gry')));
                      }
                    });
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_back),
                        Text(' OPUŚĆ GRĘ')
                      ])),
              padding: const EdgeInsets.symmetric(horizontal: 110)),
          const SizedBox(
            height: 250,
          ),
          const Padding(
              child: Text('Poczekaj na podawanie litery',
                  textAlign: TextAlign.center, style: bgDr),
              padding: EdgeInsets.symmetric(horizontal: 40))
        ],
      ),
      Column(
        children: [
          const SizedBox(height: 30),
          Padding(
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) => dr),
                      foregroundColor:
                          MaterialStateProperty.resolveWith((states) => br)),
                  onPressed: () async {
                    var r = await leaveGame(this.code, this.nick);
                    setState(() {
                      if (r == "ok") {
                        checkAPI = false;
                        index = 0;
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                                content: Text('Nie udało się opuścić gry')));
                      }
                    });
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_back),
                        Text(' OPUŚĆ GRĘ')
                      ])),
              padding: const EdgeInsets.symmetric(horizontal: 110)),
          const SizedBox(
            height: 250,
          ),
          const Text('WPISZ LITERĘ LUB HASŁO',
              style: TextStyle(
                  color: dr, fontSize: 25, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: letter,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  var time = DateTime.now()
                      .difference(start)
                      .inMicroseconds
                      .toString();
                  debugPrint(time);
                  await get(Uri.parse(
                      'https://hunched-mittens.000webhostapp.com/?code=' +
                          this.code +
                          '&submit=' +
                          letter.text +
                          '&time=' +
                          time +
                          '&letter&nick=' +
                          this.nick));
                  setState(() {
                    index = 1;
                  });
                },
                child: const Text(
                  'LITERA',
                  style: TextStyle(color: br),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) => dr)),
              ),
              const SizedBox(
                width: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  var time = DateTime.now()
                      .difference(start)
                      .inMicroseconds
                      .toString();
                  debugPrint(time);
                  await get(Uri.parse(
                      'https://hunched-mittens.000webhostapp.com/?code=' +
                          this.code +
                          '&submit=' +
                          letter.text +
                          '&time=' +
                          time +
                          '&nick=' +
                          this.nick));
                  setState(() {
                    index = 1;
                  });
                },
                child: const Text(
                  'HASŁO',
                  style: TextStyle(color: br),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) => dr)),
              )
            ],
          )
        ],
      )
    ];

    return Scaffold(
      backgroundColor: br,
      body: Center(child: screens[index]),
    );
  }
}
