import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/inbox_feed.dart';
import 'package:courier_flutter/ui/courier_footer.dart';
import 'package:courier_flutter/ui/courier_theme_builder.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'courier_inbox_list_item.dart';

class CourierInbox extends StatefulWidget {
  // Useful if you are placing your Inbox in a TabView or another widget that will recycle
  final bool keepAlive;

  // The theming for your Inbox
  final CourierInboxTheme _lightTheme;
  final CourierInboxTheme _darkTheme;

  // Actions
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxMessage, int)? onMessageLongPress;
  final Function(InboxAction, InboxMessage, int)? onActionClick;

  // Scroll handling
  final ScrollController feedScrollController;
  final ScrollController archivedScrollController;

  // Swipe behavior
  final bool canSwipePages;

  CourierInbox({
    super.key,
    this.keepAlive = false,
    CourierInboxTheme? lightTheme,
    CourierInboxTheme? darkTheme,
    ScrollController? feedScrollController,
    ScrollController? archivedScrollController,
    this.onMessageClick,
    this.onMessageLongPress,
    this.onActionClick,
    this.canSwipePages = false,
  })  : _lightTheme = lightTheme ?? CourierInboxTheme(),
        _darkTheme = darkTheme ?? CourierInboxTheme(),
        feedScrollController = feedScrollController ?? ScrollController(),
        archivedScrollController = archivedScrollController ?? ScrollController();

  @override
  State<CourierInbox> createState() => CourierInboxState();
}

