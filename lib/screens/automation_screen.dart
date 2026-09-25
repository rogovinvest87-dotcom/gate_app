import 'package:flutter/material.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  bool _autoClose = false;
  bool _geoZone = false;
  bool _notifications = true;
  double _autoCloseDelay = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Автоматизация')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Авто-закрытие ворот'),
              subtitle: const Text('Закрывать ворота автоматически'),
              value: _autoClose,
              onChanged: (v) => setState(() => _autoClose = v),
            ),
          ),
          if (_autoClose)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Задержка: ${_autoCloseDelay.toInt()} сек'),
                    Slider(
                      value: _autoCloseDelay,
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '${_autoCloseDelay.toInt()} сек',
                      onChanged: (v) => setState(() => _autoCloseDelay = v),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            child: SwitchListTile(
              title: const Text('Геозона'),
              subtitle: const Text('Открывать при приближении'),
              value: _geoZone,
              onChanged: (v) => setState(() => _geoZone = v),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Уведомления'),
              subtitle: const Text('Push при событиях'),
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
          ),
        ],
      ),
    );
  }
}
