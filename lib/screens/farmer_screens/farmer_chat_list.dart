import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'farmer_chat_screen.dart';
import 'farmer_farmer_chat_screen.dart';
import 'farmer_org_chat_screen.dart';
import 'receiver_farmer_farmer_chat_screen.dart';

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

    customerList.sort((a, b) =>
        a['displayName'].toString().compareTo(b['displayName'].toString()));

    return customerList;
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredFarmers() async {
    final farmersSnapshot =
        await FirebaseFirestore.instance.collection('farmers').get();

    final farmerList = farmersSnapshot.docs.map((doc) {
      final farmerData = doc.data();
      final displayName = farmerData['displayName'];
      final farmerId = doc.id;
      return {
        'id': farmerId,
        'displayName': displayName,
        ...farmerData,
      };
    }).toList();

    farmerList.sort((a, b) =>
        a['displayName'].toString().compareTo(b['displayName'].toString()));

    return farmerList;
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredOrganizations() async {
    final organizationsSnapshot =
        await FirebaseFirestore.instance.collection('organizations').get();

    final organizationsList = organizationsSnapshot.docs.map((doc) {
      final orgData = doc.data();
      final organizationName = orgData['organizationName'];
      final orgId = doc.id;
      return {
        'id': orgId,
        'displayName': organizationName,
        'organizationName': organizationName,
        ...orgData,
      };
    }).toList();

    organizationsList.sort((a, b) => a['organizationName']
        .toString()
        .compareTo(b['organizationName'].toString()));

    return organizationsList;
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    final farmers = await fetchRegisteredFarmers();
    final customers = await fetchRegisteredCustomers();
    final organizations = await fetchRegisteredOrganizations();

    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final customerMessagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc('customers')
        .collection('messages')
        .where('farmerId', isEqualTo: currentUserUid)
        .where('customerId',
            whereIn: customers.map((customers) => customers['id']).toList())
        .get();

    final organizationMessagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc('farmerstoorgs')
        .collection('messages')
        .where('farmerId', isEqualTo: currentUserUid)
        .where('orgId',
            whereIn: organizations
                .map((organizations) => organizations['id'])
                .toList())
        .get();

    final farmerMessagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc('farmers')
        .collection('messages')
        .where('customerId', isEqualTo: currentUserUid)
        .where('farmerId',
            whereIn: farmers.map((farmers) => farmers['id']).toList())
        .get();

    final customerMessages =
        customerMessagesSnapshot.docs.map((doc) => doc.data()).toList();
    final farmerMessages =
        farmerMessagesSnapshot.docs.map((doc) => doc.data()).toList();
    final organizationMessages =
        organizationMessagesSnapshot.docs.map((doc) => doc.data()).toList();

    final combinedList = [...farmers, ...customers, ...organizations];

    combinedList.removeWhere((item) {
      final itemId = item['id'];
      final itemRole = item.containsKey('role') ? item['role'] : 'Customer';
      if (itemRole == 'Customer') {
        return !customerMessages
            .any((message) => message['customerId'] == itemId);
      } else if (itemRole == 'Farmer') {
        return !farmerMessages.any((message) => message['farmerId'] == itemId);
      } else {
        return !organizationMessages
            .any((message) => message['orgId'] == itemId);
      }
    });

    combinedList.sort((a, b) {
      final aDisplayName =
          a.containsKey('role') ? a['displayName'] : a['organizationName'];
      final bDisplayName =
          b.containsKey('role') ? b['displayName'] : b['organizationName'];
      return aDisplayName.toString().compareTo(bDisplayName.toString());
    });
    return combinedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Messages',
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error occurred'));
          }

          final combinedList = snapshot.data!;

          if (combinedList.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          return ListView.builder(
            itemCount: combinedList.length,
            itemBuilder: (context, index) {
              final item = combinedList[index];
              final displayName = item.containsKey('role')
                  ? item['displayName']
                  : item['organizationName'];

              if (item.containsKey('role')) {
                final role = item['role'];
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
                      if (role == 'Customer') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FarmerChatScreen(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              userType: FarmerType.farmer,
                              displayName: displayName,
                              customerId: item['id'],
                            ),
                          ),
                        );
                      } else if (role == 'Farmer') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReceiverFarmerToFarmerChatScreen(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              userType: ReceiverFarmersType.customers,
                              displayName: displayName,
                              customerId: item['id'],
                            ),
                          ),
                        );
                      } else if (role == 'Organization') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FarmerToOrgChatScreen(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              userType: FarmerToOrgType.organization,
                              displayName: displayName,
                              orgId: item['id'],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              } else {
                return ListTile(
                  title: Text(displayName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmerToFarmerChatScreen(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          userType: FarmersType.organization,
                          displayName: displayName,
                          customerId: item['id'],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
