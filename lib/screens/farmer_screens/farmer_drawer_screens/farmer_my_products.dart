import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/products_provider.dart';
import '../../../widgets/farmer_app_drawer.dart';
import '../models/product.dart';

class FarmerMyProducts extends StatefulWidget {
  static const routeName = '/farmer-my-products';
  const FarmerMyProducts({Key? key}) : super(key: key);

  @override
  _FarmerMyProductsState createState() => _FarmerMyProductsState();
}

class _FarmerMyProductsState extends State<FarmerMyProducts> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = productsData.items;

    return Scaffold(
      endDrawer: FarmerAppDrawer(),
      appBar: AppBar(
        title: Text("My Products"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : (products.isEmpty
              ? Center(child: Text("No Products Added, Add A Product"))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => Column(
                    children: [
                      ListTile(
                        leading: Image.network(products[i].image),
                        title: Text(products[i].productName),
                        subtitle: Text(products[i].productDetails),
                        trailing: Text("\$${products[i].price.toString()}"),
                      ),
                      Divider(),
                    ],
                  ),
                )),
    );
  }
}
