import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/constants/discount_constant.dart';
import 'package:e_commerce_app/containers/additional_confirm.dart';
import 'package:e_commerce_app/controllers/db_services.dart';
import 'package:e_commerce_app/models/orders_model.dart';
import 'package:e_commerce_app/models/product_model.dart';
import 'package:e_commerce_app/pdf/api/pdf_api.dart';
import 'package:e_commerce_app/pdf/model/customer.dart';
import 'package:e_commerce_app/pdf/model/invoice.dart';
import 'package:e_commerce_app/pdf/model/supplier.dart';
import 'package:flutter/material.dart';

import '../pdf/api/pdf_invoice_api.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  totalQuantityCalculator(List<OrderProductModel> products) {
    int qty = 0;
    products.map((e) => qty += e.quantity).toList();
    return qty;
  }

  Widget statusIcon(String status) {
    if (status == 'PAID') {
      return statusContainer(
          text: "PAID", textColor: Colors.white, bgColor: Colors.green);
    }
    if (status == 'ON_THE_WAY') {
      return statusContainer(
          text: "ON_THE_WAY", textColor: Colors.white, bgColor: Colors.yellow);
    } else if (status == "DELIVERED") {
      return statusContainer(
          text: "DELIVERED",
          textColor: Colors.green.shade500,
          bgColor: Colors.black);
    } else {
      return statusContainer(
          text: "CANCELLED", textColor: Colors.white, bgColor: Colors.red);
    }
  }

  Widget statusContainer(
      {required String text,
      required Color textColor,
      required Color bgColor}) {
    return Container(
      color: bgColor,
      child: FittedBox(
          child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 18),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: StreamBuilder(
          stream: DbServices().readOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<OrdersModel> orders =
                  OrdersModel.fromJsonList(snapshot.data!.docs);
              if (orders.isEmpty) {
                return const Center(
                  child: Text('Not Found Orders'),
                );
              } else {
                return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, "/view_order",
                              arguments: orders[index]);
                        },
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AdditionalConfirm(
                                    title:
                                        'You want to Delete order from order list',
                                    onYes: () async {
                                      await DbServices().deleteOrder(
                                          orderId: orders[index].id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Order Deleted Successfully')));
                                    },
                                    onNo: () {
                                      Navigator.pop(context);
                                    });
                              });
                          Navigator.pop(context);
                        },
                        title: Text(
                            '${totalQuantityCalculator(orders[index].products)} Items worth ₹${orders[index].total}'),
                        subtitle: Text(
                            "Ordered on ${DateTime.fromMillisecondsSinceEpoch(orders[index].createdAt).toString()}"),
                        trailing: statusIcon(orders[index].status),
                      );
                    });
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

class ViewOrder extends StatefulWidget {
  const ViewOrder({super.key});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as OrdersModel;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Summary"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Delivery Details
              buildDeliveryDetails(args),
              //Products Details
              buildProductsDetails(args),
              buildPaymentSummary(args),
              args.status == "PAID" || args.status == "ON_THE_WAY"
                  ? SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width * .9,
                      child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ModifyOrder(
                                    order: args,
                                  );
                                });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white),
                          child: const Text('Modify Order')))
                  : args.status == "DELIVERED"
                      ? SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width * .9,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white),
                              onPressed: () async{
                                final date=DateTime.now();
                                final dueDate=date.add(const Duration(days: 7));
                                final invoice = Invoice(
                                    customer: Customer(args.name, args.address),
                                    supplier: Supplier(name: "Supplier", address: 'Supplier Address', paymentInfo: 'paymentInfo'),
                                    info: InvoiceInfo(description: 'description', number: '${DateTime.now().year}-9999', date: date, dueDate: dueDate),

                                    items:args.products.map((product)=>InvoiceItem(
                                        description: product.name.substring(0,15),
                                        date: date, quantity: product.quantity,
                                        vat: args.discount,
                                        unitPrice: product.singlePrice.toDouble())).toList(),
                                  order: args
                                );
                                final pdfFile= await PdfInvoiceApi.generate(invoice);
                                PdfApi.openFile(pdfFile);
                              },
                              child: const Text('Invoice PDF')),
                        )
                      : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentSummary(OrdersModel args) {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                args.discount == 0
                    ? const SizedBox()
                    : Text(
                        "Discount: -₹${args.discount}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                Text(
                  "Status: ${args.status}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  "Total Price: ₹${args.total}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            );
  }

  Widget buildProductsDetails(OrdersModel args) {
    return Column(
              children: args.products
                  .map((e) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                    height: 50,
                                    width: 50,
                                    padding: const EdgeInsets.all(4),
                                    child: CachedNetworkImage(
                                        imageUrl: e.image)),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(child: Text(e.name))
                              ],
                            ),
                            Text(
                              "₹${e.singlePrice.toString()} x ${e.quantity.toString()} Quantity",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "₹${e.totalPrice.toString()}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            );
  }

  Widget buildDeliveryDetails(OrdersModel args) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Delivery Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Id: ${args.id}'),
                      Text(
                          'Order on: ${DateTime.fromMillisecondsSinceEpoch(args.createdAt).toString()}'),
                      Text('Order By: ${args.name}'),
                      Text('Order Id: ${args.email}'),
                      Text('Phone No: ${args.phone}'),
                      Text('Delivery Address: ${args.address}'),
                    ],
                  ),
                ),
      ],
    );
  }
}

class ModifyOrder extends StatefulWidget {
  final OrdersModel order;
  const ModifyOrder({super.key, required this.order});

  @override
  State<ModifyOrder> createState() => _ModifyOrderState();
}

class _ModifyOrderState extends State<ModifyOrder> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings as OrdersModel;
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_outlined),
              )
            ],
          ),
          const Text(
            'Are you Sure?',
            style: TextStyle(fontSize: 20),
          ),
          const Text(
            'You want to Cancel Order',
            style: TextStyle(color: Colors.red),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) {
                      return AdditionalConfirm(
                          title:
                              'After cancelling this cannot be changed you need to order again',
                          onYes: () async {
                            await DbServices().updateOrderStatus(
                                docId: widget.order.id,
                                data: {"status": "CANCELLED"});
                            Navigator.pop(context);
                          },
                          onNo: () {
                            Navigator.pop(context);
                          });
                    });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Cancel Order'))
        ],
      ),
    );
  }
}
