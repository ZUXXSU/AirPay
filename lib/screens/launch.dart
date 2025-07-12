import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void homepage() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 10.0,
              ),
              Image.asset(
                'assets/airpays.png',
                height: 80,
                width: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  // padding: EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 16.0),
                  onPressed: () {
                    Navigator.pushNamed(context, '/Choice');
                  },
                  // color: Colors.blue[900],
                  child: Text(
                    'GET STARTED',
                    style: TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set the button's background color
                    foregroundColor: Colors.white, // Set the text/icon color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChoiceScreen extends StatefulWidget {
  @override
  _ChoiceScreenState createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<ChoiceScreen> {
  void homepage() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              Image.asset(
                'assets/airpays.png',
                height: 80,
                width: 200,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      // padding: EdgeInsets.fromLTRB(2.0, 11.0, 2.0, 11.0),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(isSandbox: true),
                          ),
                        );
                      },
                      // color: Colors.blue[900],
                      child: Text(
                        'SANDBOX',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Set the button's background color
                        foregroundColor: Colors.white, // Set the text/icon color
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      // padding: EdgeInsets.fromLTRB(2.0, 11.0, 2.0, 11.0),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(isSandbox: false),
                          ),
                        );
                      },
                      // color: Colors.blue[900],
                      child: Text(
                        'PRODUCTION',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Set the button's background color
                        foregroundColor: Colors.white, // Set the text/icon color
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
