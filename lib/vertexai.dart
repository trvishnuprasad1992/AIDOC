import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';

import 'package:vertexaitesting/provider/ai_provider.dart';

class DocumentScannerWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataExtracted;

  const DocumentScannerWidget({Key? key, required this.onDataExtracted})
      : super(key: key);

  @override
  State<DocumentScannerWidget> createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  ImagePicker _picker = ImagePicker();
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
    _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash');
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
          _status = 'PDF captured, processing...';
        });
        await _processDocument();
      }
    } catch (e) {
      setState(() {
        _status = 'Error capturing image: $e';
      });
    }
  }

  Future<void> _selectFromGallery(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _selectedImage =  File(result.files.single.path!);
          context.read<DocumentAIProvider>().getDocumentPath(result.files.single.path!??"");
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

  Future<Map<String, dynamic>> _processImageDirectly() async {
    setState(() {
      _status = 'Analyzing document with AI...';
    });

    // Read image bytes
    final imageBytes = await _selectedImage!.readAsBytes();

    // Create the prompt for document data extraction
    const prompt = '''
    "Extract all key-value pairs from the provided PDF document based on the following JSON structure. For each field, identify the corresponding text in the document and populate its value.

     Extraction Rules:
     
     company_details:
     company_name: Extract the primary company name located at the top-left/top-right.
     headquarters: second line after company_name.
     address: Capture the complete geographical address associated with the company.
     phone_numbers: Extract all listed phone numbers, including landline and mobile.
     mobile_number: Specifically identify the mobile number if distinct from general phone numbers.
     customer_details:
     customer_name: Find the name of the "Motors Industry" entity.
     customer_address: Extract the address associated with the customer.
     customer_phone: Get the telephone number for the customer.
     customer_fax: Extract the fax number if present.
     customer_email: Extract the email address if present.
     document_details:
     document_type: Identify the main title indicating the nature of the document.
     voucher_no: Extract the invoice number/ voucher number.
     date: Extract the "Date" in YYYY-MM-DD format.
     booking_no: Extract the "Booking No." value if present.
     booking_date: Extract the "Booking Date" if present.
     payment_details:
     payment_mode: Extract the "PAYMENT MODE".
     currency: Extract the "CURRENCY".
     conversion_rate: Extract the "Conv Rate" value.
     item_details:
     For each row in the item table:
     sr_no: Extract the serial number.
     item_code: Extract the item code.
     description: Extract the full item description/name.
     quantity: Extract the quantity.
     unit: Extract the unit of measurement.
     unit_price: Extract the unit price/rate.
     total: Extract the total for the item.
     summary_amounts:
     advance_amount_paid_null_fs_no:
     amount: Extract the numerical value for the "Advance amount paid on null with FS No.".
     fs_no: Extract the FS No. associated with the advance amount.
     advance_payment: Extract the "Advance Payment" value.
     last_payment: Extract the "Last Payment" value.
     invoice_value: Extract the "Invoice Value".
     loyalty_discount: Extract the "Loyalty Discount" value.
     point_redemption: Extract the "Point Redumption" value.
     discount: Extract the "Discount" value.
     sub_total: Extract the sub total/total value.
     excise_tax: Extract the "Excise Tax" value.
     vat: Extract the "VAT" value if it empty put "0".
     withholding: Extract the "With-Holding" value if it empty put "0".
     grand_total: Extract the "Grand Total/Total" value.
     worded_amount: Extract the amount spelled out in words.
     Preparation/Approval Details:
     prepared_by: Extract the name next to "Prepared By".
     prepared_date: Extract the date and time next to "Prepared Date" in YYYY-MM-DD HH:MM:SS format.
     checked_by: Extract the name next to "Checked By".
     checked_date: Extract the date next to "Checked Date" if present.
     approved_by: Extract the name next to "Approved By".
     approved_date: Extract the date and time next to "Approved Date" in YYYY-MM-DD HH:MM:SS format.
     Page Number: Extract the page number information (e.g., "Page 1/1").
     Output Format:
     
     Output Format:
     Give opening and closing quotes for all the tags and values.
     Return the extracted information as a JSON object, strictly following the provided structure.
     Ensure all monetary values are extracted as numerical strings (e.g., "2,331,516.09").
     Dates should be formatted as "YYYY-MM-DD" and datetimes as "YYYY-MM-DD HH:MM:SS".
     If a field is not found in the document, populate its value with an empty string "" or an empty array [] for lists, as appropriate.
      
      
    ''';

    final imagePart = InlineDataPart("application/pdf", imageBytes);
    try {
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          imagePart,
        ])
      ]);

      final responseText = response.text?.trim() ?? '';

      // Try to parse as JSON
      Map<String, dynamic> extractedData = {};

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
        Map<String,dynamic> parsed = jsonDecode(cleanJson);
        extractedData = parsed;
      } catch (e) {
        log("Exception $e");

      }

      return extractedData;
    } catch (e) {
      throw Exception('Vertex AI processing failed: $e');
    }
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

                Row(
                  children: [
                    // Expanded(
                    //   child: ElevatedButton.icon(
                    //     onPressed: _isProcessing ? null : _captureDocument,
                    //     icon: const Icon(Icons.camera_alt),
                    //     label: const Text('Take Photo'),
                    //     style: ElevatedButton.styleFrom(
                    //       padding: const EdgeInsets.symmetric(vertical: 12),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null :(){
                          _selectFromGallery(context);
                        },
                        icon: const Icon(Icons.file_copy_outlined),
                        label: const Text('From Files'),
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
                      color:
                          _status.contains('error') || _status.contains('Error')
                              ? Colors.red[50]
                              : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _status.contains('error') ||
                                _status.contains('Error')
                            ? Colors.red[200]!
                            : Colors.blue[200]!,
                      ),
                    ),
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: _status.contains('error') ||
                                _status.contains('Error')
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

        ]

    );
  }
}
