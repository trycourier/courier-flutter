import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/inbox_feed.dart';
import 'package:courier_flutter/ui/courier_footer.dart';
import 'package:courier_flutter/ui/courier_theme_builder.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_pagination_item.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'courier_inbox_list_item.dart';
import 'package:courier_flutter/utils.dart';

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

class CourierInboxState extends State<CourierInbox> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  CourierInboxListener? _inboxListener;
  List<InboxMessage> _feedMessages = [];
  List<InboxMessage> _archivedMessages = [];
  bool _canPaginateFeed = false;
  bool _canPaginateArchived = false;
  bool _isFeedPaginating = false;
  bool _isArchivedPaginating = false;
  bool _isLoading = true;
  String? _error;
  CourierBrand? _brand;
  String? _dismissingMessageId;
  late TabController _tabController;
  late PageController _pageController;
  int _lastSelectedTab = 0;
  
  // Map to store list item states at the top level
  final GlobalKey<CourierMessageListState> _feedListKey = GlobalKey<CourierMessageListState>();
  final GlobalKey<CourierMessageListState> _archivedListKey = GlobalKey<CourierMessageListState>();
  // final Map<String, GlobalKey<CourierInboxListItemState>> _listItemKeys = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _start();
  }

  Future<void> _handleMessageArchive(InboxMessage message, int index) async {
    _dismissingMessageId = message.messageId;
    
    // Store original state
    final originalFeedMessages = List<InboxMessage>.from(_feedMessages);
    final originalArchivedMessages = List<InboxMessage>.from(_archivedMessages);
    
    // Update messages
    _insertArchivedMessage(message);
    _feedMessages.removeAt(index);

    // Perform archive
    try {
      await message.markAsArchived();
      _dismissingMessageId = null;
    } catch (error) {
      Courier.log('Failed to archive message: $error');
      setState(() {
        _feedMessages = originalFeedMessages;
        _archivedMessages = originalArchivedMessages;
      });
      _dismissingMessageId = null;
      rethrow;
    }

  }

  void _insertArchivedMessage(InboxMessage message) {
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
  }

  // Future<void> addMessageAtIndex(GlobalKey<AnimatedListState> listKey, InboxMessage message, int index) async {
  //   await listKey.currentState?.insertItemAwaitable(index, duration: const Duration(milliseconds: 400));
  //   setState(() {});
  // }

  // Future<void> removeMessageAtIndex(GlobalKey<AnimatedListState> listKey, InboxMessage message, int index) async {
  //   Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
  //   final isDarkMode = currentBrightness == Brightness.dark;
  //   await listKey.currentState?.removeItemAwaitable(index, (context, animation) {
  //     return SizeTransition(
  //       sizeFactor: animation.drive(
  //         CurveTween(curve: Curves.easeInOutCubic),
  //       ),
  //       child: CourierInboxListItem(
  //         theme: getTheme(isDarkMode),
  //         message: message,
  //         canPerformGestures: false,
  //         onMessageIsVisible: () {},
  //         onMessageClick: (message) {},
  //         onMessageLongPress: null,
  //         onActionClick: (action) => {},
  //         onSwipeArchiveTrigger: (message) => {},
  //         onSwipeArchiveComplete: (message) => {},
  //         onArchiveButtonTrigger: (message) => {},
  //       ),
  //     );
  //   }, duration: const Duration(milliseconds: 300));
  //   setState(() {});
  // }

  Future _start() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final brand = await _refreshBrand();

    _inboxListener = await Courier.shared.addInboxListener(
      onLoading: (isRefresh) {
        if (mounted) {
          setState(() {
            _brand = brand;
            if (!isRefresh) {
              _isLoading = true;
            }
            _error = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _brand = brand;
            _isLoading = false;
            _error = error;
          });
        }
      },
      onFeedChanged: (messageSet) async {
        if (mounted) {
          setState(() {
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
      onPageAdded: (feed, messageSet) {
        if (mounted) {
          if (feed == InboxFeed.feed) {
            setState(() {
              _feedMessages = [..._feedMessages, ...messageSet.messages];
              _canPaginateFeed = messageSet.canPaginate;
              _isFeedPaginating = false;
            });
          } else {
            setState(() {
              _archivedMessages = [..._archivedMessages, ...messageSet.messages];
              _canPaginateArchived = messageSet.canPaginate;
              _isArchivedPaginating = false;
            });
          }
        }
      },
      onMessageChanged: (feed, index, message) async {
        if (mounted && message.messageId != _dismissingMessageId) {
          if (feed == InboxFeed.feed) {
            if (index >= 0 && index < _feedMessages.length) {
              await _feedListKey.currentState?.reloadMessageAtIndex(message, index);
            }
          } else {
            if (index >= 0 && index < _archivedMessages.length) {
              await _archivedListKey.currentState?.reloadMessageAtIndex(message, index);
            }
          }
        }
      },
      onMessageAdded: (feed, index, message) async {
        if (mounted && message.messageId != _dismissingMessageId) {
          if (feed == InboxFeed.feed) {
            if (index >= 0 && index <= _feedMessages.length) {
              await _feedListKey.currentState?.addMessageAtIndex(message, index);
            } else {
              await _feedListKey.currentState?.addMessageAtIndex(message, 0);
            }
          } else {
            if (index >= 0 && index <= _archivedMessages.length) {
              await _archivedListKey.currentState?.addMessageAtIndex(message, index);
            } else {
              await _archivedListKey.currentState?.addMessageAtIndex(message, 0);
            }
          }
        }
      },
      onMessageRemoved: (feed, index, message) async {
        if (mounted && message.messageId != _dismissingMessageId) {
          if (feed == InboxFeed.feed) {
            if (index >= 0 && index < _feedMessages.length) {
              await _feedListKey.currentState?.removeMessageAtIndex(index);
            }
          } else {
            if (index >= 0 && index < _archivedMessages.length) {
              await _archivedListKey.currentState?.removeMessageAtIndex(index);
            }
          }
        }
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

  Future<void> _fetchNextPage(InboxFeed feed) async {
    // Check if already paginating for this feed
    if ((feed == InboxFeed.feed && _isFeedPaginating) || 
        (feed == InboxFeed.archived && _isArchivedPaginating)) {
      return;
    }

    setState(() {
      if (feed == InboxFeed.feed) {
        _isFeedPaginating = true;
      } else {
        _isArchivedPaginating = true;
      }
    });

    try {
      final messageSet = await Courier.shared.fetchNextInboxPage(feed: feed);
      Courier.log('New Messages Fetched. Count: ${messageSet?.messages.length ?? 0}');
    } catch (error) {
      Courier.log('Failed to fetch next page: $error');
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

  List<Widget> _buildTabViews(bool isDarkMode, double triggerPoint) {
    return [
      CourierMessageList(
        key: _feedListKey,
        triggerPoint: triggerPoint,
        messages: _feedMessages,
        theme: getTheme(isDarkMode),
        canPaginate: _canPaginateFeed,
        scrollController: widget.feedScrollController,
        onMessageClick: widget.onMessageClick,
        onMessageLongPress: widget.onMessageLongPress,
        onActionClick: widget.onActionClick,
        onRefresh: _refresh,
        feed: InboxFeed.feed,
        canSwipeItems: !widget.canSwipePages,
        onSwipeArchiveTrigger: _handleMessageArchive,
        onSwipeArchiveComplete: (message, index) => setState(() {}),
        onArchiveButtonTrigger: (message, index) async {
          try {
            await _handleMessageArchive(message, index);
            // await _listItemKeys[message.messageId]?.currentState?.dismiss();
          } catch (error) {
            Courier.log('Failed to archive message: $error');
          }
        },
        isPaginating: _isFeedPaginating,
        onPaginationTriggered: () => _fetchNextPage(InboxFeed.feed),
      ),
      CourierMessageList(
        key: _archivedListKey,
        triggerPoint: triggerPoint,
        messages: _archivedMessages,
        theme: getTheme(isDarkMode),
        canPaginate: _canPaginateArchived,
        scrollController: widget.archivedScrollController,
        onMessageClick: widget.onMessageClick,
        onMessageLongPress: widget.onMessageLongPress,
        onActionClick: widget.onActionClick,
        onRefresh: _refresh,
        feed: InboxFeed.archived,
        canSwipeItems: !widget.canSwipePages,
        onSwipeArchiveTrigger: _handleMessageArchive,
        onSwipeArchiveComplete: (message, index) => setState(() {}),
        onArchiveButtonTrigger: (message, index) async {
          try {
            await _handleMessageArchive(message, index);
            // await _listItemKeys[message.messageId]?.currentState?.dismiss();
          } catch (error) {
            Courier.log('Failed to archive message: $error');
          }
        },
        isPaginating: _isArchivedPaginating,
        onPaginationTriggered: () => _fetchNextPage(InboxFeed.archived),
      ),
    ];
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
              _error!,
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
            children: _buildTabViews(isDarkMode, triggerPoint),
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
  final Function(InboxMessage, int) onSwipeArchiveTrigger;
  final Function(InboxMessage, int) onSwipeArchiveComplete;
  final Function(InboxMessage, int) onArchiveButtonTrigger;
  final bool isPaginating;
  final Function() onPaginationTriggered;

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
    required this.onSwipeArchiveTrigger,
    required this.onSwipeArchiveComplete,
    required this.onArchiveButtonTrigger,
    required this.isPaginating,
    required this.onPaginationTriggered,
  });

  @override
  State<CourierMessageList> createState() => CourierMessageListState();
}

class CourierMessageListState extends State<CourierMessageList> with AutomaticKeepAliveClientMixin {
  final Map<String, GlobalKey<CourierInboxListItemState>> _listItemKeys = {};

  @override
  bool get wantKeepAlive => true;

  Future<void> addMessageAtIndex(InboxMessage message, int index) async {
    setState(() {
      widget.messages.insert(index, message);
      _listItemKeys[message.messageId] = GlobalKey<CourierInboxListItemState>();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _listItemKeys[message.messageId]?.currentState?.enter();
    });
  }

  Future<void> removeMessageAtIndex(int index) async {
    final message = widget.messages[index];
    await _listItemKeys[message.messageId]?.currentState?.dismiss();
    setState(() {
      widget.messages.removeAt(index);
      _listItemKeys.remove(message.messageId);
    });
  }

  Future<void> reloadMessageAtIndex(InboxMessage message, int index) async {
    setState(() {
      widget.messages[index] = message;
    });
  }

  Widget _buildMessageItem(BuildContext context, InboxMessage message, int index) {
    // Create key if it doesn't exist
    _listItemKeys.putIfAbsent(message.messageId, () => GlobalKey<CourierInboxListItemState>());

    return Column(
      children: [
        if (index > 0) widget.theme.separator ?? const SizedBox(),
        CourierInboxListItem(
          key: _listItemKeys[message.messageId],
          theme: widget.theme,
          message: message,
          canPerformGestures: widget.canSwipeItems,
          onMessageIsVisible: () {
            message.markAsOpened().then((value) {
              Courier.log('Message opened: ${message.messageId}');
            });
          },
          onMessageClick: (message) {
            message.markAsClicked();
            widget.onMessageClick?.call(message, index);
          },
          onMessageLongPress: widget.onMessageLongPress != null ? (message) => widget.onMessageLongPress?.call(message, index) : null,
          onActionClick: (action) => widget.onActionClick?.call(action, message, index),
          onReadGesture: (message) {
            message.isRead ? message.markAsUnread() : message.markAsRead();
          },
          onArchiveGesture: (message) {
            message.markAsArchived();
          },
        )
      ],
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index < widget.messages.length) {
      return _buildMessageItem(context, widget.messages[index], index);
    } else if (index == widget.messages.length && widget.canPaginate) {
      return CourierInboxPaginationItem(
        isPaginating: widget.isPaginating,
        canPaginate: widget.canPaginate,
        onPaginationTriggered: widget.onPaginationTriggered,
        triggerPoint: widget.triggerPoint,
        loadingColor: widget.theme.getLoadingColor(context),
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
