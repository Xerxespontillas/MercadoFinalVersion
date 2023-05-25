import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_chat_screen.dart';

class UserListScreen extends StatelessWidget {
  static const routeName = '/user-list';

  // ignore: use_key_in_widget_constructors
  const UserListScreen({Key? key});

  Future<List<Map<String, dynamic>>> fetchRegisteredFarmers() async {
    final farmersSnapshot =
        await FirebaseFirestore.instance.collection('farmers').get();

    // Get the farmer documents along with their IDs
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

    // Sort the farmerList by display name in alphabetical order
    farmerList.sort((a, b) =>
        a['displayName'].toString().compareTo(b['displayName'].toString()));

    return farmerList;
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredOrganizations() async {
    final organizationsSnapshot =
        await FirebaseFirestore.instance.collection('organizations').get();

    // Get the organization documents along with their IDs
    final organizationsList = organizationsSnapshot.docs.map((doc) {
      final orgData = doc.data();
      final organizationName = orgData['organizationName'];
      final orgId = doc.id;
      return {
        'id': orgId,
        'displayName':
            organizationName, // Use the "organizationName" field as display name
        'organizationName': organizationName, // Add the organization name
        ...orgData,
      };
    }).toList();

    // Sort the organizationsList by organization name in alphabetical order
    organizationsList.sort((a, b) => a['organizationName']
        .toString()
        .compareTo(b['organizationName'].toString()));

    return organizationsList;
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    final farmers = await fetchRegisteredFarmers();
    final organizations = await fetchRegisteredOrganizations();

    final combinedList = [...farmers, ...organizations];
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
        title: const Text('Farmers & Organizations'),
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

          return ListView.builder(
            itemCount: combinedList.length,
            itemBuilder: (context, index) {
              final item = combinedList[index];
              final displayName = item.containsKey('role')
                  ? item['displayName']
                  : item['organizationName'];

              if (item.containsKey('role')) {
                // Display farmer item
                final role = item['role'];
                return ListTile(
                  title: Text(displayName),
                  subtitle: Text('$role'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      UserChatScreen.routeName,
                      arguments: UserChatArguments(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        userType: UserType.farmer,
                        displayName: displayName,
                        farmerId: item['id'],
                      ),
                    );
                  },
                );
              } else {
                // Display organization item
                return ListTile(
                  title: Text(displayName),
                  onTap: () {
                    // Handle organization list item tap
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
