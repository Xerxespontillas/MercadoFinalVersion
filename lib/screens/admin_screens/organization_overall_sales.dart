import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrganizationSalesOverall extends StatefulWidget {
  const OrganizationSalesOverall({Key? key}) : super(key: key);

  @override
  State<OrganizationSalesOverall> createState() =>
      _OrganizationSalesOverallState();
}

class _OrganizationSalesOverallState extends State<OrganizationSalesOverall> {
  double _overallTotalSales = 0;

  bool _isLoaded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(0, 66, 180, 119),
          centerTitle: true,
          title: const Text(
            'Organization Sales',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          )),
      body: _buildOrganizationSales(),
    );
  }

  Widget _buildOrganizationSales() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('organizations')
          .where('isOrgConfirmed', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error fetching data'),
          );
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No confirmed organizations found'),
          );
        }

        if (!_isLoaded) {
          _overallTotalSales = 0; // Reset the overall total sales

          snapshot.data!.docs.forEach((orgDoc) async {
            final orgId = orgDoc.id;
            final orgTotalSales = await _calculateOrganizationSales(orgId);
            setState(() {
              _overallTotalSales += orgTotalSales;
            });
          });

          _isLoaded = true; // Set the flag to true after calculation
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final orgDoc = snapshot.data!.docs[index];
                  final orgId = orgDoc.id;

                  return FutureBuilder<double>(
                    future: _calculateOrganizationSales(orgId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Calculating sales...'),
                        );
                      }

                      if (snapshot.hasError) {
                        return ListTile(
                          title: Text('Error calculating sales'),
                        );
                      }

                      final totalSales = snapshot.data ?? 0;

                      final orgData = orgDoc.data() as Map<String, dynamic>;
                      final orgName =
                          orgData['displayName'] ?? 'Name not available';
                      final orgEmail =
                          orgData['email'] ?? 'Email not available';
                      final orgPhoneNumber = orgData['phoneNumber'] ??
                          'Phone number not available';
                      final orgAddress =
                          orgData['address'] ?? 'Address not available';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orgName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Email: $orgEmail'),
                                  Text('Phone: $orgPhoneNumber'),
                                  Text('Address: $orgAddress'),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Total Sales: ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text(
                                    '₱ ${NumberFormat('#,##0.00').format(totalSales)}',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Divider(
              height: 5,
              thickness: 2,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Overall Total Sales:   ₱',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,##0.00').format(_overallTotalSales)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<double> _calculateOrganizationSales(String orgId) async {
    double totalSales = 0;

    final customerOrdersSnapshot = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgId)
        .collection('customerOrders')
        .where('orderCompleted', isEqualTo: true)
        .get();

    customerOrdersSnapshot.docs.forEach((orderDoc) {
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final orderItems = orderData['items'] as List<dynamic>;

      orderItems.forEach((item) {
        final itemData = item as Map<String, dynamic>;
        final productPrice = itemData['productPrice'] ?? 0;
        totalSales += productPrice;
      });
    });

    return totalSales;
  }
}
