import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VerifFibre',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _detectedArea = "En attente de coordonnées";
  bool _showOrangeButton = false;

  void _processText() {
    final text = _controller.text;
    final regExp = RegExp(r'(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)');
    final match = regExp.firstMatch(text);

    if (match != null) {
      setState(() {
        _detectedArea = "Coordonnées détectées : ${match.group(1)}, ${match.group(2)}";
        _showOrangeButton = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position détectée avec succès !')),
      );
    } else {
      setState(() {
        _detectedArea = "Aucune coordonnée GPS valide trouvée";
        _showOrangeButton = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune coordonnée GPS trouvée dans le texte')),
      );
    }
  }

  Future<void> _launchOrange() async {
    final Uri url = Uri.parse('https://orange.sn');
    await Clipboard.setData(ClipboardData(text: _detectedArea));
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le site d\'Orange')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VerifFibre Orange Sénégal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Vérificateur Éligibilité Fibre",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Collez le message ou le lien de localisation WhatsApp ici...",
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _processText,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text("1. Extraire et Localiser", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: Text(_detectedArea, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.orange), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            if (_showOrangeButton)
              ElevatedButton(
                onPressed: _launchOrange,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6600), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("2. Vérifier Éligibilité Orange", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
