import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FarmerList extends StatelessWidget {
  const FarmerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(0, 66, 180, 119),
          centerTitle: true,
          title: const Text(
            'Farmer Request',
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
          .collection('farmers')
          .where('isFarmerConfirmed', isEqualTo: false)
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
            child: Text('No pending farmers found'),
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
    final farmerData = farmerSnapshot.data() as Map<String, dynamic>;

    final farmerName = farmerData['displayName'] ?? 'Name not available';
    final farmerEmail = farmerData['email'] ?? 'Email not available';
    final farmerPhoneNumber =
        farmerData['phoneNumber'] ?? 'Phone number not available';
    final farmerAddress = farmerData['address'] ?? 'Address not available';

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
                    farmerName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text('Email: $farmerEmail'),
                  Text('Phone: $farmerPhoneNumber'),
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
    farmerRef.update({'isFarmerConfirmed': true});
  }

  void _declineFarmer(DocumentReference farmerRef) {
    farmerRef.delete();
  }
}
