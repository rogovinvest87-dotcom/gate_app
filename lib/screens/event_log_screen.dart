import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';

class EventLogScreen extends StatelessWidget {
  const EventLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Журнал событий')),
      body: mqtt.events.isEmpty
          ? const Center(child: Text('Нет событий'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: mqtt.events.length,
              itemBuilder: (context, index) {
                final e = mqtt.events[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      e.topic == 'system' ? Icons.info : Icons.notifications,
                      color: e.topic == 'command' ? Colors.blue : Colors.grey,
                    ),
                    title: Text(e.message),
                    subtitle: Text('${e.formattedTime} - ${e.topic}'),
                  ),
                );
              },
            ),
    );
  }
}
