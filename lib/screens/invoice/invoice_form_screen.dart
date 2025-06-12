import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/invoice/invoice_item_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/invoice_status.dart';
import '../../models/invoice/invoice_type.dart';
import '../../services/auth/auth_service.dart';
import '../../services/invoice/invoice_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/gstin_validator.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/invoice/invoice_item_form.dart';

class InvoiceFormScreen extends StatefulWidget {
  final Invoice? invoice;
  
  const InvoiceFormScreen({
    Key? key,
    this.invoice,
  }) : super(key: key);

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceService = InvoiceService();
  final _authService = AuthService();
  
  // Controllers for invoice details
  final _invoiceNumberController = TextEditingController();
  final _invoiceDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerGstinController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerStateController = TextEditingController();
  final _customerStateCodeController = TextEditingController();
  final _placeOfSupplyController = TextEditingController();
  final _placeOfSupplyCodeController = TextEditingController();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();
  
  // Invoice type and status
  InvoiceType _invoiceType = InvoiceType.sales;
  InvoiceStatus _invoiceStatus = InvoiceStatus.draft;
  
  // Invoice items
  List<InvoiceItem> _items = [];
  
  // Flags
  bool _isReverseCharge = false;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Calculated totals
  double _subtotal = 0.0;
  double _cgstTotal = 0.0;
  double _sgstTotal = 0.0;
  double _igstTotal = 0.0;
  double _cessTotal = 0.0;
  double _totalTax = 0.0;
  double _grandTotal = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    // Set default dates
    final now = DateTime.now();
    _invoiceDateController.text = DateFormat('dd/MM/yyyy').format(now);
    _dueDateController.text = DateFormat('dd/MM/yyyy').format(now.add(const Duration(days: 30)));
    
