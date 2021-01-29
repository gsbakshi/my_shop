import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;

import '../widgets/order_item.dart';
import '../widgets/common/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future _getOrders() {
    return Provider.of<Orders>(
      context,
      listen: false,
    ).fetchOrders();
  }

  @override
  void initState() {
    super.initState();
    _ordersFuture = _getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _getOrders,
        child: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.error != null) {
                // !         TODO       error handling
                return Center(
                  child: Text(
                    'An error occurred - ${snapshot.error.toString()}',
                  ),
                );
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
