import 'package:flutter/material.dart';

class FarmerMyOrder extends StatefulWidget {
  static const routeName = '/farmer-my-order';
  const FarmerMyOrder({super.key});

  @override
  State<FarmerMyOrder> createState() => _FarmerMyOrderState();
}

class _FarmerMyOrderState extends State<FarmerMyOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),
    );
  }
}
