import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/item_model.dart';
import 'services/local_storage_service.dart';

class LocalStorageCRUDScreen extends StatefulWidget {
  const LocalStorageCRUDScreen({Key? key}) : super(key: key);

  @override
  State<LocalStorageCRUDScreen> createState() => _LocalStorageCRUDScreenState();
}

class _LocalStorageCRUDScreenState extends State<LocalStorageCRUDScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  List<Item> _items = [];
  bool _isLoading = true;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    _items = await _storageService.getItems();
    setState(() => _isLoading = false);
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty) return;

    final now = DateTime.now();

    if (_editingId != null) {
      final updatedItem = Item(
        id: _editingId!,
        name: _nameController.text,
        description: _descController.text,
        createdAt: _items.firstWhere((item) => item.id == _editingId).createdAt,
        updatedAt: now,
      );
      await _storageService.updateItem(updatedItem);
    } else {
      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descController.text,
        createdAt: now,
        updatedAt: now,
      );
      await _storageService.addItem(newItem);
    }

    _clearForm();
    await _loadItems();
  }

  void _editItem(Item item) {
    setState(() {
      _editingId = item.id;
      _nameController.text = item.name;
      _descController.text = item.description;
    });
  }

  Future<void> _deleteItem(String id) async {
    await _storageService.deleteItem(id);
    await _loadItems();
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _descController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Local Storage'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _editingId != null ? 'Edit Item' : 'Tambah Item Baru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Item',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveItem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(
                              _editingId != null ? 'UPDATE' : 'SIMPAN',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        if (_editingId != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton(
                              onPressed: _clearForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              child: const Text(
                                'BATAL',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(
                        child: Text('Tidak ada data'),
                      )
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.description),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Diperbarui: ${DateFormat('dd/MM/yyyy HH:mm').format(item.updatedAt)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _editItem(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteItem(item.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearForm,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
