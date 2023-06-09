import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/farmer_app_drawer.dart';
import '../../providers/organization_products_provider.dart';

class OrganizationMyProducts extends StatefulWidget {
  static const routeName = '/organization-my-products';
  const OrganizationMyProducts({Key? key}) : super(key: key);

  @override
  OrganizationMyProductsState createState() => OrganizationMyProductsState();
}

class OrganizationMyProductsState extends State<OrganizationMyProducts> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<OrganizationProducts>(context).fetchProducts().then((_) {
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
    final productsData = Provider.of<OrganizationProducts>(context);
    final products = productsData.items;

    return Scaffold(
      endDrawer: const FarmerAppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black, // Set the color of the back icon to black
        ),
        title: const Text("My Products",
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700)),
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
                            '/organization-my-edit-products',
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
