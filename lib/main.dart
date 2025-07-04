import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Scanner Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DocumentScannerPage(),
    );
  }
}

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({super.key});

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  List<String> _scannedImages = [];

  Future<void> _scanDocument() async {
    try {
      final images = await CunningDocumentScanner.getPictures();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _scannedImages = images;
        });
      }
    } catch (e) {
      debugPrint("Xatolik: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hujjatni Skanerlash')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _scanDocument,
            child: const Text('Hujjatni skanerlash'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _scannedImages.isEmpty
                ? const Center(child: Text('Hali hujjat skanerl. qilingan emas'))
                : ListView.builder(
                    itemCount: _scannedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          File(_scannedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
