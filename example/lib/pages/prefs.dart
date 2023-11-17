import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class PrefsPage extends StatefulWidget {
  const PrefsPage({super.key});

  @override
  State<PrefsPage> createState() => _PrefsPageState();
}

class _PrefsPageState extends State<PrefsPage> {
  CourierUserPreferences? _preferences;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  // To update a topic
  // await Courier.shared.putUserPreferencesTopic(
  //     topicId: 'YOUR_ID',
  //     status: CourierUserPreferencesStatus.optedIn,
  //     hasCustomRouting: true,
  //     customRouting: [CourierUserPreferencesChannel.push]
  // );

  _showAlert(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Future<void> _start() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final preferences = await Courier.shared.getUserPreferences();
      setState(() {
        _error = null;
        _isLoading = false;
        _preferences = preferences;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _preferences = null;
      });
    }
  }

  Future<void> _refresh() async {
    return _start();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(_error!),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scrollbar(
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: _preferences?.items.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            final topic = _preferences!.items[index];
            return InkWell(
              onTap: () async {
                final prefTopic = await Courier.shared.getUserPreferencesTopic(topicId: topic.topicId);
                _showAlert(context, prefTopic.topicId, prefTopic.toJson());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  topic.toJson(),
                  style: GoogleFonts.robotoMono(fontSize: 16.0),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: _buildContent(),
    );
  }
}

extension TopicExtension on CourierUserPreferencesTopic {
  String toJson() => jsonEncode({
        'topicId': topicId,
        'topicName': topicName,
        'status': status.value,
        'hasCustomRouting': hasCustomRouting,
        'defaultStatus': defaultStatus.value,
        'customRouting': customRouting.map((e) => e.value).join(", "),
      });
}