    // If editing an existing invoice, populate the form
    if (widget.invoice != null) {
      _populateForm();
    } else {
      // Generate a new invoice number
      _generateInvoiceNumber();
    }
  }
  
  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _invoiceDateController.dispose();
    _dueDateController.dispose();
    _customerNameController.dispose();
    _customerGstinController.dispose();
    _customerAddressController.dispose();
    _customerStateController.dispose();
    _customerStateCodeController.dispose();
    _placeOfSupplyController.dispose();
    _placeOfSupplyCodeController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }
  
  void _populateForm() {
    final invoice = widget.invoice!;
    
    _invoiceNumberController.text = invoice.invoiceNumber;
    _invoiceDateController.text = DateFormat('dd/MM/yyyy').format(invoice.invoiceDate);
    _dueDateController.text = DateFormat('dd/MM/yyyy').format(invoice.dueDate);
    _customerNameController.text = invoice.customerName;
    _customerGstinController.text = invoice.customerGstin;
    _customerAddressController.text = invoice.customerAddress;
    _customerStateController.text = invoice.customerState;
    _customerStateCodeController.text = invoice.customerStateCode.toString();
    _placeOfSupplyController.text = invoice.placeOfSupply;
    _placeOfSupplyCodeController.text = invoice.placeOfSupplyCode.toString();
    _notesController.text = invoice.notes;
    _termsController.text = invoice.termsAndConditions;
    
    _invoiceType = invoice.invoiceType;
    _invoiceStatus = invoice.status;
    _isReverseCharge = invoice.isReverseCharge;
    
    _items = List.from(invoice.items);
    
    _updateTotals();
  }
  
  Future<void> _generateInvoiceNumber() async {
    final nextNumber = await _invoiceService.getNextInvoiceNumber();
    _invoiceNumberController.text = nextNumber;
  }
  
  void _updateTotals() {
    double subtotal = 0.0;
    double cgstTotal = 0.0;
    double sgstTotal = 0.0;
    double igstTotal = 0.0;
    double cessTotal = 0.0;
    
    for (var item in _items) {
      subtotal += item.totalBeforeTax;
      cgstTotal += item.cgstAmount;
      sgstTotal += item.sgstAmount;
      igstTotal += item.igstAmount;
      cessTotal += item.cessAmount;
    }
    
    setState(() {
      _subtotal = subtotal;
      _cgstTotal = cgstTotal;
      _sgstTotal = sgstTotal;
      _igstTotal = igstTotal;
      _cessTotal = cessTotal;
      _totalTax = cgstTotal + sgstTotal + igstTotal + cessTotal;
      _grandTotal = subtotal + _totalTax;
    });
  }
  
  Future<void> _selectDate(TextEditingController controller) async {
    final initialDate = controller.text.isNotEmpty
        ? DateFormat('dd/MM/yyyy').parse(controller.text)
        : DateTime.now();
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }
  
  void _addItem() {
    final isInterState = _placeOfSupplyCodeController.text != _customerStateCodeController.text;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InvoiceItemForm(
        isInterState: isInterState,
        onSave: (item) {
          setState(() {
            _items.add(item);
            _updateTotals();
          });
        },
      ),
    );
  }
  
  void _editItem(int index) {
    final isInterState = _placeOfSupplyCodeController.text != _customerStateCodeController.text;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InvoiceItemForm(
        item: _items[index],
        isInterState: isInterState,
        onSave: (item) {
          setState(() {
            _items[index] = item;
            _updateTotals();
          });
        },
      ),
    );
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _updateTotals();
    });
  }
  
  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_items.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one item to the invoice';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final invoiceDate = DateFormat('dd/MM/yyyy').parse(_invoiceDateController.text);
      final dueDate = DateFormat('dd/MM/yyyy').parse(_dueDateController.text);
      
      final invoice = Invoice.create(
        invoiceNumber: _invoiceNumberController.text,
        invoiceDate: invoiceDate,
        dueDate: dueDate,
        customerName: _customerNameController.text,
        customerGstin: _customerGstinController.text,
        customerAddress: _customerAddressController.text,
        customerState: _customerStateController.text,
        customerStateCode: int.parse(_customerStateCodeController.text),
        placeOfSupply: _placeOfSupplyController.text,
        placeOfSupplyCode: int.parse(_placeOfSupplyCodeController.text),
        invoiceType: _invoiceType,
        items: _items,
        notes: _notesController.text,
        termsAndConditions: _termsController.text,
        isReverseCharge: _isReverseCharge,
        createdBy: _authService.getUserId() ?? '',
      );
      
      if (widget.invoice != null) {
        // Update existing invoice
        await _invoiceService.updateInvoice(invoice.copyWith(
          id: widget.invoice!.id,
          createdAt: widget.invoice!.createdAt,
          status: _invoiceStatus,
        ));
      } else {
        // Create new invoice
        await _invoiceService.createInvoice(invoice);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice != null ? 'Edit Invoice' : 'Create Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveInvoice,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.red.shade100,
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  
                  // Form fields
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Invoice details section
                          _buildSectionTitle('Invoice Details'),
                          const SizedBox(height: 16),
                          
                          // Invoice type
                          DropdownButtonFormField<InvoiceType>(
                            value: _invoiceType,
                            decoration: InputDecoration(
                              labelText: 'Invoice Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            items: InvoiceType.values.map((type) {
                              return DropdownMenuItem<InvoiceType>(
                                value: type,
                                child: Text(_getInvoiceTypeText(type)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _invoiceType = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Invoice status (only for editing)
                          if (widget.invoice != null) ...[
                            DropdownButtonFormField<InvoiceStatus>(
                              value: _invoiceStatus,
                              decoration: InputDecoration(
                                labelText: 'Invoice Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              items: InvoiceStatus.values.map((status) {
                                return DropdownMenuItem<InvoiceStatus>(
                                  value: status,
                                  child: Text(_getInvoiceStatusText(status)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _invoiceStatus = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Invoice number
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _invoiceNumberController,
                                  labelText: 'Invoice Number',
                                  hintText: 'Enter invoice number',
                                  prefixIcon: Icons.receipt,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter invoice number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (widget.invoice == null) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _generateInvoiceNumber,
                                  tooltip: 'Generate invoice number',
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Invoice date and due date
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _invoiceDateController,
                                  labelText: 'Invoice Date',
                                  hintText: 'DD/MM/YYYY',
                                  prefixIcon: Icons.calendar_today,
                                  readOnly: true,
                                  onTap: () => _selectDate(_invoiceDateController),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select invoice date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _dueDateController,
                                  labelText: 'Due Date',
                                  hintText: 'DD/MM/YYYY',
                                  prefixIcon: Icons.calendar_today,
                                  readOnly: true,
                                  onTap: () => _selectDate(_dueDateController),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select due date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Reverse charge
                          CheckboxListTile(
                            title: const Text('Reverse Charge'),
                            value: _isReverseCharge,
                            onChanged: (value) {
                              setState(() {
                                _isReverseCharge = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 16),
                          
                          // Customer details section
                          _buildSectionTitle('Customer Details'),
                          const SizedBox(height: 16),
                          
                          // Customer name
                          CustomTextField(
                            controller: _customerNameController,
                            labelText: 'Customer Name',
                            hintText: 'Enter customer name',
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Customer GSTIN
                          CustomTextField(
                            controller: _customerGstinController,
                            labelText: 'Customer GSTIN',
                            hintText: 'Enter customer GSTIN',
                            prefixIcon: Icons.numbers,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!GstinValidator.isValid(value)) {
                                  return 'Please enter a valid GSTIN';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Customer address
                          CustomTextField(
                            controller: _customerAddressController,
                            labelText: 'Customer Address',
                            hintText: 'Enter customer address',
                            prefixIcon: Icons.location_on,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Customer state and state code
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller: _customerStateController,
                                  labelText: 'Customer State',
                                  hintText: 'Enter state',
                                  prefixIcon: Icons.location_city,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter state';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _customerStateCodeController,
                                  labelText: 'State Code',
                                  hintText: 'Code',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Place of supply
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller: _placeOfSupplyController,
                                  labelText: 'Place of Supply',
                                  hintText: 'Enter place of supply',
                                  prefixIcon: Icons.location_city,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter place of supply';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _placeOfSupplyCodeController,
                                  labelText: 'Code',
                                  hintText: 'Code',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Items section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('Items'),
                              CustomButton(
                                text: 'Add Item',
                                icon: Icons.add,
                                onPressed: _addItem,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Items list
                          _items.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'No items added yet. Click "Add Item" to add items to the invoice.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _items.length,
                                  itemBuilder: (context, index) {
                                    final item = _items[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit, size: 20),
                                                      onPressed: () => _editItem(index),
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                                      onPressed: () => _removeItem(index),
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (item.description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                item.description,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('HSN/SAC: ${item.hsnSacCode}'),
                                                Text('${item.quantity} ${item.unit} × ₹${NumberFormatter.format(item.unitPrice)}'),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Taxable Value: ₹${NumberFormatter.format(item.taxableValue)}',
                                                ),
                                                Text(
                                                  'Total: ₹${NumberFormatter.format(item.totalAfterTax)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                if (item.cgstRate > 0) ...[
                                                  Text('CGST: ${item.cgstRate}%'),
                                                  const SizedBox(width: 8),
                                                ],
                                                if (item.sgstRate > 0) ...[
                                                  Text('SGST: ${item.sgstRate}%'),
                                                  const SizedBox(width: 8),
                                                ],
                                                if (item.igstRate > 0) ...[
                                                  Text('IGST: ${item.igstRate}%'),
                                                  const SizedBox(width: 8),
                                                ],
                                                if (item.cessRate > 0) ...[
                                                  Text('Cess: ${item.cessRate}%'),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          const SizedBox(height: 24),
                          
                          // Additional details section
                          _buildSectionTitle('Additional Details'),
                          const SizedBox(height: 16),
                          
                          // Notes
                          CustomTextField(
                            controller: _notesController,
                            labelText: 'Notes',
                            hintText: 'Enter notes (optional)',
                            prefixIcon: Icons.note,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          // Terms and conditions
                          CustomTextField(
                            controller: _termsController,
                            labelText: 'Terms and Conditions',
                            hintText: 'Enter terms and conditions (optional)',
                            prefixIcon: Icons.description,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // Summary section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('₹${NumberFormatter.format(_subtotal)}'),
                          ],
                        ),
                        if (_cgstTotal > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('CGST:'),
                              Text('₹${NumberFormatter.format(_cgstTotal)}'),
                            ],
                          ),
                        ],
                        if (_sgstTotal > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('SGST:'),
                              Text('₹${NumberFormatter.format(_sgstTotal)}'),
                            ],
                          ),
                        ],
                        if (_igstTotal > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('IGST:'),
                              Text('₹${NumberFormatter.format(_igstTotal)}'),
                            ],
                          ),
                        ],
                        if (_cessTotal > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Cess:'),
                              Text('₹${NumberFormatter.format(_cessTotal)}'),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₹${NumberFormatter.format(_grandTotal)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: widget.invoice != null ? 'Update Invoice' : 'Save Invoice',
                          icon: Icons.save,
                          onPressed: _saveInvoice,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  String _getInvoiceTypeText(InvoiceType type) {
    switch (type) {
      case InvoiceType.sales:
        return 'Sales Invoice';
      case InvoiceType.purchase:
        return 'Purchase Invoice';
      case InvoiceType.creditNote:
        return 'Credit Note';
      case InvoiceType.debitNote:
        return 'Debit Note';
    }
  }
  
  String _getInvoiceStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.issued:
        return 'Issued';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.voided:
        return 'Void';
    }
  }
}
