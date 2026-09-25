import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';

class GuestAccessScreen extends StatefulWidget {
  const GuestAccessScreen({super.key});

  @override
  State<GuestAccessScreen> createState() => _GuestAccessScreenState();
}

class _GuestAccessScreenState extends State<GuestAccessScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _validUntil;
  final List<Map<String, String>> _guests = [];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.read<MqttService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Гостевой доступ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Создать гостевой доступ', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя гостя',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Телефон',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_validUntil == null
                            ? 'Срок действия: не выбран'
                            : 'До: ${_validUntil!.day}.${_validUntil!.month}.${_validUntil!.year}'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _validUntil = date);
                          }
                        },
                        child: const Text('Выбрать дату'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Создать доступ'),
                      onPressed: () {
                        if (_nameController.text.isEmpty) return;
                        setState(() {
                          _guests.add({
                            'name': _nameController.text,
                            'phone': _phoneController.text,
                            'validUntil': _validUntil != null
                                ? '${_validUntil!.day}.${_validUntil!.month}.${_validUntil!.year}'
                                : 'Бессрочно',
                          });
                        });
                        if (mqtt.isConnected) {
                          mqtt.openGate();
                        }
                        _nameController.clear();
                        _phoneController.clear();
                        setState(() => _validUntil = null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Гостевой доступ создан')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_guests.isNotEmpty) ...[
            Text('Активные доступы', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._guests.map((g) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(g['name']!),
                    subtitle: Text('${g['phone']} - до ${g['validUntil']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _guests.remove(g));
                      },
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
