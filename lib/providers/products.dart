import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://my-shop-550f4-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) {
        return;
      }
      url =
          'https://my-shop-550f4-default-rtdb.firebaseio.com/users/$userId/favorites.json?auth=$authToken';

      final favoriteResponse = await http.get(url);
      final favData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      data.forEach(
        (productId, productData) {
          loadedProducts.insert(
            0,
            Product(
              id: productId,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              imageUrl: productData['imageUrl'],
              isFavorite: favData == null ? false : favData[productId] ?? false,
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(NewProduct product) async {
    final url =
        'https://my-shop-550f4-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      // _items.add(newProduct);
      _items.insert(0, newProduct); // adds product at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, NewProduct product) async {
    final productIndex = _items.indexWhere(
      (product) => product.id == id,
    );
    if (productIndex >= 0) {
      try {
        final url =
            'https://my-shop-550f4-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
        await http.patch(
          url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }),
        );
      } catch (error) {
        throw error;
      }
      _items[productIndex] = Product(
        id: product.id,
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      );
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://my-shop-550f4-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
