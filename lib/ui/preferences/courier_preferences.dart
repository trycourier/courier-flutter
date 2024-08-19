import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:courier_flutter/ui/courier_footer.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/courier_theme_builder.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_section.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_sheet.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Mode {}

class TopicMode extends Mode {}

class ChannelsMode extends Mode {
  final List<CourierUserPreferencesChannel> channels;
  ChannelsMode({required this.channels});
}

class CourierPreferences extends StatefulWidget {
  // Useful if you are placing your Inbox in a TabView or another widget that will recycle
  final bool keepAlive;

  // The theming for your Inbox
  final Mode mode;
  final CourierPreferencesTheme _lightTheme;
  final CourierPreferencesTheme _darkTheme;

  // Scroll handling
  final ScrollController? scrollController;

  // Error callbacks
  final Function(String)? onError;

  CourierPreferences({
    super.key,
    this.keepAlive = false,
    Mode? mode,
    CourierPreferencesTheme? lightTheme,
    CourierPreferencesTheme? darkTheme,
    this.scrollController,
    this.onError,
  }) : mode = mode ?? ChannelsMode(channels: CourierUserPreferencesChannel.allCases),
      _lightTheme = lightTheme ?? CourierPreferencesTheme(),
      _darkTheme = darkTheme ?? CourierPreferencesTheme();

  @override
  CourierPreferencesState createState() => CourierPreferencesState();
}

