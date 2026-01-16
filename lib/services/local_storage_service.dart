import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';

class LocalStorageService {
  static const String _itemsKey = 'items';

  Future<List<Item>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_itemsKey);

    if (itemsJson == null) return [];

    final List<dynamic> itemsList = itemsJson.isNotEmpty
        ? itemsJson
            .split('|||')
            .map((json) {
              try {
                return json;
              } catch (e) {
                return null;
              }
            })
            .where((item) => item != null)
            .toList()
        : [];

    return itemsList.map((json) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(json);
      return Item.fromMap(map);
    }).toList();
  }

  Future<void> saveItems(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = items.map((item) => item.toMap()).toList();
    final encodedItems = itemsJson.map((map) => map.toString()).join('|||');
    await prefs.setString(_itemsKey, encodedItems);
  }

  Future<String> addItem(Item item) async {
    final items = await getItems();
    items.add(item);
    await saveItems(items);
    return item.id;
  }

  Future<void> updateItem(Item updatedItem) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      await saveItems(items);
    }
  }

  Future<void> deleteItem(String id) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == id);
    await saveItems(items);
  }

  Future<Item?> getItem(String id) async {
    final items = await getItems();
    return items.firstWhere((item) => item.id == id,
        orElse: () => Item(
              id: '',
              name: '',
              description: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
  }
}
