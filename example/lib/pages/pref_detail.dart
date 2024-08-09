import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_flutter_v2.dart';
import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreferencesDetailPage extends StatefulWidget {
  final String topicId;
  final Function() onSave;

  PreferencesDetailPage({required this.topicId, required this.onSave});

  @override
  _PreferencesDetailPageState createState() => _PreferencesDetailPageState();
}

class _PreferencesDetailPageState extends State<PreferencesDetailPage> {
  late CourierUserPreferencesTopic _topic;
  bool _isLoading = true;
  String? _error;

  CourierUserPreferencesStatus? _selectedStatus;
  bool? _hasCustomRouting;
  List<CourierUserPreferencesChannel>? _customRouting;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // try {
    //   _topic = await Courier.shared.getUserPreferencesTopic(topicId: widget.topicId);
    // } catch (error) {
    //   setState(() {
    //     _error = error.toString();
    //   });
    // }

    setState(() {
      _isLoading = false;
    });
  }

  void _saveButtonTapped(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = await CourierRC.shared.client;
      await client?.preferences.putUserPreferencesTopic(
        topicId: widget.topicId,
        status: _selectedStatus ?? _topic.status,
        hasCustomRouting: _hasCustomRouting ?? _topic.hasCustomRouting,
        customRouting: _customRouting ?? _topic.customRouting,
      );
      widget.onSave();
      Navigator.pop(context);
    } catch (error) {
      final snackBar = SnackBar(content: Text(error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildContent(BuildContext context) {
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

    return Scrollbar(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatusTabs(
                initialStatus: _topic.status,
                onStatusChanged: (selectedStatus) {
                  _selectedStatus = selectedStatus;
                },
              ),
              SizedBox(height: 16), // Add vertical spacing
              CustomRoutingSwitch(
                initialValue: _topic.hasCustomRouting,
                onChanged: (value) {
                  _hasCustomRouting = value;
                },
              ),
              SizedBox(height: 16), // Add vertical spacing
              ChannelsSelectionList(
                initialSelectedChannels: _topic.customRouting,
                onSelectionChanged: (value) {
                  _customRouting = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicId, style: GoogleFonts.robotoMono(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (!_isLoading && _error == null) {
                _saveButtonTapped(context);
              }
            },
          ),
        ],
      ),
      body: _buildContent(context),
    );
  }
}

class StatusTabs extends StatefulWidget {
  final CourierUserPreferencesStatus initialStatus;
  final ValueChanged<CourierUserPreferencesStatus> onStatusChanged;

  StatusTabs({required this.initialStatus, required this.onStatusChanged});

  @override
  State<StatusTabs> createState() => _StatusTabsState();
}

class _StatusTabsState extends State<StatusTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final statuses = [
    CourierUserPreferencesStatus.optedIn,
    CourierUserPreferencesStatus.optedOut,
    CourierUserPreferencesStatus.required,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = statuses.indexOf(widget.initialStatus);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold)),
        TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.robotoMono(),
          tabs: statuses.map((status) => Tab(text: status.value)).toList(),
          onTap: (index) {
            widget.onStatusChanged(statuses[index]);
          },
        ),
      ],
    );
  }
}

class CustomRoutingSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  CustomRoutingSwitch({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _CustomRoutingSwitchState createState() => _CustomRoutingSwitchState();
}

class _CustomRoutingSwitchState extends State<CustomRoutingSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Has Custom Routing',
            style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SwitchListTile(
          title: Text('Has Custom Routing', style: GoogleFonts.robotoMono()),
          value: _value,
          onChanged: (newValue) {
            setState(() {
              _value = newValue;
            });
            widget.onChanged(newValue);
          },
        ),
      ],
    );
  }
}

class ChannelsSelectionList extends StatefulWidget {
  final List<CourierUserPreferencesChannel> initialSelectedChannels;
  final ValueChanged<List<CourierUserPreferencesChannel>> onSelectionChanged;

  ChannelsSelectionList({
    required this.initialSelectedChannels,
    required this.onSelectionChanged,
  });

  @override
  _ChannelsSelectionListState createState() => _ChannelsSelectionListState();
}

class _ChannelsSelectionListState extends State<ChannelsSelectionList> {
  late List<bool> _selections;

  @override
  void initState() {
    super.initState();
    _selections = List.generate(
      CourierUserPreferencesChannel.allCases.length,
      (index) => widget.initialSelectedChannels.contains(CourierUserPreferencesChannel.allCases[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Custom Routing',
            style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: CourierUserPreferencesChannel.allCases.length,
          itemBuilder: (context, index) {
            final channel = CourierUserPreferencesChannel.allCases[index];
            return SwitchListTile(
              title: Text(channel.value, style: GoogleFonts.robotoMono()),
              value: _selections[index],
              onChanged: (newValue) {
                setState(() {
                  _selections[index] = newValue;
                });
                _notifyParent();
              },
            );
          },
        ),
      ],
    );
  }

  void _notifyParent() {
    final selectedChannels = <CourierUserPreferencesChannel>[];
    for (var i = 0; i < _selections.length; i++) {
      if (_selections[i]) {
        selectedChannels.add(CourierUserPreferencesChannel.allCases[i]);
      }
    }
    widget.onSelectionChanged(selectedChannels);
  }
}
