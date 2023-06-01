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

    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    // Filter out customers who don't have any messages
    List<Map<String, dynamic>> filteredCustomerList =
        []; // <-- Explicitly declare the type here
    for (var customer in customerList) {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc('customers')
          .collection('messages')
          .where('farmerId', isEqualTo: currentUserUid)
          .where('customerId', isEqualTo: customer['id'])
          .get();

      if (messagesSnapshot.docs.isNotEmpty) {
        filteredCustomerList.add(customer);
      }
    }

    return filteredCustomerList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Customer Messages',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700)),
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

          if (customerList.isEmpty) {
            return const Center(child: Text('No messages from customers'));
          }

          return ListView.builder(
            itemCount: customerList.length,
            itemBuilder: (context, index) {
              final customer = customerList[index];
              final displayName = customer['displayName'];
              final role = customer['role'];

              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/images/image.png', // Replace with your actual image path
                    width: 50, // Adjust the width as needed
                    height: 50, // Adjust the height as needed
                  ),
                  title: Text(displayName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      )),
                  subtitle: Text('$role'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      FarmerChatScreen.routeName,
                      arguments: FarmerChatArguments(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        userType: FarmerType.customers,
                        displayName: displayName,
                        customerId:
                            customer['id'], // Use the customer's ID here
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
