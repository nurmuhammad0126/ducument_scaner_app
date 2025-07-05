import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Scanner PDF',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DocumentScannerPage(),
      debugShowCheckedModeBanner: false,
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

  /// Hujjatni skaner qilish
  Future<void> _scanDocument() async {
    try {
      final images = await CunningDocumentScanner.getPictures();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _scannedImages = images;
        });
      }
    } catch (e) {
      debugPrint('Xatolik: $e');
    }
  }

  /// PDF yaratish va ulashish
  Future<void> _generateAndSharePdf() async {
    if (_scannedImages.isEmpty) return;

    final pdf = pw.Document();

    for (final imagePath in _scannedImages) {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(child: pw.Image(pdfImage)),
        ),
      );
    }

    // Vaqtinchalik fayl saqlash
    final tempDir = await getTemporaryDirectory();
    final filePath = path.join(tempDir.path, 'scanned_document.pdf');
    final pdfFile = File(filePath);
    await pdfFile.writeAsBytes(await pdf.save());

    // Faylni ulashish
    await Share.shareXFiles([
      XFile(pdfFile.path),
    ], text: '📎 Mana mening skanerlangan hujjatim!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📄 Hujjatni skanerlash')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _scanDocument,
            icon: const Icon(Icons.camera_alt),
            label: const Text('📷 Hujjatni skanerlash'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _scannedImages.isNotEmpty ? _generateAndSharePdf : null,
            icon: const Icon(Icons.share),
            label: const Text('📤 PDF ni ulashish'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _scannedImages.isEmpty
                ? const Center(
                    child: Text(
                      'Hali hujjat skaner qilinmagan',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
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
