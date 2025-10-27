import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud AI Keyboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const AiKeyboardPage(),
    );
  }
}

class AiKeyboardPage extends StatefulWidget {
  const AiKeyboardPage({super.key});

  @override
  State<AiKeyboardPage> createState() => _AiKeyboardPageState();
}

class _AiKeyboardPageState extends State<AiKeyboardPage> {
  final TextEditingController _controller = TextEditingController();
  String _apiResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_formatText);
  }

  @override
  void dispose() {
    _controller.removeListener(_formatText);
    _controller.dispose();
    super.dispose();
  }

  void _formatText() {
    String text = _controller.text.replaceAll('.', '');
    if (text.length > 18) {
      text = text.substring(0, 18);
    }
    String newText = '';

    for (int i = 0; i < text.length; i++) {
      newText += text[i];
      if ((i + 1) % 6 == 0 && i < text.length - 1) {
        newText += '.';
      }
    }

    // This is to avoid an infinite loop by only updating if the text actually changed
    if (newText != _controller.text) {
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    
    // Check for auto-send when exactly 18 digits are entered
    if (text.length == 18) {
      _sendToApi(newText);
    }
  }

  Future<void> _sendToApi(String data) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _apiResponse = 'Sending to Cloud AI...';
    });

    // Simulate a network request to a cloud AI
    await Future.delayed(const Duration(seconds: 2));

    // This is a placeholder for your actual API call.
    // For now, we'll just return a mock success message.
    setState(() {
      _isLoading = false;
      _apiResponse = 'Cloud AI Response: Processed data "$data" successfully.';
      _controller.clear();
    });
    
    // Hide the response message after a few seconds to keep the UI clean
    Timer(const Duration(seconds: 5), () {
        if(mounted) {
            setState(() {
                _apiResponse = '';
            });
        }
    });
  }

  void _onKeyPressed(String value) {
    if (_isLoading) return;

    String currentText = _controller.text.replaceAll('.', '');
    if (value == 'BACKSPACE') {
      if (currentText.isNotEmpty) {
        currentText = currentText.substring(0, currentText.length - 1);
      }
    } else if (currentText.length < 18) {
      currentText += value;
    }
    _controller.text = currentText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud AI Numeric Keyboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              readOnly: true,
              showCursor: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 2.0, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide.none,
                ),
                hintText: '000000.000000.000000',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                    child: Text(
                                    _apiResponse,
                                    style: TextStyle(
                    fontSize: 16,
                    color: _apiResponse.contains('successfully') ? Colors.green.shade700 : Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                  ),
            ),
            const Spacer(),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      'CLEAR', '0', 'BACKSPACE',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        
        Widget keyChild;
        VoidCallback? onPressed = () => _onKeyPressed(key);
        Color color = Colors.white;
        
        switch (key) {
          case 'BACKSPACE':
            keyChild = const Icon(Icons.backspace_outlined, color: Colors.black54);
            color = Colors.grey.shade300;
            break;
          case 'CLEAR':
            keyChild = const Text('C', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54));
            color = Colors.grey.shade300;
            onPressed = () {
              if (!_isLoading) _controller.clear();
            };
            break;
          default:
            keyChild = Text(
              key,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            );
        }

        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(16),
            elevation: 4,
            shadowColor: Colors.grey.withOpacity(0.4),
          ),
          child: keyChild,
        );
      },
    );
  }
}
