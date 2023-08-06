import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrganizationList extends StatelessWidget {
  const OrganizationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(0, 66, 180, 119),
          centerTitle: true,
          title: const Text(
            'Organization Request',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          )),
      body: _buildFarmerList(),
    );
  }

  Widget _buildFarmerList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('organizations')
          .where('isOrgConfirmed', isEqualTo: false)
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
            child: Text('No pending organizations found'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildFarmerCard(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildFarmerCard(DocumentSnapshot farmerSnapshot) {
    final orgData = farmerSnapshot.data() as Map<String, dynamic>;

    final orgName = orgData['displayName'] ?? 'Name not available';
    final orgEmail = orgData['email'] ?? 'Email not available';
    final orgPhoneNumber =
        orgData['phoneNumber'] ?? 'Phone number not available';
    final farmerAddress = orgData['address'] ?? 'Address not available';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orgName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text('Email: $orgEmail'),
                  Text('Phone: $orgPhoneNumber'),
                  Text('Address: $farmerAddress'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => _confirmFarmer(farmerSnapshot.reference),
                  child: Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _declineFarmer(farmerSnapshot.reference),
                  child: Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmFarmer(DocumentReference farmerRef) {
    farmerRef.update({'isOrgConfirmed': true});
  }

  void _declineFarmer(DocumentReference farmerRef) {
    farmerRef.delete();
  }
}
