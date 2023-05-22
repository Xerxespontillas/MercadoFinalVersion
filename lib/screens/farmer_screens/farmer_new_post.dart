import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewProductPost extends StatefulWidget {
  const NewProductPost({Key? key}) : super(key: key);

  @override
  _NewProductPostState createState() => _NewProductPostState();
}

class _NewProductPostState extends State<NewProductPost> {
  int quantity = 0;
  final TextEditingController _textController = TextEditingController();

  void increaseQuantity() {
    setState(() {
      quantity += 1;
    });
  }

  void decreaseQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.02), // 2% of screen width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        image: DecorationImage(
                          image: AssetImage('assets/images/merkado_logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenSize.width * 0.02), // 2% of screen width
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.penToSquare),
                          SizedBox(
                              width: screenSize.width *
                                  0.01), // 1% of screen width
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Product Name',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.dollarSign),
                          SizedBox(
                              width: screenSize.width *
                                  0.01), // 1% of screen width
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Price',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Qty.'),
                          SizedBox(
                              width: screenSize.width *
                                  0.01), // 1% of screen width
                          Text(quantity.toString()),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: increaseQuantity,
                          ),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: decreaseQuantity,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.height * 0.02), // 2% of screen height
            ElevatedButton.icon(
              onPressed: () {
                // Handle button press here
              },
              icon: Icon(Icons.location_on),
              label: Text('Location'),
            ),
            SizedBox(height: screenSize.height * 0.02), // 2%
            // Product details text field
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter Product details',
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.02), // 2% of screen height

            // ADD ITEM NOW and CANCEL buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Handle button press here
                  },
                  icon: Icon(Icons.add),
                  label: Text('ADD ITEM NOW'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle button press here
                  },
                  child: Text('CANCEL'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
