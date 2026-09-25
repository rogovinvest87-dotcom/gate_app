import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/gate_state.dart';
import '../models/event_log.dart';

class MqttService extends ChangeNotifier {
  late MqttClient _client;

  String _broker = 'broker.emqx.io';
  int _port = 8083;
  String _deviceId = 'gate_001';
  bool _isConnected = false;

  final GateState gateState = GateState();
  final List<EventLogEntry> events = [];

  bool get isConnected => _isConnected;
  String get broker => _broker;
  int get port => _port;
  String get deviceId => _deviceId;

  MqttService() {
    _createClient();
  }

  void _createClient() {
    final clientId = 'gate_app_${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      // Browser: MqttBrowserClient + WebSocket
      _client = MqttBrowserClient('ws://$_broker:$_port/mqtt', clientId);
      _client.port = _port;
      (_client as MqttBrowserClient).websocketProtocols = ['mqtt'];
    } else {
      // Android/iOS/Desktop: MqttServerClient + TCP
      _client = MqttServerClient.withPort(_broker, clientId, 1883);
    }

    _client.keepAlivePeriod = 30;
    _client.autoReconnect = true;

    _client.onConnected = () {
      _isConnected = true;
      _subscribeTopics();
      _addEvent('system', 'Подключено к $_broker');
      notifyListeners();
    };

    _client.onDisconnected = () {
      _isConnected = false;
      _addEvent('system', 'Отключено от брокера');
      notifyListeners();
    };

    _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? messages) {
      if (messages == null) return;
      for (final recv in messages) {
        final pubMsg = recv.payload as MqttPublishMessage;
        final topic = pubMsg.variableHeader?.topicName ?? '';
        final payload = MqttPublishPayload.bytesToStringAsString(pubMsg.payload.message);
        _handleMessage(topic, payload);
      }
      notifyListeners();
    });
  }

  void _subscribeTopics() {
    _client.subscribe('$_deviceId/status', MqttQos.atMostOnce);
    _client.subscribe('$_deviceId/events', MqttQos.atMostOnce);
  }

  void _handleMessage(String topic, String payload) {
    _addEvent(topic, payload);

    if (topic == '$_deviceId/status') {
      if (payload.contains('gate_open')) {
        gateState.gateOpen = payload.contains('true');
      }
      if (payload.contains('lock_open')) {
        gateState.lockOpen = payload.contains('true');
      }
      if (payload.contains('battery_percent')) {
        final match = RegExp(r'battery_percent[=:]([\d.]+)').firstMatch(payload);
        if (match != null) {
          gateState.batteryPercent = double.tryParse(match.group(1)!) ?? gateState.batteryPercent;
        }
      }
      if (payload.contains('solar_power')) {
        final match = RegExp(r'solar_power[=:]([\d.]+)').firstMatch(payload);
        if (match != null) {
          gateState.solarPower = double.tryParse(match.group(1)!) ?? gateState.solarPower;
        }
      }
      if (payload.contains('temperature')) {
        final match = RegExp(r'temperature[=:]([\d.]+)').firstMatch(payload);
        if (match != null) {
          gateState.temperature = double.tryParse(match.group(1)!) ?? gateState.temperature;
        }
      }
      if (payload.contains('battery_voltage')) {
        final match = RegExp(r'battery_voltage[=:]([\d.]+)').firstMatch(payload);
        if (match != null) {
          gateState.batteryVoltage = double.tryParse(match.group(1)!) ?? gateState.batteryVoltage;
        }
      }
    }
  }

  void _addEvent(String topic, String message) {
    events.insert(0, EventLogEntry(topic: topic, message: message, timestamp: DateTime.now()));
    if (events.length > 100) events.removeLast();
  }

  Future<void> connect() async {
    try {
      await _client.connect();
    } catch (e) {
      _addEvent('system', 'Ошибка подключения: $e');
      notifyListeners();
    }
  }

  void disconnect() {
    _client.disconnect();
  }

  void openGate() {
    _publish('$_deviceId/command', 'open_gate');
    _addEvent('command', 'Команда: открыть ворота');
    notifyListeners();
  }

  void closeGate() {
    _publish('$_deviceId/command', 'close_gate');
    _addEvent('command', 'Команда: закрыть ворота');
    notifyListeners();
  }

  void openLock() {
    _publish('$_deviceId/command', 'open_lock');
    _addEvent('command', 'Команда: открыть калитку');
    notifyListeners();
  }

  void closeLock() {
    _publish('$_deviceId/command', 'close_lock');
    _addEvent('command', 'Команда: закрыть калитку');
    notifyListeners();
  }

  void _publish(String topic, String message) {
  if (_client.connectionStatus?.state != MqttConnectionState.connected) {
    debugPrint('MQTT: not connected, cannot publish');
    return;
  }

  final builder = MqttClientPayloadBuilder();
  builder.addString(message);

  // ИСПРАВЛЕНИЕ: проверяем payload на null и приводим к не-nullable
  final payload = builder.payload;
  if (payload != null) {
    _client.publishMessage(topic, MqttQos.atMostOnce, payload);
  } else {
    debugPrint('MQTT: payload is null, skipping publish');
  }
}


  void updateConfig(String newBroker, int newPort, String newDeviceId) {
    _broker = newBroker;
    _port = newPort;
    _deviceId = newDeviceId;
    _isConnected = false;
    _createClient();
    _addEvent('system', 'Конфигурация обновлена: $newBroker:$newPort');
    notifyListeners();
  }
}
