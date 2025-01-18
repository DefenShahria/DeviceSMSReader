import 'dart:async';
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
      debugShowCheckedModeBanner: false,
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
  List<String> displayedMessages = [];
  Set<String> seenMessages = {}; // Set to keep track of shown messages
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPeriodicSmsCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getSmsData() async {
    try {
      final result = await platform.invokeMethod<List<Object?>>('readAllSms');
      if (result != null) {
        final filteredMessages = result.cast<String>().where((message) {
          return message.contains("DFNInternet");
        }).toList();

        final newMessages = filteredMessages.where((message) {
          return !seenMessages.contains(message);
        }).toList();

        if (newMessages.isNotEmpty) {
          setState(() {
            displayedMessages.insertAll(0, newMessages);
            seenMessages.addAll(newMessages);
          });

          for (var message in newMessages) {
            debugPrint('New Message: $message');
          }
        }
      }
    } on PlatformException catch (e) {
      setState(() {
        displayedMessages = ['Failed to get SMS: ${e.message}'];
      });
    } catch (e) {
      setState(() {
        displayedMessages = ['Error: $e'];
      });
    }
  }

  void _startPeriodicSmsCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getSmsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Reader'),
      ),
      body: Column(
        children: [
          Text(
            'New Messages: ${displayedMessages.length}',
            style: const TextStyle(
                color: Colors.green, fontSize: 22, fontWeight: FontWeight.w400),
          ),
          if (displayedMessages.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: displayedMessages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(displayedMessages[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
