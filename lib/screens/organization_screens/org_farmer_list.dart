// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merkado/screens/organization_screens/org_add_farmer.dart';
import 'package:merkado/screens/organization_screens/org_farmer_profile.dart';

class OrgFarmerList extends StatefulWidget {
  const OrgFarmerList({Key? key});
  static const routeName = '/org-farmer-list';

  @override
  State<OrgFarmerList> createState() => _OrgFarmerListState();
}

class _OrgFarmerListState extends State<OrgFarmerList> {
  final TextEditingController _searchController = TextEditingController();
  String search = '';

  Future<List<Map<String, dynamic>>> _fetchFarmers() async {
    final firestore = FirebaseFirestore.instance;

    // Get the current user's UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case when the user is not authenticated
      return [];
    }

    // Create a reference to the "OrgAddFarmers" collection under the user's UID
    final userCollectionRef = firestore
        .collection("organizations")
        .doc(user.uid)
        .collection("OrgAddFarmers");

    final querySnapshot = await userCollectionRef.get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 66, 180, 119),
        centerTitle: true,
        title: const Text(
          'Farmers',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black, size: 30),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '   looking for someone? ',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(OrgAddFarmer.routeName);
                },
                icon: const Icon(
                  Icons.person_add_alt_sharp,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFarmers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching data.'),
                  );
                } else {
                  final farmers = snapshot.data!;
                  return ListView.builder(
                    itemCount: farmers.length,
                    itemBuilder: (context, index) {
                      final farmer = farmers[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrgFarmerProfile(
                                farmerData: farmer,
                              ),
                            ),
                          );
                        },
                        child: Container(
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
                            title: Text(
                              farmer["displayName"] ?? "Unknown",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text("Address: " + farmer["address"]),
                            // Display other fields as needed
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
