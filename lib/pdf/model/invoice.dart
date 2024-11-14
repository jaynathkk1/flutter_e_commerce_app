import 'package:e_commerce_app/models/orders_model.dart';
import 'package:e_commerce_app/pdf/model/supplier.dart';

import 'customer.dart';

class Invoice{
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final OrdersModel order;
  final List<InvoiceItem> items;

  Invoice({required this.order,
    required this.customer,required this.supplier,required this.info, required this.items});
}

class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final double vat;
  final double unitPrice;

  InvoiceItem({required this.description, required this.date, required this.quantity, required this.vat, required this.unitPrice});
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  InvoiceInfo({required this.description, required this.number, required this.date, required this.dueDate});
}