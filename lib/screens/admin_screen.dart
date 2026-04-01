import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService _apiService = ApiService();

  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final data = await _apiService.getUsers(true);

    setState(() {
      users = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: users.map((u) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(u['name']),
                    subtitle: Text(u['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${u['balance']} €"),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () async {
                            await _apiService.addMoney(u['id'], 100);
                            loadUsers();
                          },
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}