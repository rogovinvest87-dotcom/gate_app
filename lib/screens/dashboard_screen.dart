import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление воротами'),
        actions: [
          Icon(
            mqtt.isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: mqtt.isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        mqtt.isConnected ? Icons.check_circle : Icons.cancel,
                        color: mqtt.isConnected ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        mqtt.isConnected ? 'Подключено' : 'Не подключено',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!mqtt.isConnected)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.power),
                        label: const Text('Подключиться'),
                        onPressed: () => mqtt.connect(),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.power_off),
                        label: const Text('Отключиться'),
                        onPressed: () => mqtt.disconnect(),
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
                  Text('Управление', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.door_front_door),
                          label: const Text('Ворота'),
                          onPressed: mqtt.isConnected ? () => mqtt.openGate() : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.door_back_door),
                          label: const Text('Калитка'),
                          onPressed: mqtt.isConnected ? () => mqtt.openLock() : null,
                        ),
                      ),
                    ],
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
                  Text('Состояние', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _StateTile(
                    icon: Icons.door_front_door,
                    label: 'Ворота',
                    value: mqtt.gateState.gateOpen ? 'Открыты' : 'Закрыты',
                    color: mqtt.gateState.gateOpen ? Colors.green : Colors.grey,
                  ),
                  _StateTile(
                    icon: Icons.door_back_door,
                    label: 'Калитка',
                    value: mqtt.gateState.lockOpen ? 'Открыта' : 'Закрыта',
                    color: mqtt.gateState.lockOpen ? Colors.green : Colors.grey,
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
                  Text('Телеметрия', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _StateTile(
                    icon: Icons.battery_charging_full,
                    label: 'АКБ',
                    value: '${mqtt.gateState.batteryPercent.toStringAsFixed(0)}%',
                    color: _batteryColor(mqtt.gateState.batteryPercent),
                  ),
                  _StateTile(
                    icon: Icons.wb_sunny,
                    label: 'Солнце',
                    value: '${mqtt.gateState.solarPower.toStringAsFixed(1)} Вт',
                    color: Colors.orange,
                  ),
                  _StateTile(
                    icon: Icons.thermostat,
                    label: 'Температура',
                    value: '${mqtt.gateState.temperature.toStringAsFixed(1)} C',
                    color: Colors.blue,
                  ),
                  _StateTile(
                    icon: Icons.battery_full,
                    label: 'Напряжение АКБ',
                    value: '${mqtt.gateState.batteryVoltage.toStringAsFixed(1)} В',
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _batteryColor(double percent) {
    if (percent > 50) return Colors.green;
    if (percent > 20) return Colors.orange;
    return Colors.red;
  }
}

class _StateTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StateTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
