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
  int totalMessages = 0; // Total messages in the first step
  String? latestMessage; // Holds the most recent new message
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeMessageCount();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeMessageCount() async {
    try {
      final result = await platform.invokeMethod<List<Object?>>('readAllSms');
      if (result != null) {
        final filteredMessages = result.cast<String>().where((message) {
          return message.contains("DFNInternet");
        }).toList();
        // Save the total count of initial messages
        totalMessages = filteredMessages.length;
        // Start periodic checks after initialization
        _startPeriodicSmsCheck();
      }
    } on PlatformException catch (e) {
      setState(() {
        latestMessage = 'Failed to get SMS: ${e.message}';
      });
    } catch (e) {
      setState(() {
        latestMessage = 'Error: $e';
      });
    }
  }

  Future<void> _checkForNewMessages() async {
    try {
      final result = await platform.invokeMethod<List<Object?>>('readAllSms');
      if (result != null) {
        final filteredMessages = result.cast<String>().where((message) {
          return message.contains("DFNInternet");
        }).toList();

        // Check if the number of messages has increased
        if (filteredMessages.length > totalMessages) {
          setState(() {
            latestMessage = filteredMessages.first; // Get the newest message
          });

          // Update the total message count
          totalMessages = filteredMessages.length;

          // Print for debugging
          debugPrint('New Message: $latestMessage');
        }
      }
    } on PlatformException catch (e) {
      setState(() {
        latestMessage = 'Failed to get SMS: ${e.message}';
      });
    } catch (e) {
      setState(() {
        latestMessage = 'Error: $e';
      });
    }
  }

  void _startPeriodicSmsCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkForNewMessages();
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
          Center(
            child: latestMessage != null
                ? Text(
              latestMessage!,
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            )
                : const Text(
              'No new messages',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          ElevatedButton(onPressed: (){
            print(latestMessage);
          }, child: Text("Print latest msg data"))
        ],
      ),
    );
  }
}