class CourierInboxState extends State<CourierInbox> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  CourierInboxListener? _inboxListener;
  List<InboxMessage> _feedMessages = [];
  List<InboxMessage> _archivedMessages = [];
  bool _canPaginateFeed = false;
  bool _canPaginateArchived = false;
  bool _isLoading = true;
  String? _error;
  CourierBrand? _brand;
  String? _userId;
  String? _dismissingMessageId;
  
  // Map to store list item states at the top level
  final Map<String, GlobalKey<CourierInboxListItemState>> _listItemStates = {};

  void _handleMessageArchive(InboxMessage message, int index) async {
    _dismissingMessageId = message.messageId;
    
    // Store original state
    final originalFeedMessages = List<InboxMessage>.from(_feedMessages);
    final originalArchivedMessages = List<InboxMessage>.from(_archivedMessages);
    
    // Find index to insert archived message based on timestamp
    if (message.createdAt == null) {
      // If message has no timestamp, insert at beginning
      _archivedMessages.insert(0, message);
    } else {
      int insertIndex = _archivedMessages.indexWhere(
        (m) => m.createdAt?.isBefore(message.createdAt!) ?? false
      );
      if (insertIndex == -1) {
        // If no earlier messages found, add to end
        _archivedMessages.add(message);
      } else {
        // Insert at correct position
        _archivedMessages.insert(insertIndex, message);
      }
    }
    _feedMessages.removeAt(index);
    await dismissItem(message.messageId);

    try {
      await message.markAsArchived();
    } catch (error) {
      Courier.log('Failed to archive message: $error');
      // Reset to original state on error
      setState(() {
        _feedMessages = originalFeedMessages;
        _archivedMessages = originalArchivedMessages;
      });
    }
    
    _dismissingMessageId = null;
  }

  Future<void> dismissItem(String messageId) async {
    if (_listItemStates.containsKey(messageId)) {
      await _listItemStates[messageId]?.currentState?.dismiss();
    }
  }

  Future<void> animateItemIn(String messageId, {SlideDirection direction = SlideDirection.fromRight}) async {
    if (_listItemStates.containsKey(messageId)) {
      await _listItemStates[messageId]?.currentState?.animateIn(direction: direction);
    }
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future _start() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final brand = await _refreshBrand();

    _inboxListener = await Courier.shared.addInboxListener(
      onLoading: (isRefresh) async {
        if (mounted) {
          final userId = await Courier.shared.userId;
          setState(() {
            _userId = userId;
            _brand = brand;
            _isLoading = !isRefresh;
            _error = null;
          });
        }
      },
      onError: (error) async {
        if (mounted) {
          final userId = await Courier.shared.userId;
          setState(() {
            _userId = userId;
            _brand = brand;
            _isLoading = false;
            _error = error;
          });
        }
      },
      onFeedChanged: (messageSet) async {
        if (mounted) {
          final userId = await Courier.shared.userId;
          setState(() {
            _userId = userId;
            _brand = brand;
            _feedMessages = messageSet.messages;
            _canPaginateFeed = messageSet.canPaginate;
            _isLoading = false;
            _error = null;
          });
        }
      },
      onArchiveChanged: (messageSet) {
        if (mounted) {
          setState(() {
            _archivedMessages = messageSet.messages;
            _canPaginateArchived = messageSet.canPaginate;
            _isLoading = false;
            _error = null;
          });
        }
      },
      onMessageChanged: (feed, index, message) async {
        if (mounted && message.messageId != _dismissingMessageId) {
          setState(() {
            if (feed == InboxFeed.feed) {
              if (index >= 0 && index < _feedMessages.length) {
                _feedMessages[index] = message;
              }
            } else {
              if (index >= 0 && index < _archivedMessages.length) {
                _archivedMessages[index] = message;
              }
            }
          });
        }
      },
      onMessageAdded: (feed, index, message) async {
        if (mounted && message.messageId != _dismissingMessageId) {
          setState(() {
            if (feed == InboxFeed.feed) {
              if (index >= 0 && index <= _feedMessages.length) {
                _feedMessages.insert(index, message);
              } else {
                _feedMessages.insert(0, message);
              }
            } else {
              if (index >= 0 && index <= _archivedMessages.length) {
                _archivedMessages.insert(index, message);
              } else {
                _archivedMessages.insert(0, message);
              }
            }
          });
        }
      },
      onMessageRemoved: (feed, index, message) async {
        // if (mounted && message.messageId != _dismissingMessageId) {
        //   setState(() {
        //     if (feed == InboxFeed.feed) {
        //       if (index >= 0 && index < _feedMessages.length) {
        //         _feedMessages.removeAt(index);
        //       }
        //     } else {
        //       if (index >= 0 && index < _archivedMessages.length) {
        //         _archivedMessages.removeAt(index);
        //       }
        //     }
        //   });
        // }
      },
    );
  }

  Future<CourierBrand?> _refreshBrand() async {
    if (!mounted) return null;

    try {
      Brightness currentBrightness = PlatformDispatcher.instance.platformBrightness;
      final brandId = currentBrightness == Brightness.dark
          ? widget._darkTheme.brandId
          : widget._lightTheme.brandId;

      if (brandId == null) {
        widget._lightTheme.brand = null;
        widget._darkTheme.brand = null;
        return null;
      }

      final client = await Courier.shared.client;
      final res = await client?.brands.getBrand(brandId: brandId);
      final brand = res?.data?.brand;
      widget._lightTheme.brand = brand;
      widget._darkTheme.brand = brand;
      return brand;
    } catch (error) {
      Courier.log(error.toString());
      widget._lightTheme.brand = null;
      widget._darkTheme.brand = null;
      return null;
    }
  }

  void _disposeScrollControllers() {
    if (widget.feedScrollController.hasClients) {
      widget.feedScrollController.dispose();
    }
    if (widget.archivedScrollController.hasClients) {
      widget.archivedScrollController.dispose();
    }
  }

  Future<void> _refresh() async {
    await _refreshBrand();
    await Courier.shared.refreshInbox();
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _refreshBrand();
    await Courier.shared.refreshInbox();
  }

  CourierInboxTheme getTheme(bool isDarkMode) {
    return isDarkMode ? widget._darkTheme : widget._lightTheme;
  }

  Widget _buildContent(BuildContext context, bool isDarkMode, double triggerPoint) {
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

    return Column(
      children: [
        Expanded(
          child: CourierInboxPage(
            feedMessages: _feedMessages,
            archivedMessages: _archivedMessages,
            canPaginateFeed: _canPaginateFeed,
            canPaginateArchived: _canPaginateArchived,
            theme: getTheme(isDarkMode),
            feedScrollController: widget.feedScrollController,
            archivedScrollController: widget.archivedScrollController,
            onMessageClick: widget.onMessageClick,
            onMessageLongPress: widget.onMessageLongPress,
            onActionClick: widget.onActionClick,
            onRefresh: _refresh,
            triggerPoint: triggerPoint,
            canSwipePages: widget.canSwipePages,
            onArchive: _handleMessageArchive,
            listItemStates: _listItemStates,
          ),
        ),
        CourierFooter(
          shouldShow: _brand?.settings?.inapp?.showCourierFooter ?? true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipRect(
      child: CourierThemeBuilder(builder: (context, constraints, isDarkMode) {
        final triggerPoint = constraints.maxHeight / 2;
        return _buildContent(context, isDarkMode, triggerPoint);
      }),
    );
  }

  void _removeInboxListener() {
    if (_inboxListener != null) {
      _inboxListener!.remove().then((_) {
        _inboxListener = null;
      }).catchError((error) {
        Courier.log('Failed to remove inbox listener: $error');
      });
    }
  }

  @override
  void dispose() {
    _disposeScrollControllers();
    _removeInboxListener();
    super.dispose();
  }
}

class CourierInboxPage extends StatefulWidget {
  final List<InboxMessage> feedMessages;
  final List<InboxMessage> archivedMessages;
  final bool canPaginateFeed;
  final bool canPaginateArchived;
  final CourierInboxTheme theme;
  final ScrollController feedScrollController;
  final ScrollController archivedScrollController;
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxMessage, int)? onMessageLongPress;
  final Function(InboxAction, InboxMessage, int)? onActionClick;
  final Future<void> Function() onRefresh;
  final bool canSwipePages;
  final Function(InboxMessage, int)? onArchive;
  final double triggerPoint;
  final Map<String, GlobalKey<CourierInboxListItemState>> listItemStates;

  const CourierInboxPage({
    super.key,
    required this.feedMessages,
    required this.archivedMessages,
    required this.canPaginateFeed,
    required this.canPaginateArchived,
    required this.theme,
    required this.feedScrollController,
    required this.archivedScrollController,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.onRefresh,
    required this.canSwipePages,
    required this.onArchive,
    required this.triggerPoint,
    required this.listItemStates,
  });

  @override
  State<CourierInboxPage> createState() => _CourierInboxPageState();
}

class _CourierInboxPageState extends State<CourierInboxPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _lastSelectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Inbox'),
            Tab(text: 'Archive'),
          ],
          onTap: (index) {
            if (index == _lastSelectedTab) {
              final controller = index == 0 ? widget.feedScrollController : widget.archivedScrollController;
              controller.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              return;
            }
            _lastSelectedTab = index;
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: widget.canSwipePages ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
            children: _buildTabViews(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabViews() {
    return [
      CourierMessageList(
        triggerPoint: widget.triggerPoint,
        messages: widget.feedMessages,
        theme: widget.theme,
        canPaginate: widget.canPaginateFeed,
        scrollController: widget.feedScrollController,
        onMessageClick: widget.onMessageClick,
        onMessageLongPress: widget.onMessageLongPress,
        onActionClick: widget.onActionClick,
        onRefresh: widget.onRefresh,
        feed: InboxFeed.feed,
        canSwipeItems: !widget.canSwipePages,
        onArchive: widget.onArchive,
        listItemStates: widget.listItemStates,
      ),
      CourierMessageList( 
        triggerPoint: widget.triggerPoint,
        messages: widget.archivedMessages,
        theme: widget.theme,
        canPaginate: widget.canPaginateArchived,
        scrollController: widget.archivedScrollController,
        onMessageClick: widget.onMessageClick,
        onMessageLongPress: widget.onMessageLongPress,
        onActionClick: widget.onActionClick,
        onRefresh: widget.onRefresh,
        feed: InboxFeed.archived,
        canSwipeItems: !widget.canSwipePages,
        onArchive: widget.onArchive,
        listItemStates: widget.listItemStates,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class CourierMessageList extends StatefulWidget {
  final List<InboxMessage> messages;
  final CourierInboxTheme theme;
  final bool canPaginate;
  final double triggerPoint;
  final ScrollController scrollController;
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxMessage, int)? onMessageLongPress;
  final Function(InboxAction, InboxMessage, int)? onActionClick;
  final Future<void> Function() onRefresh;
  final InboxFeed feed;
  final bool canSwipeItems;
  final Function(InboxMessage, int)? onArchive;
  final Map<String, GlobalKey<CourierInboxListItemState>> listItemStates;

  const CourierMessageList({
    super.key,
    required this.messages,
    required this.theme,
    required this.canPaginate,
    required this.triggerPoint,
    required this.scrollController,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.onRefresh,
    required this.feed,
    required this.canSwipeItems,
    required this.onArchive,
    required this.listItemStates,
  });

  @override
  State<CourierMessageList> createState() => _CourierMessageListState();
}

class _CourierMessageListState extends State<CourierMessageList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Trigger the pagination
    if (widget.scrollController.offset >= widget.scrollController.position.maxScrollExtent - widget.triggerPoint) {
      Courier.shared.fetchNextInboxPage(feed: widget.feed).then((messages) {
        Courier.log('New Messages Fetched. Count: ${messages.length}');
      });
    }
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index < widget.messages.length) {
      final message = widget.messages[index];
      widget.listItemStates[message.messageId] = widget.listItemStates[message.messageId] ?? GlobalKey<CourierInboxListItemState>();
      Widget listItem = Column(
        children: [
          if (index > 0) widget.theme.separator ?? const SizedBox(),
          VisibilityDetector(
            key: Key(message.messageId),
            onVisibilityChanged: (VisibilityInfo info) {
              if (info.visibleFraction > 0 && !message.isOpened) {
                message.markAsOpened().then((value) {
                  Courier.log('Message opened: ${message.messageId}');
                });
              }
            },
            child: CourierInboxListItem(
              key: widget.listItemStates[message.messageId],
              theme: widget.theme,
              message: message,
              canPerformGestures: widget.canSwipeItems,
              onArchive: (message) => widget.onArchive?.call(message, index),
              onMessageClick: (message) {
                message.markAsClicked();
                widget.onMessageClick?.call(message, index);
              },
              onMessageLongPress: widget.onMessageLongPress != null ? (message) {
                widget.onMessageLongPress?.call(message, index);
              } : null,
              onActionClick: (action) => widget.onActionClick?.call(action, message, index),
            ),
          ),
        ],
      );

      return StatefulBuilder(
        builder: (context, setState) {
          return listItem;
        },
      );
    } else if (index == widget.messages.length && widget.canPaginate) {
      return Container(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: 24, bottom: widget.triggerPoint),
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                  widget.theme.getLoadingColor(context)),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        RefreshIndicator(
          color: widget.theme.getLoadingColor(context),
          onRefresh: widget.onRefresh,
          child: Scrollbar(
            controller: widget.scrollController,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: widget.scrollController,
              itemCount: widget.messages.length + (widget.canPaginate ? 1 : 0),
              itemBuilder: (context, index) => _buildListItem(context, index),
            ),
          ),
        ),
        if (widget.messages.isEmpty)
          Center(
            child: Text(
              style: widget.theme.getInfoViewTitleStyle(context),
              'No messages found',
            ),
          ),
      ],
    );
  }

}
