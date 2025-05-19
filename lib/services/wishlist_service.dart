import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  static const String _wishlistKey = 'wishlist';

  // Get all wishlist items
  Future<List<Map<String, dynamic>>> getWishlistItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? wishlistJson = prefs.getString(_wishlistKey);
    
    if (wishlistJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(wishlistJson);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  // Add item to wishlist
  Future<bool> addToWishlist(Map<String, dynamic> item) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> currentItems = await getWishlistItems();
      
      // Check if item already exists
      final bool itemExists = currentItems.any((existingItem) => 
        existingItem['id'] != null && 
        item['id'] != null && 
        existingItem['id'].toString() == item['id'].toString()
      );
      
      // If item exists, don't add it again
      if (itemExists) {
        return false;
      }
      
      // Add new item
      currentItems.add(item);
      final String updatedJson = json.encode(currentItems);
      
      // Save updated list
      return await prefs.setString(_wishlistKey, updatedJson);
    } catch (e) {
      return false;
    }
  }

  // Remove item from wishlist
  Future<bool> removeFromWishlist(int index) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> currentItems = await getWishlistItems();
      
      if (index < 0 || index >= currentItems.length) {
        return false;
      }
      
      // Remove item at index
      currentItems.removeAt(index);
      final String updatedJson = json.encode(currentItems);
      
      // Save updated list
      return await prefs.setString(_wishlistKey, updatedJson);
    } catch (e) {
      return false;
    }
  }

  // Remove item by id
  Future<bool> removeItemById(dynamic id) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> currentItems = await getWishlistItems();
      
      final itemIndex = currentItems.indexWhere((item) => 
        item['id'] != null && item['id'].toString() == id.toString()
      );
      
      if (itemIndex == -1) {
        return false;
      }
      
      // Remove item
      currentItems.removeAt(itemIndex);
      final String updatedJson = json.encode(currentItems);
      
      // Save updated list
      return await prefs.setString(_wishlistKey, updatedJson);
    } catch (e) {
      return false;
    }
  }

  // Clear wishlist
  Future<bool> clearWishlist() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_wishlistKey);
    } catch (e) {
      return false;
    }
  }

  // Check if item is in wishlist
  Future<bool> isInWishlist(dynamic id) async {
    final List<Map<String, dynamic>> items = await getWishlistItems();
    
    return items.any((item) => 
      item['id'] != null && item['id'].toString() == id.toString()
    );
  }
} 