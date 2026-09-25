import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _brokerController;
  late TextEditingController _portController;
  late TextEditingController _deviceIdController;

  @override
  void initState() {
    super.initState();
    final mqtt = context.read<MqttService>();
    _brokerController = TextEditingController(text: mqtt.broker);
    _portController = TextEditingController(text: mqtt.port.toString());
    _deviceIdController = TextEditingController(text: mqtt.deviceId);
  }

  @override
  void dispose() {
    _brokerController.dispose();
    _portController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.read<MqttService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MQTT брокер', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _brokerController,
                    decoration: const InputDecoration(
                      labelText: 'Адрес брокера',
                      border: OutlineInputBorder(),
                      hintText: 'broker.emqx.io',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Порт (Web: 8083, TCP: 1883)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deviceIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID устройства',
                      border: OutlineInputBorder(),
                      hintText: 'gate_001',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Сохранить и переподключить'),
                      onPressed: () {
                        mqtt.updateConfig(
                          _brokerController.text,
                          int.tryParse(_portController.text) ?? 8083,
                          _deviceIdController.text,
                        );
                        mqtt.connect();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Настройки сохранены')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('О приложении', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Управление воротами v1.0'),
                  const SizedBox(height: 4),
                  const Text('MQTT клиент: mqtt_client 9.8.1'),
                  const SizedBox(height: 4),
                  const Text('Брокер по умолчанию: broker.emqx.io'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
