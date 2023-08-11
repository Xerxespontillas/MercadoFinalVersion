import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrgFarmerCompletedOrders extends StatefulWidget {
  const OrgFarmerCompletedOrders({Key? key}) : super(key: key);
  static const routeName = '/organization-completed-orders';

  @override
  State<OrgFarmerCompletedOrders> createState() =>
      _OrgFarmerCompletedOrdersState();
}

class _OrgFarmerCompletedOrdersState extends State<OrgFarmerCompletedOrders> {
  final TextEditingController _datePickerController = TextEditingController();
  DateTime _chosenDate = DateTime.now();
  // ignore: unused_field
  QuerySnapshot? _snapshotData;
  double _totalEarnings = 0.0; // Added this variable

  @override
  void initState() {
    super.initState();
    _datePickerController.text =
        DateFormat('MMMM, dd, yyyy').format(_chosenDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _calculateTotalEarnings here
    _calculateTotalEarnings();
  }

  @override
  void dispose() {
    _datePickerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _chosenDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _chosenDate) {
      setState(() {
        _chosenDate = picked;
        _datePickerController.text =
            DateFormat('MMMM, dd, yyyy').format(_chosenDate);
        // Calculate and update the total earnings whenever the date changes
        _calculateTotalEarnings();
      });
    }
  }

  String formatDateForFirestore(DateTime date) {
    return DateFormat('MMMM, dd, yyyy').format(date);
  }

  void _calculateTotalEarnings() {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    final displayName = ModalRoute.of(context)?.settings.arguments as String;

    FirebaseFirestore.instance
        .collection('organizations')
        .doc(userId)
        .collection('customerOrders')
        .where('orderCompleted', isEqualTo: true)
        .where('date', isEqualTo: formatDateForFirestore(_chosenDate))
        .get()
        .then((snapshot) {
      double totalEarnings = snapshot.docs.fold(
        0.0,
        (total, order) {
          var items = order['items'];
          var deliveryFee = 0.0; // Assuming a fixed delivery fee

          var filteredItems = items.where(
            (item) => item['productSeller'] == displayName,
          );

          if (filteredItems.isEmpty) {
            return total;
          }

          return total +
              filteredItems.fold(
                0.0,
                (subTotal, item) {
                  var itemSubtotal =
                      item['productPrice'] * item['productQuantity'];
                  var discountPercent = int.parse(item['discount'] ?? '0');
                  var minItems = int.parse(item['minItems'] ?? '0');
                  if (item['productQuantity'] >= minItems) {
                    var discountAmount = itemSubtotal * discountPercent / 100;
                    itemSubtotal -= discountAmount;
                  }
                  return subTotal + itemSubtotal;
                },
              ) +
              deliveryFee;
        },
      );

      setState(() {
        _totalEarnings = totalEarnings;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    final displayName = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        title: const Text(
          'Completed Orders',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('organizations')
                  .doc(userId)
                  .collection('customerOrders')
                  .where('orderCompleted', isEqualTo: true)
                  .where('date', isEqualTo: formatDateForFirestore(_chosenDate))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }

                _snapshotData =
                    snapshot.data; // Save the snapshot data to the variable

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index];
                    var items = order['items'];
                    var deliveryFee = 0.0; // Assuming a fixed delivery fee

                    final bool orderCompleted =
                        order['orderCompleted'] ?? false;
                    final bool orderCancelled =
                        order['orderCancelled'] ?? false;

                    // If both orderCancelled and orderConfirmed are false, don't display the item
                    if (!orderCompleted && !orderCancelled) {
                      return Container();
                    }

                    var filteredItems = items
                        .where((item) => item['productSeller'] == displayName)
                        .toList();

                    if (filteredItems.isEmpty) {
                      return Container();
                    }

                    return Stack(
                      children: [
                        InkWell(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20.0,
                                    ),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Order date: ${order['date']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Text('Order ID: ${order.id}'),
                                  Text('Buyer: ${order['buyerName']}'),
                                  ...filteredItems
                                      .map<Widget>((item) => ListTile(
                                            leading: Image.network(
                                              item['productImage'],
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return const Icon(Icons.error);
                                              },
                                            ),
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item['productName']),
                                              ],
                                            ),
                                            subtitle: Text(
                                                'Price: ${item['productPrice']}'),
                                            trailing: Text(
                                              'Quantity: ${item['productQuantity']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                  Text(
                                    'Delivery Fee: $deliveryFee',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Total Payment: ${filteredItems.fold(0.0, (total, item) {
                                          var itemSubtotal =
                                              item['productPrice'] *
                                                  item['productQuantity'];
                                          var discountPercent = int.parse(
                                              item['discount'] ?? '0');
                                          var minItems = int.parse(
                                              item['minItems'] ?? '0');
                                          if (item['productQuantity'] >=
                                              minItems) {
                                            var discountAmount = itemSubtotal *
                                                discountPercent /
                                                100;
                                            itemSubtotal -= discountAmount;
                                          }
                                          return total + itemSubtotal;
                                        }) + deliveryFee}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _datePickerController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: const InputDecoration(
                labelText: 'Choose Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Total Earnings: ${_totalEarnings.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
