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
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Authentication.md">
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
import Courier_iOS

// Create the view
let courierPreferences = CourierPreferences(
    mode: .topic,
    onError: { error in
        print(error.localizedDescription)
    }
)

// Add the view to your UI
courierPreferences.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(courierPreferences)

// Constrain the view how you'd like
NSLayoutConstraint.activate([
    courierPreferences.topAnchor.constraint(equalTo: view.topAnchor),
    courierPreferences.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    courierPreferences.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    courierPreferences.trailingAnchor.constraint(equalTo: view.trailingAnchor),
])
```

&emsp;

## Styled Preferences View

The styles you can use to quickly customize the `CourierPreferences`.

<img width="296" alt="default-inbox-styles" src="https://github.com/trycourier/courier-flutter/assets/6370613/116cb22c-5a3c-4eb3-bd14-c3137cb8a2ab">

```swift
import Courier_iOS

let textColor = UIColor(red: 42 / 255, green: 21 / 255, blue: 55 / 255, alpha: 100)
let primaryColor = UIColor(red: 136 / 255, green: 45 / 255, blue: 185 / 255, alpha: 100)
let secondaryColor = UIColor(red: 234 / 255, green: 104 / 255, blue: 102 / 255, alpha: 100)

// Theme object containing all the styles you want to apply 
let preferencesTheme = CourierPreferencesTheme(
    brandId: "7S9R...3Q1M", // Optional. Theme colors will override this brand.
    loadingIndicatorColor: secondaryColor,
    sectionTitleFont: CourierStyles.Font(
        font: UIFont(name: "Avenir Black", size: 20)!,
        color: .white
    ),
    topicCellStyles: CourierStyles.Cell(
        separatorStyle: .none
    ),
    topicTitleFont: CourierStyles.Font(
        font: UIFont(name: "Avenir Medium", size: 18)!,
        color: .white
    ),
    topicSubtitleFont: CourierStyles.Font(
        font: UIFont(name: "Avenir Medium", size: 16)!,
        color: .white
    ),
    topicButton: CourierStyles.Button(
        font: CourierStyles.Font(
            font: UIFont(name: "Avenir Medium", size: 16)!,
            color: .white
        ),
        backgroundColor: secondaryColor,
        cornerRadius: 8
    ),
    sheetTitleFont: CourierStyles.Font(
        font: UIFont(name: "Avenir Medium", size: 18)!,
        color: .white
    ),
    sheetSettingStyles: CourierStyles.Preferences.SettingStyles(
        font: CourierStyles.Font(
            font: UIFont(name: "Avenir Medium", size: 18)!,
            color: .white
        ),
        toggleColor: secondaryColor
    ),
    sheetCornerRadius: 0,
    sheetCellStyles: CourierStyles.Cell(
        separatorStyle: .none
    )
)

// Pass the theme to the view
let courierPreferences = CourierPreferences(
    mode: .channels([.push, .sms, .email]),
    lightTheme: preferencesTheme,
    darkTheme: preferencesTheme,
    onError: { error in
        print(error.localizedDescription)
    }
)

view.addSubview(courierPreferences)
...
```

If you are interested in using a Courier "Brand", here is where you can adjust that: [`Courier Studio`](https://app.courier.com/designer/brands). 

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

&emsp;

## Custom Preferences APIs

The raw data you can use to build whatever UI you'd like.

# Get All User Preferences

Returns all the user's preferences. [`listAllUserPreferences`](https://www.courier.com/docs/reference/user-preferences/list-all-user-preferences/)

```dart
// paginationCursor is optional
final preferences = await Courier.shared.getUserPreferences(paginationCursor: cursor);
```

&emsp;

# Update Preference Topic

Updates a specific user preference topic. [`updateUserSubscriptionTopic`](https://www.courier.com/docs/reference/user-preferences/update-subscription-topic-preferences/)

```dart
await Courier.shared.putUserPreferencesTopic(
  topicId: 'your_topic_id',
  status: CourierUserPreferencesStatus.optedIn,
  hasCustomRouting: true,
  customRouting: [CourierUserPreferencesChannel.push]
);
```

&emsp;

# Get Preference Topic

Gets a specific preference topic. [`getUserSubscriptionTopic`](https://www.courier.com/docs/reference/user-preferences/get-subscription-topic-preferences/)

```dart
final topic = await Courier.shared.getUserPreferencesTopic(topicId: 'your_topic_id');
```
