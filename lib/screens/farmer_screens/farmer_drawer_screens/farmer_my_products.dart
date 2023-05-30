import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/farmer_products_provider.dart';
import '../../../widgets/farmer_app_drawer.dart';

class FarmerMyProducts extends StatefulWidget {
  static const routeName = '/farmer-my-products';
  const FarmerMyProducts({Key? key}) : super(key: key);

  @override
  FarmerMyProductsState createState() => FarmerMyProductsState();
}

class FarmerMyProductsState extends State<FarmerMyProducts> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<FarmerProducts>(context).fetchProducts().then((_) {
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
    final productsData = Provider.of<FarmerProducts>(context);
    final products = productsData.items;

    return Scaffold(
      endDrawer: const FarmerAppDrawer(),
      appBar: AppBar(
        title: const Text("My Products"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (products.isEmpty
              ? const Center(child: Text("No Products Added, Add A Product"))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/farmer-my-edit-products',
                            arguments: products[i],
                          );
                        },
                        child: ListTile(
                          leading: Image.network(
                            products[i].image,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              // Return any widget you want to be displayed instead of the network image like an asset image or an icon
                              return const Icon(Icons.shopping_bag);
                            },
                          ),
                          title: Text(products[i].productName),
                          subtitle: Text(products[i].productDetails),
                          trailing: Text("Php.${products[i].price.toString()}"),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                )),
    );
  }
}
