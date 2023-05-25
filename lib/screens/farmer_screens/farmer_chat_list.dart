import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'farmer_chat_screen.dart';

class FarmerListScreen extends StatelessWidget {
  static const routeName = '/farmer-list';

  // ignore: use_key_in_widget_constructors
  const FarmerListScreen({Key? key});

  Future<List<Map<String, dynamic>>> fetchRegisteredCustomers() async {
    final customersSnapshot =
        await FirebaseFirestore.instance.collection('customers').get();

    // Get the customer documents along with their IDs
    final customerList = customersSnapshot.docs.map((doc) {
      final customerData = doc.data();
      final displayName = customerData['displayName'];
      final customerId = doc.id;
      return {
        'id': customerId,
        'displayName': displayName,
        ...customerData,
      };
    }).toList();

    return customerList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRegisteredCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error occurred'));
          }

          final customerList = snapshot.data!;

          return ListView.builder(
            itemCount: customerList.length,
            itemBuilder: (context, index) {
              final customer = customerList[index];
              final displayName = customer['displayName'];
              final role = customer['role'];

              return ListTile(
                title: Text(displayName),
                subtitle: Text('$role'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    FarmerChatScreen.routeName,
                    arguments: FarmerChatArguments(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      userType: FarmerType.customers,
                      displayName: displayName,
                      customerId: customer['id'], // Use the customer's ID here
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
