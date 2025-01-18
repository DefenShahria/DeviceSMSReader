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
  List<String> displayedMessages = []; // SMS messages currently shown
  List<String> newMessages = []; // New messages not yet shown

  Future<void> _getSmsData() async {
    try {
      final result = await platform.invokeMethod<List<Object?>>('readAllSms');
      if (result != null) {
        // Filter messages where the contact name is "DFNInternet"
        final filteredMessages = result.cast<String>().where((message) {
          return message.contains("DFNInternet");
        }).toList();

        // Identify new messages
        final fetchedNewMessages = filteredMessages
            .where((message) => !displayedMessages.contains(message))
            .toList();

        if (fetchedNewMessages.isNotEmpty) {
          setState(() {
            // Add new messages to the displayed list
            newMessages = fetchedNewMessages;
            displayedMessages.addAll(fetchedNewMessages);
          });
        }
      }
    } on PlatformException catch (e) {
      setState(() {
        newMessages = ['Failed to get SMS: ${e.message}'];
      });
    } catch (e) {
      setState(() {
        newMessages = ['Error: $e'];
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
          if (newMessages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'New SMS: ${newMessages.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: newMessages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(newMessages[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
