import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'dart:convert';

class DocumentScannerWidget extends StatefulWidget {
  final Function(Map<String, String>) onDataExtracted;

  const DocumentScannerWidget({Key? key, required this.onDataExtracted}) : super(key: key);

  @override
  State<DocumentScannerWidget> createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  String _status = '';

  // Text recognition instance
  final textRecognizer = TextRecognizer();

  // Firebase Vertex AI instance
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    // Initialize the Vertex AI model
    _model =
    FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash');
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureDocument() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _status = 'Image captured, processing...';
        });
        await _processDocument();
      }
    } catch (e) {
      setState(() {
        _status = 'Error capturing image: $e';
      });
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _status = 'Image selected, processing...';
        });
        await _processDocument();
      }
    } catch (e) {
      setState(() {
        _status = 'Error selecting image: $e';
      });
    }
  }

  Future<void> _processDocument() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Option 1: Direct image processing with Vertex AI (recommended)
      final extractedData = await _processImageDirectly();

      // Option 2: OCR first, then AI processing (uncomment if needed)
      // final extractedData = await _processWithOCRFirst();

      widget.onDataExtracted(extractedData);

      setState(() {
        _status = 'Data extraction completed!';
        _isProcessing = false;
      });

    } catch (e) {
      setState(() {
        _status = 'Processing error: $e';
        _isProcessing = false;
      });
    }
  }

  Future<Map<String, String>> _processImageDirectly() async {
    setState(() {
      _status = 'Analyzing document with AI...';
    });

    // Read image bytes
    final imageBytes = await _selectedImage!.readAsBytes();

    // Create the prompt for document data extraction
    const prompt = '''
    Analyze this document image and extract the following information. Return the result as a clean JSON object with these exact keys:

    {
      "name": "full name if found",
      "email": "email address if found", 
      "phone": "phone number if found",
      "address": "complete address if found",
      "date_of_birth": "date of birth if found",
      "id_number": "any ID/document numbers if found",
      "organization": "company/organization name if found",
      "position": "job title/position if found"
    }

    Rules:
    - Only include fields that you can clearly identify in the document
    - Use empty string "" for fields not found
    - Format phone numbers consistently
    - Format dates as YYYY-MM-DD if possible
    - Return only the JSON object, no additional text
    ''';

    final imagePart = InlineDataPart("image/png", imageBytes);
    try {
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          imagePart,
        ])
      ]);

      final responseText = response.text?.trim() ?? '';

      // Try to parse as JSON
      Map<String, String> extractedData = {};

      try {
        // Remove any markdown formatting if present
        String cleanJson = responseText;
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.substring(7);
        }
        if (cleanJson.endsWith('```')) {
          cleanJson = cleanJson.substring(0, cleanJson.length - 3);
        }
        cleanJson = cleanJson.trim();

        final parsed = jsonDecode(cleanJson);
        extractedData = Map<String, String>.from(
            parsed.map((key, value) => MapEntry(key.toString(), value.toString()))
        );

        // Remove empty values
        extractedData.removeWhere((key, value) => value.isEmpty);

      } catch (e) {
        // Fallback: parse manually if JSON parsing fails
        extractedData = _parseResponseManually(responseText);
      }

      return extractedData;

    } catch (e) {
      throw Exception('Vertex AI processing failed: $e');
    }
  }



  Map<String, String> _parseJsonResponse(String responseText) {
    try {
      // Clean up the response
      String cleanJson = responseText;
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final parsed = jsonDecode(cleanJson);
      final result = Map<String, String>.from(
          parsed.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''))
      );

      // Remove empty values
      result.removeWhere((key, value) => value.isEmpty || value == 'null');

      return result;

    } catch (e) {
      return _parseResponseManually(responseText);
    }
  }

  Map<String, String> _parseResponseManually(String text) {
    final Map<String, String> result = {};
    final lines = text.split('\n');

    for (String line in lines) {
      line = line.trim();
      if (line.contains(':')) {
        final colonIndex = line.indexOf(':');
        final key = line.substring(0, colonIndex).trim()
            .replaceAll('"', '')
            .replaceAll('*', '')
            .toLowerCase()
            .replaceAll(' ', '_');
        final value = line.substring(colonIndex + 1).trim()
            .replaceAll('"', '')
            .replaceAll(',', '');

        if (value.isNotEmpty && value != 'null' && value != 'not found') {
          result[key] = value;
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Scanner',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                if (_selectedImage != null) ...[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _captureDocument,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _selectFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('From Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_isProcessing) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                ],

                if (_status.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _status.contains('error') || _status.contains('Error')
                          ? Colors.red[50]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _status.contains('error') || _status.contains('Error')
                            ? Colors.red[200]!
                            : Colors.blue[200]!,
                      ),
                    ),
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: _status.contains('error') || _status.contains('Error')
                            ? Colors.red[700]
                            : Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}