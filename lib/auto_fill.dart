import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:vertexaitesting/provider/ai_provider.dart';
import 'package:vertexaitesting/vertexai.dart'; // Assuming this provides DocumentScannerWidget

class AutoFillFormScreen extends StatefulWidget {
  const AutoFillFormScreen({Key? key}) : super(key: key);

  @override
  State<AutoFillFormScreen> createState() => _AutoFillFormScreenState();
}

class _AutoFillFormScreenState extends State<AutoFillFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Old Text editing controllers (keeping them for reference of previous prompt's structure)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _organizationController = TextEditingController();
  final _positionController = TextEditingController();

  // New Text editing controllers based on the new JSON structure
  // Company Details
  final _companyNameController = TextEditingController();
  final _headquartersController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneNumbersController =
      TextEditingController(); // Join multiple numbers
  final _companyMobileNumberController = TextEditingController();

  // Customer Details
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerFaxController = TextEditingController();
  final _customerEmailController = TextEditingController();

  // Document Details
  final _documentTypeController = TextEditingController();
  final _voucherNoController = TextEditingController();
  final _documentDateController = TextEditingController();
  final _bookingNoController = TextEditingController();
  final _bookingDateController = TextEditingController();

  // Payment Details
  final _paymentModeController = TextEditingController();
  final _currencyController = TextEditingController();
  final _conversionRateController = TextEditingController();

  // Summary Amounts
  final _advanceAmountPaidNullFsNoAmountController = TextEditingController();
  final _advanceAmountPaidNullFsNoFsNoController = TextEditingController();
  final _advancePaymentController = TextEditingController();
  final _lastPaymentController = TextEditingController();
  final _invoiceValueController = TextEditingController();
  final _loyaltyDiscountController = TextEditingController();
  final _pointRedemptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _subTotalController = TextEditingController();
  final _exciseTaxController = TextEditingController();
  final _vatController = TextEditingController();
  final _withholdingController = TextEditingController();
  final _grandTotalController = TextEditingController();

  // Worded Amount
  final _wordedAmountController = TextEditingController();

  // Preparation/Approval Details
  final _preparedByController = TextEditingController();
  final _preparedDateController = TextEditingController();
  final _checkedByController = TextEditingController();
  final _checkedDateController = TextEditingController();
  final _approvedByController = TextEditingController();
  final _approvedDateController = TextEditingController();

  // Page Number
  final _pageNumberController = TextEditingController();

  // For item_details, we'll store them in a list of maps
  List<Map<String, String>> _itemDetails = [];

  bool _showScanner = true;

  @override
  void dispose() {
    // Dispose old controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _idNumberController.dispose();
    _organizationController.dispose();
    _positionController.dispose();

    // Dispose new controllers
    _companyNameController.dispose();
    _headquartersController.dispose();
    _companyAddressController.dispose();
    _companyPhoneNumbersController.dispose();
    _companyMobileNumberController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerPhoneController.dispose();
    _customerFaxController.dispose();
    _customerEmailController.dispose();
    _documentTypeController.dispose();
    _voucherNoController.dispose();
    _documentDateController.dispose();
    _bookingNoController.dispose();
    _bookingDateController.dispose();
    _paymentModeController.dispose();
    _currencyController.dispose();
    _conversionRateController.dispose();
    _advanceAmountPaidNullFsNoAmountController.dispose();
    _advanceAmountPaidNullFsNoFsNoController.dispose();
    _advancePaymentController.dispose();
    _lastPaymentController.dispose();
    _invoiceValueController.dispose();
    _loyaltyDiscountController.dispose();
    _pointRedemptionController.dispose();
    _discountController.dispose();
    _subTotalController.dispose();
    _exciseTaxController.dispose();
    _vatController.dispose();
    _withholdingController.dispose();
    _grandTotalController.dispose();
    _wordedAmountController.dispose();
    _preparedByController.dispose();
    _preparedDateController.dispose();
    _checkedByController.dispose();
    _checkedDateController.dispose();
    _approvedByController.dispose();
    _approvedDateController.dispose();
    _pageNumberController.dispose();

    super.dispose();
  }

  void _clearForm(BuildContext context,doClearPdf) {
    setState(() {
      // Clear old controllers
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _dobController.clear();
      _idNumberController.clear();
      _organizationController.clear();
      _positionController.clear();

      // Clear new controllers
      _companyNameController.clear();
      _headquartersController.clear();
      _companyAddressController.clear();
      _companyPhoneNumbersController.clear();
      _companyMobileNumberController.clear();
      _customerNameController.clear();
      _customerAddressController.clear();
      _customerPhoneController.clear();
      _customerFaxController.clear();
      _customerEmailController.clear();
      _documentTypeController.clear();
      _voucherNoController.clear();
      _documentDateController.clear();
      _bookingNoController.clear();
      _bookingDateController.clear();
      _paymentModeController.clear();
      _currencyController.clear();
      _conversionRateController.clear();
      _advanceAmountPaidNullFsNoAmountController.clear();
      _advanceAmountPaidNullFsNoFsNoController.clear();
      _advancePaymentController.clear();
      _lastPaymentController.clear();
      _invoiceValueController.clear();
      _loyaltyDiscountController.clear();
      _pointRedemptionController.clear();
      _discountController.clear();
      _subTotalController.clear();
      _exciseTaxController.clear();
      _vatController.clear();
      _withholdingController.clear();
      _grandTotalController.clear();
      _wordedAmountController.clear();
      _preparedByController.clear();
      _preparedDateController.clear();
      _checkedByController.clear();
      _checkedDateController.clear();
      _approvedByController.clear();
      _approvedDateController.clear();
      _pageNumberController.clear();

      _itemDetails.clear();
      // Clear item details list
    });
    if(doClearPdf){
      context.read<DocumentAIProvider>().getDocumentPath('');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process form submission
      final formData = {
        // Company Details
        'company_details': {
          'company_name': _companyNameController.text,
          'headquarters': _headquartersController.text,
          'address': _companyAddressController.text,
          'phone_numbers': _companyPhoneNumbersController.text
              .split(', ')
              .map((e) => e.trim())
              .toList(),
          'mobile_number': _companyMobileNumberController.text,
        },
        // Customer Details
        'customer_details': {
          'customer_name': _customerNameController.text,
          'customer_address': _customerAddressController.text,
          'customer_phone': _customerPhoneController.text,
          'customer_fax': _customerFaxController.text,
          'customer_email': _customerEmailController.text,
        },
        // Document Details
        'document_details': {
          'document_type': _documentTypeController.text,
          'voucher_no': _voucherNoController.text,
          'date': _documentDateController.text,
          'booking_no': _bookingNoController.text,
          'booking_date': _bookingDateController.text,
        },
        // Payment Details
        'payment_details': {
          'payment_mode': _paymentModeController.text,
          'currency': _currencyController.text,
          'conversion_rate': _conversionRateController.text,
        },
        // Item Details
        'item_details': _itemDetails, // Use the stored list of maps
        // Summary Amounts
        'summary_amounts': {
          // 'advance_amount_paid_null_fs_no': {
          // 'amount': _advanceAmountPaidNullFsNoAmountController.text,
          // 'fs_no': _advanceAmountPaidNullFsNoFsNoController.text,
          // },
          // 'advance_payment': _advancePaymentController.text,
          // 'last_payment': _lastPaymentController.text,
          // 'invoice_value': _invoiceValueController.text,
          // 'loyalty_discount': _loyaltyDiscountController.text,
          // 'point_redemption': _pointRedemptionController.text,
          // 'discount': _discountController.text,
          'sub_total': _subTotalController.text,
          // 'excise_tax': _exciseTaxController.text,
          'vat': _vatController.text,
          'withholding': _withholdingController.text,
          'grand_total': _grandTotalController.text,
        },
        // // Worded Amount
        // 'worded_amount': _wordedAmountController.text,
        // // Preparation/Approval Details
        // 'prepared_by': _preparedByController.text,
        // 'prepared_date': _preparedDateController.text,
        // 'checked_by': _checkedByController.text,
        // 'checked_date': _checkedDateController.text,
        // 'approved_by': _approvedByController.text,
        // 'approved_date': _approvedDateController.text,
        // // Page Number
        // 'page_number': _pageNumberController.text,
      };

      // You might want to recursively remove empty fields/maps/lists here if desired
      // For simplicity, this example just includes all fields.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted with new structure!'),
          backgroundColor: Colors.blue,
        ),
      );

      print('Form Data: $formData');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Document Form'),
        actions: [
          IconButton(
            icon: Icon(
                _showScanner ? Icons.visibility_off : Icons.document_scanner),
            onPressed: () {
              setState(() {
                _showScanner = !_showScanner;
              });
            },
            tooltip: _showScanner ? 'Hide Scanner' : 'Show Scanner',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Scanner Section
            if (_showScanner) ...[
              // Make sure DocumentScannerWidget's onDataExtracted callback expects a Map<String, dynamic>
              DocumentScannerWidget(
                onDataExtracted:(data){
                  _onDataExtracted(data,context);
                },
              ),
              const SizedBox(height: 24),
            ],
            // Form Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Document Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          TextButton.icon(
                            onPressed: (){
                              _clearForm(context,true);
                              },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Company Details ---
                      _buildSectionTitle(context, 'Company Details'),
                      _buildTextField(_companyNameController, 'Company Name',
                          Icons.business),
                      _buildTextField(_headquartersController, 'Headquarters',
                          Icons.location_city),
                      _buildTextField(_companyAddressController,
                          'Company Address', Icons.location_on,
                          maxLines: 3),
                      _buildTextField(_companyPhoneNumbersController,
                          'Company Phone Numbers', Icons.phone),
                      // _buildTextField(_companyMobileNumberController,
                      //     'Company Mobile Number', Icons.phone_android),

                      const SizedBox(height: 24),

                      // --- Customer Details ---
                      _buildSectionTitle(context, 'Customer Details'),
                      _buildTextField(_customerNameController, 'Customer Name',
                          Icons.person),
                      _buildTextField(_customerAddressController,
                          'Customer Address', Icons.home),
                      _buildTextField(_customerPhoneController,
                          'Customer Phone', Icons.phone),
                      // _buildTextField(
                      //     _customerFaxController, 'Customer Fax', Icons.fax),
                      // _buildTextField(_customerEmailController,
                      //     'Customer Email', Icons.email),

                      const SizedBox(height: 24),

                      // --- Document Details ---
                      _buildSectionTitle(context, 'Document Details'),
                      // _buildTextField(_documentTypeController, 'Document Type',
                      //     Icons.description),
                      _buildTextField(
                          _voucherNoController, 'Invoice No.', Icons.numbers),
                      _buildTextField(_documentDateController, 'Date',
                          Icons.calendar_today,
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _documentDateController)),
                      // _buildTextField(_bookingNoController, 'Booking No.',
                      //     Icons.confirmation_number),
                      // _buildTextField(
                      //     _bookingDateController, 'Booking Date', Icons.event,
                      //     readOnly: true,
                      //     onTap: () =>
                      //         _selectDate(context, _bookingDateController)),

                      const SizedBox(height: 24),

                      // --- Payment Details ---
                      // _buildSectionTitle(context, 'Payment Details'),
                      // _buildTextField(_paymentModeController, 'Payment Mode',
                      //     Icons.payment),
                      // _buildTextField(_currencyController, 'Currency',
                      //     Icons.currency_exchange),
                      // _buildTextField(_conversionRateController,
                      //     'Conversion Rate', Icons.transform),

                      const SizedBox(height: 24),

                      // --- Item Details ---
                      _buildSectionTitle(context, 'Item Details'),
                      if (_itemDetails.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No item details extracted.'),
                        )
                      else
                        ..._itemDetails.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, String> item = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Item ${index + 1}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Sr. No: ${item['sr_no'] ?? ''}'),
                                  Text('Code: ${item['item_code'] ?? ''}'),
                                  Text(
                                      'Description: ${item['description'] ?? ''}'),
                                  Text(
                                      'Qty: ${item['quantity'] ?? ''} ${item['unit'] ?? ''}'),
                                  Text(
                                      'Unit Price: ${item['unit_price'] ?? ''}'),
                                  Text('Total: ${item['total'] ?? ''}'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                      const SizedBox(height: 24),

                      // --- Summary Amounts ---
                      _buildSectionTitle(context, 'Summary Amounts'),
                      // _buildTextField(_advanceAmountPaidNullFsNoAmountController, 'Advance Amount (Null FS No.)', Icons.money),
                      // _buildTextField(_advanceAmountPaidNullFsNoFsNoController, 'Advance FS No.', Icons.document_scanner),
                      // _buildTextField(_advancePaymentController, 'Advance Payment', Icons.money),
                      // _buildTextField(_lastPaymentController, 'Last Payment', Icons.money),
                      // _buildTextField(_invoiceValueController, 'Invoice Value', Icons.money),
                      // _buildTextField(_loyaltyDiscountController, 'Loyalty Discount', Icons.discount),
                      // _buildTextField(_pointRedemptionController, 'Point Redemption', Icons.star),
                      // _buildTextField(_discountController, 'Discount', Icons.discount),
                      // _buildTextField(
                      //     _subTotalController, 'Sub Total', Icons.payments),
                      // _buildTextField(_exciseTaxController, 'Excise Tax', Icons.attach_money),
                      _buildTextField(_vatController, 'VAT', Icons.percent),
                      _buildTextField(_withholdingController, 'With-Holding', Icons.money_off),
                      _buildTextField(_grandTotalController, 'Grand Total',
                          Icons.currency_bitcoin),

                      // const SizedBox(height: 24),

                      // --- Worded Amount ---
                      // _buildSectionTitle(context, 'Worded Amount'),
                      // _buildTextField(_wordedAmountController, 'Amount in Words', Icons.spellcheck, maxLines: 3),

                      // const SizedBox(height: 24),

                      // --- Preparation/Approval Details ---
                      // _buildSectionTitle(context, 'Preparation & Approval'),
                      // _buildTextField(_preparedByController, 'Prepared By', Icons.person_outline),
                      // _buildTextField(_preparedDateController, 'Prepared Date', Icons.date_range),
                      // _buildTextField(_checkedByController, 'Checked By', Icons.person_outline),
                      // _buildTextField(_checkedDateController, 'Checked Date', Icons.date_range),
                      // _buildTextField(_approvedByController, 'Approved By', Icons.person_outline),
                      // _buildTextField(_approvedDateController, 'Approved Date', Icons.date_range),

                      // const SizedBox(height: 24),

                      // --- Page Number ---
                      // _buildSectionTitle(context, 'Page Information'),
                      // _buildTextField(_pageNumberController, 'Page Number', Icons.numbers),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit Form',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12,),
            if (context.watch<DocumentAIProvider>().documentPath.isNotEmpty) ...[
              Card(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: PDFView(
                      filePath: context.watch<DocumentAIProvider>().documentPath,
                      enableSwipe: true,
                      fitEachPage: true,
                      fitPolicy: FitPolicy.BOTH,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: false,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onDataExtracted(Map<String, dynamic> data,BuildContext context) {
    // Changed to dynamic to handle nested maps and lists
    print("data__ " + data.toString());
    setState(() {
      // Clear previous data
      _clearForm(context,false);
      try {
        Map<String, dynamic> company_details = data['company_details'];

        // Populate Company Details
        if (data.containsKey('company_details')) {
          _companyNameController.text = company_details['company_name'] ?? '';
          _headquartersController.text = company_details['headquarters'] ?? '';
          _companyAddressController.text = company_details['address'] ?? '';
          if (data['company_details']['phone_numbers'] is List) {
            _companyPhoneNumbersController.text =
                (company_details['phone_numbers'] as List).join(', ');
          }
          _companyMobileNumberController.text =
              company_details['mobile_number'] ?? '';
        }

        // Populate Customer Details
        if (data.containsKey('customer_details')) {
          _customerNameController.text =
              data['customer_details']['customer_name'] ?? '';
          _customerAddressController.text =
              data['customer_details']['customer_address'] ?? '';
          _customerPhoneController.text =
              data['customer_details']['customer_phone'] ?? '';
          _customerFaxController.text =
              data['customer_details']['customer_fax'] ?? '';
          _customerEmailController.text =
              data['customer_details']['customer_email'] ?? '';
        }

        // Populate Document Details
        if (data.containsKey('document_details')) {
          _documentTypeController.text =
              data['document_details']['document_type'] ?? '';
          _voucherNoController.text =
              data['document_details']['voucher_no'] ?? '';
          _documentDateController.text = data['document_details']['date'] ?? '';
          _bookingNoController.text =
              data['document_details']['booking_no'] ?? '';
          _bookingDateController.text =
              data['document_details']['booking_date'] ?? '';
        }

        // Populate Payment Details
        if (data.containsKey('payment_details')) {
          _paymentModeController.text =
              data['payment_details']['payment_mode'] ?? '';
          _currencyController.text = data['payment_details']['currency'] ?? '';
          _conversionRateController.text =
              data['payment_details']['conversion_rate'] ?? '';
        }

        // Populate Item Details
        if (data.containsKey('item_details') && data['item_details'] is List) {
          _itemDetails = List<Map<String, String>>.from(data['item_details']
              .map((item) => Map<String, String>.from(item)));
        }

        // Populate Summary Amounts
        if (data.containsKey('summary_amounts')) {
          if (data['summary_amounts']
              .containsKey('advance_amount_paid_null_fs_no')) {
            _advanceAmountPaidNullFsNoAmountController.text =
                data['summary_amounts']['advance_amount_paid_null_fs_no']
                        ['amount'] ??
                    '';
            _advanceAmountPaidNullFsNoFsNoController.text =
                data['summary_amounts']['advance_amount_paid_null_fs_no']
                        ['fs_no'] ??
                    '';
          }
          _advancePaymentController.text =
              data['summary_amounts']['advance_payment'] ?? '';
          _lastPaymentController.text =
              data['summary_amounts']['last_payment'] ?? '';
          _invoiceValueController.text =
              data['summary_amounts']['invoice_value'] ?? '';
          _loyaltyDiscountController.text =
              data['summary_amounts']['loyalty_discount'] ?? '';
          _pointRedemptionController.text =
              data['summary_amounts']['point_redemption'] ?? '';
          _discountController.text = data['summary_amounts']['discount'] ?? '';
          _subTotalController.text = data['summary_amounts']['sub_total'] ?? '';
          _exciseTaxController.text =
              data['summary_amounts']['excise_tax'] ?? '';
          _vatController.text = data['summary_amounts']['vat'] ?? '';
          _withholdingController.text =
              data['summary_amounts']['withholding'] ?? '';
          _grandTotalController.text =
              data['summary_amounts']['grand_total'] ?? '';
          // Corrected: Populate Worded Amount from within summary_amounts
          _wordedAmountController.text =
              data['summary_amounts']['worded_amount'] ?? '';
        }

        // Corrected: Populate Preparation/Approval Details from the nested map
        if (data.containsKey('Preparation/Approval Details')) {
          // Use the exact key from JSON
          _preparedByController.text =
              data['Preparation/Approval Details']['prepared_by'] ?? '';
          _preparedDateController.text =
              data['Preparation/Approval Details']['prepared_date'] ?? '';
          _checkedByController.text =
              data['Preparation/Approval Details']['checked_by'] ?? '';
          _checkedDateController.text =
              data['Preparation/Approval Details']['checked_date'] ?? '';
          _approvedByController.text =
              data['Preparation/Approval Details']['approved_by'] ?? '';
          _approvedDateController.text =
              data['Preparation/Approval Details']['approved_date'] ?? '';
        }

        // Populate Page Number
        _pageNumberController.text =
            data['Page Number'] ?? ''; // Use the exact key from JSON

        _showScanner = false;
      } on Exception catch (e) {
        log("exception__ " + e.toString());
      }
      // Hide scanner after successful extraction
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form auto-filled with new JSON structure!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now()
          .add(const Duration(days: 365 * 10)), // 10 years in the future
    );
    if (date != null) {
      controller.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
