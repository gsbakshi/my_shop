import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

import './edit_product_screen.dart';

import '../widgets/common/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditProductScreen.routeName,
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Consumer<Products>(
          builder: (ctx, product, _) => ListView.builder(
            itemCount: product.items.length,
            itemBuilder: (ctx, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    UserProductItem(
                      id: product.items[i].id,
                      title: product.items[i].title,
                      imageUrl: product.items[i].imageUrl,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}