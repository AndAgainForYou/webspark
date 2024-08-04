import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webspark_test/Pages/api.dart';
import 'package:webspark_test/Pages/clases.dart';
import 'package:webspark_test/Pages/resultScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isLoading = false;
  double _progress = 0.0;
  List<Task> _taskResults = [];
  bool _taskCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('api_url');
    if (savedUrl != null) {
      _controller.text = savedUrl;
    }
  }

  Future<void> _saveUrl() async {
    String url = _controller.text;
    if (Uri.tryParse(url)?.hasAbsolutePath ?? false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_url', url);
      setState(() {
        _errorText = null;
      });
      await _getTasks(url);
    } else {
      setState(() {
        _errorText = 'Invalid URL';
      });
    }
  }

  Future<void> _getTasks(String url) async {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
    });

    try {
      List<Task> tasks = await ApiService().getTasks(url);

      for (int i = 0; i < tasks.length; i++) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _progress = (i + 1) / tasks.length;
        });
      }

      setState(() {
        _isLoading = false;
        _taskCompleted = true;
        _taskResults = tasks;
      });
      
      if (tasks.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(tasks: tasks, apiUrl: url),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Error: $e';
      });
    }
  }

  Future<void> _sendResults() async {
    setState(() {
      _isLoading = true;
    });

    try {

      setState(() {
        _isLoading = false;
        _taskCompleted = false;

      /*  Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultsScreen(results: results)),
        );
      */
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Set valid API base URL in order to continue'),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link),
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Column(
                    children: [
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 10),
                      Text('Loading tasks... ${(_progress * 100).toStringAsFixed(0)}%'),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _saveUrl,
                    child: const Text('Start counting process'),
                  ),
            if (_taskCompleted)
              ElevatedButton(
                onPressed: _sendResults,
                child: const Text('Send results to server'),
              ),
          ],
        ),
      ),
    );
  }
}
