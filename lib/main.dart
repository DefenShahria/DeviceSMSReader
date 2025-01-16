import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('smsPlatform');
  String _smsData = 'No data';

  Future<void> _getSmsData() async {
    try {
      final String result = await platform.invokeMethod('readAllSms');
      setState(() {
        _smsData = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _smsData = "Failed to get SMS data: '${e.message}'.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SMS Reader")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_smsData),
                ElevatedButton(
                  onPressed: _getSmsData,
                  child: Text('Get SMS Data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
