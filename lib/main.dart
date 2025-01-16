import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('smsPlatform');
  List<String> smsMessages = [];

  Future<void> _getSmsData() async {
    try {
      final result = await platform.invokeMethod<List<Object?>>('readAllSms');
      if (result != null) {
        setState(() {
          smsMessages = result.cast<String>();
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        smsMessages = ['Failed to get SMS: ${e.message}'];
      });
    } catch (e) {
      setState(() {
        smsMessages = ['Error: $e'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Reader'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _getSmsData,
            child: const Text('Read SMS'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: smsMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(smsMessages[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
