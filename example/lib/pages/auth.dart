import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_authentication_listener.dart';
import 'package:courier_flutter_sample/auth_preferences.dart';
import 'package:courier_flutter_sample/courier_environment.dart';
import 'package:courier_flutter_sample/example_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  static const _monoStyle = TextStyle(fontFamily: 'monospace', fontSize: 16);
  static const _monoBoldStyle = TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold);

  AuthPreferences? _prefs;
  CourierAuthenticationListener? _authListener;
  CourierEnvironment _selectedEnvironment = CourierEnvironment.production;
  bool _isSaving = false;

  final List<MapEntry<String, String>> _options = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await AuthPreferences.create();

    final listener = await Courier.shared.addAuthenticationListener((_) {
      if (mounted) setState(() {});
    });

    setState(() {
      _prefs = prefs;
      _authListener = listener;
    });

    _initOptions();
  }

  void _initOptions() {
    final prefs = _prefs;
    if (prefs == null) return;

    const defaults = CourierEnvironment.defaultUrls;
    final envName = prefs.environment ?? CourierEnvironment.production.label;
    _selectedEnvironment = CourierEnvironment.fromLabel(envName);

    _options
      ..clear()
      ..addAll([
        MapEntry('Environment', _selectedEnvironment.label),
        MapEntry('User ID', prefs.userId ?? ''),
        MapEntry('Tenant ID (Optional)', prefs.tenantId ?? ''),
        MapEntry('API Key', prefs.apiKey),
        MapEntry('REST URL', prefs.restUrl ?? defaults.rest),
        MapEntry('GraphQL URL', prefs.graphqlUrl ?? defaults.graphql),
        MapEntry('Inbox GraphQL URL', prefs.inboxGraphqlUrl ?? defaults.inboxGraphql),
        MapEntry('Inbox WebSocket', prefs.inboxWebSocketUrl ?? defaults.inboxWebSocket),
      ]);

    setState(() {});
  }

  bool get _saveEnabled => !_isSaving && (_options.length > 1 && _options[1].value.isNotEmpty);

  Future<void> _performSave() async {
    setState(() => _isSaving = true);

    try {
      if (await Courier.shared.userId != null) {
        await Courier.shared.signOut();
      }
      await _performSignIn();
    } catch (e) {
      if (mounted) _showErrorDialog(e.toString());
    }

    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _performSignIn() async {
    final userId = _options[1].value;
    final tenantId = _options[2].value.isEmpty ? null : _options[2].value;
    final apiKey = _options[3].value;

    if (userId.isEmpty) {
      await Courier.shared.signOut();
      return;
    }

    final jwt = await ExampleServer.generateJwt(
      authKey: apiKey,
      userId: userId,
      baseUrl: _options[4].value,
    );

    await Courier.shared.signIn(
      userId: userId,
      tenantId: tenantId,
      accessToken: jwt,
      backendUrls: CourierBackendUrls(
        rest: _options[4].value,
        graphql: _options[5].value,
        inboxGraphql: _options[6].value,
        inboxWebSocket: _options[7].value,
      ),
    );
  }

  void _onRowTapped(int index) {
    if (index == 0) {
      _showEnvironmentPicker();
    } else if (index >= 1 && index <= 3) {
      _showEditDialog(index);
    } else if (index >= 4 && _selectedEnvironment != CourierEnvironment.custom) {
      _copyToClipboard(_options[index].value);
    } else if (index >= 4) {
      _showEditDialog(index);
    }
  }

  void _showEnvironmentPicker() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Environment'),
        children: CourierEnvironment.values.map((env) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _applyEnvironment(env);
            },
            child: Row(
              children: [
                Icon(
                  env == _selectedEnvironment ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(env.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _applyEnvironment(CourierEnvironment env) {
    _selectedEnvironment = env;
    _options[0] = MapEntry(_options[0].key, env.label);
    _prefs?.environment = env.label;

    final urls = env.urls;
    if (urls != null) {
      _options[4] = MapEntry(_options[4].key, urls.rest);
      _options[5] = MapEntry(_options[5].key, urls.graphql);
      _options[6] = MapEntry(_options[6].key, urls.inboxGraphql);
      _options[7] = MapEntry(_options[7].key, urls.inboxWebSocket);
      _prefs?.saveApiUrls(urls);
    }

    setState(() {});
  }

  void _showEditDialog(int row) {
    final title = _options[row].key;
    final currentValue = _options[row].value;
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(hintText: title),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final text = controller.text;
              if (text.isNotEmpty) _copyToClipboard(text);
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _applyEdit(row, controller.text);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _applyEdit(int row, String value) {
    _options[row] = MapEntry(_options[row].key, value);

    switch (row) {
      case 1:
        _prefs?.userId = value;
        break;
      case 2:
        _prefs?.tenantId = value;
        break;
      case 3:
        _prefs?.apiKey = value;
        break;
      case 4:
        _prefs?.restUrl = value;
        break;
      case 5:
        _prefs?.graphqlUrl = value;
        break;
      case 6:
        _prefs?.inboxGraphqlUrl = value;
        break;
      case 7:
        _prefs?.inboxWebSocketUrl = value;
        break;
    }

    if (row >= 4 && _selectedEnvironment != CourierEnvironment.custom) {
      _selectedEnvironment = CourierEnvironment.custom;
      _options[0] = MapEntry(_options[0].key, CourierEnvironment.custom.label);
      _prefs?.environment = CourierEnvironment.custom.label;
    }

    setState(() {});
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData? _accessoryIcon(int index) {
    if (index == 0) return Icons.edit;
    if (index >= 4 && _selectedEnvironment != CourierEnvironment.custom) return Icons.copy;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Auth'),
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: _saveEnabled ? _performSave : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _saveEnabled ? Colors.white : Colors.white38,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _options.length,
        itemBuilder: (context, index) {
          final key = _options[index].key;
          final value = _options[index].value;
          final displayValue = value.isEmpty ? 'NOT SET' : value;
          final icon = _accessoryIcon(index);

          return InkWell(
            onTap: () => _onRowTapped(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(key, style: _monoBoldStyle),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      displayValue,
                      style: _monoStyle,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 12),
                    Icon(icon, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _authListener?.remove();
    super.dispose();
  }
}
