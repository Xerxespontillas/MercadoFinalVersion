import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'organization_chat_screen.dart';
import 'organization_farmer_chat_screen.dart';

class OrganizationListScreen extends StatelessWidget {
  static const routeName = '/organization-list';

  // ignore: use_key_in_widget_constructors
  const OrganizationListScreen({Key? key});

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

    organizationsList.sort((a, b) =>
        a['displayName'].toString().compareTo(b['displayName'].toString()));

    return organizationsList;
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    final farmers = await fetchRegisteredFarmers();
    final customers = await fetchRegisteredCustomers();
    final organizations = await fetchRegisteredOrganizations();

    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final customerMessagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc('organization')
        .collection('messages')
        .where('orgId', isEqualTo: currentUserUid)
        .where('customerId',
            whereIn: customers.map((customers) => customers['id']).toList())
        .get();

    final farmerMessagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc('farmerstoorgs')
        .collection('messages')
        .where('orgId', isEqualTo: currentUserUid)
        .where('farmerId',
            whereIn: farmers.map((farmers) => farmers['id']).toList())
        .get();

    final customerMessages =
        customerMessagesSnapshot.docs.map((doc) => doc.data()).toList();
    final farmerMessages =
        farmerMessagesSnapshot.docs.map((doc) => doc.data()).toList();

    final combinedList = [...farmers, ...customers, ...organizations];

    combinedList.removeWhere((item) {
      final itemId = item['id'];
      final itemRole = item.containsKey('role') ? item['role'] : 'Farmer';
      if (itemRole == 'Farmer') {
        return !farmerMessages.any((message) => message['farmerId'] == itemId);
      } else {
        return !customerMessages
            .any((message) => message['customerId'] == itemId);
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

          final entityList = snapshot.data!;

          return ListView.builder(
            itemCount: entityList.length,
            itemBuilder: (context, index) {
              final entity = entityList[index];
              final displayName = entity['displayName'];
              final role = entity['role'];

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
                      Navigator.pushNamed(
                        context,
                        OrganizationChatScreen.routeName,
                        arguments: OrganizationChatArguments(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          userType: OrganizationType.customers,
                          displayName: displayName,
                          customerId: entity['id'], // Use the entity's ID here
                        ),
                      );
                    } else if (role == 'Farmer') {
                      Navigator.pushNamed(
                        context,
                        OrgToFarmerChatScreen.routeName,
                        arguments: OrgToFarmerChatArguments(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          userType: OrgToFarmerType.organization,
                          displayName: displayName,
                          farmerId: entity['id'], // Use the entity's ID here
                        ),
                      );
                    } else if (role == 'Organization') {}
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