class CourierPreferencesState extends State<CourierPreferences> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  late final ScrollController _scrollController = widget.scrollController ?? ScrollController();

  bool _isLoading = true;
  String? _error;
  List<PreferenceSection> _sections = [];

  CourierBrand? _brand;
  String? _userId;

  @override
  void initState() {
    super.initState();

    // Ensure widget is mounted
    if (mounted) {
      _retry();
    }
  }

  Future<void> _getPreferences() async {

    final userId = await Courier.shared.userId;

    final brand = await _refreshBrand();

    try {

      final client = await Courier.shared.client;
      final res = await client?.preferences.getUserPreferences();

      if (res == null) {
        throw "Unable to get preferences";
      }

      if (!mounted) return;

      final topics = res.items;

      List<PreferenceSection> sections = [];

      for (var topic in topics) {

        String sectionId = topic.sectionId;

        // Add the item to the proper section
        int sectionIndex = sections.indexWhere((section) => section.id == sectionId);

        if (sectionIndex != -1) {

          sections[sectionIndex].topics.add(topic);

        } else {

          PreferenceSection newSection = PreferenceSection(
            title: topic.sectionName,
            id: topic.sectionId,
            topics: [topic],
          );

          sections.add(newSection);

        }

      }

      setState(() {
        _userId = userId;
        _brand = brand;
        _sections = sections;
        _isLoading = false;
        _error = null;
      });

    } catch (error) {

      if (!mounted) return;

      setState(() {
        _userId = userId;
        _brand = brand;
        _sections = [];
        _isLoading = false;
        _error = error.toString();
      });

    }

  }

  Future<CourierBrand?> _refreshBrand() async {

    if (!mounted) return null;

    try {

      // Get the theme
      Brightness currentBrightness = PlatformDispatcher.instance.platformBrightness;
      final brandId = currentBrightness == Brightness.dark ? widget._darkTheme.brandId : widget._lightTheme.brandId;

      if (brandId == null) {
        widget._lightTheme.brand = null;
        widget._darkTheme.brand = null;
        return null;
      }

      // Get / set the brand
      final client = await Courier.shared.client;
      final res = await client?.brands.getBrand(brandId: brandId);
      final brand = res?.data?.brand;
      widget._lightTheme.brand = brand;
      widget._darkTheme.brand = brand;
      return brand;

    } catch (error) {

      if (widget.onError != null) {
        widget.onError!(error.toString());
      }

      widget._lightTheme.brand = null;
      widget._darkTheme.brand = null;
      return null;

    }

  }

  Future<void> _retry() async {

    final userId = await Courier.shared.userId;

    setState(() {
      _userId = userId;
      _sections = [];
      _isLoading = true;
      _error = null;
    });

    await _getPreferences();

  }

  int get _itemCount => _sections.length;

  CourierPreferencesTheme getTheme(bool isDarkMode) {
    return isDarkMode ? widget._darkTheme : widget._lightTheme;
  }

  void _showTopicSheet(BuildContext context, bool isDarkMode, CourierUserPreferencesTopic topic) {

    final items = <CourierSheetItem>[];

    if (widget.mode is TopicMode) {

      final isRequired = topic.status == CourierUserPreferencesStatus.required;
      var isOn = true;

      if (!isRequired) {
        isOn = topic.status != CourierUserPreferencesStatus.optedOut;
      }

      items.add(CourierSheetItem(
        title: 'Receive Notifications',
        isOn: isOn,
        isDisabled: isRequired,
        channel: null,
      ));

    } else if (widget.mode is ChannelsMode) {

      final mode = widget.mode as ChannelsMode;

      items.addAll(mode.channels.map((channel) {
        final isRequired = topic.status == CourierUserPreferencesStatus.required;
        var isOn = true;

        if (topic.customRouting.isEmpty) {
          isOn = topic.status != CourierUserPreferencesStatus.optedOut;
        } else {
          isOn = topic.customRouting.contains(channel);
        }

        return CourierSheetItem(
          title: channel.title,
          isOn: isOn,
          isDisabled: isRequired,
          channel: channel,
        );
      }));

    }

    final sheet = CourierPreferencesSheet(
      mode: widget.mode,
      theme: getTheme(isDarkMode),
      topic: topic,
      items: items,
    );

    showModalBottomSheet(
      context: context,
      shape: getTheme(isDarkMode).sheetShape,
      builder: (BuildContext context) => sheet,
    ).then((value) {
      _updatePreferences(widget.mode, topic, sheet.items);
    });

  }

  Future<void> _updatePreferences(Mode mode, CourierUserPreferencesTopic topic, List<CourierSheetItem> items) async {

    if (topic.defaultStatus == CourierUserPreferencesStatus.required && topic.status == CourierUserPreferencesStatus.required) {
      return;
    }

    if (widget.mode is TopicMode) {

      final selectedItems = items.where((item) => item.isOn).toList();
      final isSelected = selectedItems.isNotEmpty;

      if (topic.status == CourierUserPreferencesStatus.optedIn && isSelected) {
        return;
      }

      if (topic.status == CourierUserPreferencesStatus.optedOut && !isSelected) {
        return;
      }

      final newStatus = isSelected ? CourierUserPreferencesStatus.optedIn : CourierUserPreferencesStatus.optedOut;

      final newTopic = CourierUserPreferencesTopic(
        defaultStatus: topic.defaultStatus,
        hasCustomRouting: false,
        customRouting: [],
        status: newStatus,
        topicId: topic.topicId,
        topicName: topic.topicName,
        sectionName: topic.sectionName,
        sectionId: topic.sectionId,
      );

      if (newTopic.isEqual(topic)) {
        return;
      }

      _updateTopic(topic.topicId, newTopic);

      try {

        final client = await Courier.shared.client;
        await client?.preferences.putUserPreferenceTopic(
            topicId: topic.topicId,
            status: newStatus,
            hasCustomRouting: topic.hasCustomRouting,
            customRouting: topic.customRouting
        );

        Courier.log("Topic updated: ${topic.topicId}");

      } catch (error) {

        Courier.log(error.toString());

        if (widget.onError != null) {
          widget.onError!(error.toString());
        }

        _updateTopic(topic.topicId, topic);

      }

    } else if (widget.mode is ChannelsMode) {

      final selectedItems = items.where((item) => item.isOn).map((item) => item.channel as CourierUserPreferencesChannel).toList();

      var newStatus = CourierUserPreferencesStatus.unknown;

      if (selectedItems.isEmpty) {
        newStatus = CourierUserPreferencesStatus.optedOut;
      } else {
        newStatus = CourierUserPreferencesStatus.optedIn;
      }

      var hasCustomRouting = false;
      var customRouting = <CourierUserPreferencesChannel>[];
      final areAllSelected = selectedItems.length == items.length;

      if (areAllSelected && topic.defaultStatus == CourierUserPreferencesStatus.optedIn) {
        hasCustomRouting = false;
        customRouting = [];
      } else if (selectedItems.isEmpty && topic.defaultStatus == CourierUserPreferencesStatus.optedOut) {
        hasCustomRouting = false;
        customRouting = [];
      } else {
        hasCustomRouting = true;
        customRouting = selectedItems;
      }

      final newTopic = CourierUserPreferencesTopic(
        defaultStatus: topic.defaultStatus,
        hasCustomRouting: hasCustomRouting,
        customRouting: customRouting.map((channel) => channel).toList(),
        status: newStatus,
        topicId: topic.topicId,
        topicName: topic.topicName,
        sectionName: topic.sectionName,
        sectionId: topic.sectionId,
      );

      if (newTopic.isEqual(topic)) {
        return;
      }

      _updateTopic(topic.topicId, newTopic);

      try {

        final client = await Courier.shared.client;
        await client?.preferences.putUserPreferenceTopic(
            topicId: topic.topicId,
            status: newStatus,
            hasCustomRouting: hasCustomRouting,
            customRouting: customRouting
        );

        Courier.log("Topic updated: ${topic.topicId}");

      } catch (error) {

        Courier.log(error.toString());

        if (widget.onError != null) {
          widget.onError!(error.toString());
        }

        _updateTopic(topic.topicId, topic);

      }

    }

  }

  void _updateTopic(String topicId, CourierUserPreferencesTopic newTopic) {

    if (!mounted) return;

    for (int sectionIndex = 0; sectionIndex < _sections.length; sectionIndex++) {
      final section = _sections[sectionIndex];
      final topicIndex = section.topics.indexWhere((topic) => topic.topicId == topicId);
      if (topicIndex != -1) {
        setState(() {
          _sections[sectionIndex].topics[topicIndex] = newTopic;
        });
        return;
      }
    }
  }

  Widget _buildContent(BuildContext context, bool isDarkMode) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: getTheme(isDarkMode).getLoadingColor(context),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              style: getTheme(isDarkMode).getInfoViewTitleStyle(context),
              _userId == null ? 'No User Found' : _error!,
            ),
            const SizedBox(height: 16.0),
            FilledButton(
              style: getTheme(isDarkMode).getInfoViewButtonStyle(context),
              onPressed: () => _retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sections.isEmpty) {
      return Center(
        child: Text(
          style: getTheme(isDarkMode).getInfoViewTitleStyle(context),
          'No preferences found',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: getTheme(isDarkMode).getLoadingColor(context),
            onRefresh: _getPreferences,
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                separatorBuilder: (context, index) => const SizedBox(height: CourierTheme.margin),
                itemCount: _itemCount,
                itemBuilder: (BuildContext context, int index) {
                  return CourierPreferencesSection(
                    mode: widget.mode,
                    theme: getTheme(isDarkMode),
                    section: _sections[index],
                    onTopicClick: (topic) => _showTopicSheet(context, isDarkMode, topic),
                  );
                },
              ),
            ),
          ),
        ),
        CourierFooter(shouldShow: _brand?.settings?.inapp?.showCourierFooter ?? true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipRect(
      child: CourierThemeBuilder(builder: (context, constraints, isDarkMode) {
        return _buildContent(context, isDarkMode);
      }),
    );
  }

  @override
  void dispose() {
    // Dispose the default controller
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    super.dispose();
  }
}
