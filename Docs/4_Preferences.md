<img width="1040" alt="banner-flutter-preferences" src="https://github.com/trycourier/courier-flutter/assets/6370613/29da0de2-bd74-4ed8-9245-ebbe1d74ff19">

# Courier Preferences

Allow users to update which types of notifications they would like to receive.

## Requirements

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Requirement</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/1_Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Needed to view preferences that belong to a user.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## Default Preferences View

The default `CourierPreferences` styles.

<img width="296" alt="default-preference-styles" src="https://github.com/trycourier/courier-flutter/assets/6370613/522caa39-7c62-434b-add3-fa9b2eb5dfcf">

```swift
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';

...

@override
Widget build(BuildContext context) {
  return CourierPreferences(
    mode: TopicMode(),
  );
}
```

&emsp;

## Styled Preferences View

The styles you can use to quickly customize the `CourierPreferences`.

<img width="296" alt="default-inbox-styles" src="https://github.com/trycourier/courier-flutter/assets/6370613/116cb22c-5a3c-4eb3-bd14-c3137cb8a2ab">

```swift
import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';

...

final customTheme = CourierPreferencesTheme(
  brandId: "YOUR_BRAND_ID",
  topicSeparator: null,
  sectionTitleStyle: GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Color(0xFF9747FF),
  ),
  topicTitleStyle: GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.normal,
    fontSize: 18,
  ),
  topicSubtitleStyle: GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.normal,
    fontSize: 16,
  ),
  topicTrailing: const Icon(
    Icons.edit_outlined,
    color: Colors.black45,
  ),
  sheetSeparator: null,
  sheetTitleStyle: GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Color(0xFF9747FF),
  ),
  sheetSettingStyles: SheetSettingStyles(
    textStyle: GoogleFonts.sen().copyWith(
      fontWeight: FontWeight.normal,
      fontSize: 18,
    ),
    activeTrackColor: Color(0xFF9747FF),
    activeThumbColor: Colors.white,
    inactiveTrackColor: Colors.black45,
    inactiveThumbColor: Colors.white,
  ),
  sheetShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(16.0),
    ),
  ),
  infoViewStyle: CourierInfoViewStyle(
    textStyle: GoogleFonts.sen().copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    buttonStyle: FilledButton.styleFrom(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    ),
  ),
);

...

@override
Widget build(BuildContext context) {
  return CourierPreferences(
    // keepAlive: true, // Useful if you are adding this widget to a TabBarView
    lightTheme: customTheme,
    darkTheme: customTheme,
    mode: ChannelsMode(channels: [CourierUserPreferencesChannel.push, CourierUserPreferencesChannel.sms, CourierUserPreferencesChannel.email]),
    onError: (error) => print(error),
  );
}
```

&emsp;

### Courier Studio Branding (Optional)

<img width="782" alt="setting" src="https://user-images.githubusercontent.com/6370613/228931428-04dc2130-789a-4ac3-bf3f-0bbb49d5519a.png">

You can control your branding from the [`Courier Studio`](https://app.courier.com/designer/brands).

<table>
    <thead>
        <tr>
            <th width="850px" align="left">Supported Brand Styles</th>
            <th width="200px" align="center">Support</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left"><code>Primary Color</code></td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left"><code>Show/Hide Courier Footer</code></td>
            <td align="center">✅</td>
        </tr>
    </tbody>
</table>

---

👋 `Branding APIs` can be found <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/5_Client.md#branding-apis"><code>here</code></a>

👋 `Preference APIs` can be found <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/5_Client.md#preferences-apis"><code>here</code></a>
