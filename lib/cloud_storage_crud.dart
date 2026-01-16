import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'models/item_model.dart';

class CloudStorageCRUDScreen extends StatefulWidget {
  const CloudStorageCRUDScreen({super.key});

  @override
  State<CloudStorageCRUDScreen> createState() => _CloudStorageCRUDScreenState();
}

class _CloudStorageCRUDScreenState extends State<CloudStorageCRUDScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Storage CRUD (Firebase)'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          _inputForm(),
          Expanded(child: _itemList()),
        ],
      ),
    );
  }

  // ================= FORM =================
  Widget _inputForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Item',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saveItem,
              child: const Text('SIMPAN'),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SAVE =================
  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty || _descController.text.isEmpty) return;

    final item = Item(
      id: '',
      name: _nameController.text,
      description: _descController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firebaseService.addItem(item);

    _nameController.clear();
    _descController.clear();
  }

  // ================= LIST =================
  Widget _itemList() {
    return StreamBuilder<List<Item>>(
      stream: _firebaseService.getItemsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Data masih kosong'));
        }

        final items = snapshot.data!;

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text(item.description),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _firebaseService.deleteItem(item.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
