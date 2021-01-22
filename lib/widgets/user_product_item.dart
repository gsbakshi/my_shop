import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem({
    this.id,
    this.title,
    this.imageUrl,
  });

  void editor(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      EditProductScreen.routeName,
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () => editor(context),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () {
                Provider.of<Products>(
                  context,
                  listen: false,
                ).deleteProduct(id);
              },
            ),
          ],
        ),
      ),
      onTap: () => editor(context),
    );
  }
}
