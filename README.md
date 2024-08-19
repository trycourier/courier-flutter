<img width="1040" alt="banner-flutter" src="https://github.com/user-attachments/assets/e7164275-cb8c-45b3-8d12-5dacfae5ec5e">

&emsp;

# Requirements & Support

<table>
    <thead>
        <tr>
            <th width="940px" align="left">Requirements</th>
            <th width="120px" align="center"></th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">Courier Account</td>
            <td align="center">
                <a href="https://app.courier.com/channels/courier">
                    <code>Sign Up</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Minimum iOS SDK Version</td>
            <td align="center">
                <code>13.0</code>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Minimum Android SDK Version</td>
            <td align="center">
                <code>23</code>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Installation

Run the following command at your project's root directory:

```
flutter pub add courier_flutter
```

&emsp;

## **iOS Setup**

### 1. Support iOS 13.0+ in your Project

<img width="512" alt="Screenshot 2023-11-17 at 11 26 01 AM" src="https://github.com/trycourier/courier-flutter/assets/6370613/3a00d399-6de7-44fe-810e-b87f8d48841a">

Update your deployment target to iOS 13

### 2. Install the Cocoapods

From the root of your project run

```sh
cd ios && pod install
```

&emsp;

## **Android Setup**

### 1. Add the Jitpack repository

In your `android/build.gradle` make sure your build and repository values are as follows

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' } // Add this line
    }
}
```

### 2. Support Proper SDK Version

In your `app/build.gradle` update these values

```gradle
minSdkVersion 23
targetSdkVersion 33+
compileSdkVersion 33+
```

### 3. Run Gradle Sync

&emsp;

# Getting Started

These are all the available features of the SDK.

<table>
    <thead>
        <tr>
            <th width="25px"></th>
            <th width="250px" align="left">Feature</th>
            <th width="750px" align="left">Description</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="center">
                1
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Manages user credentials between app sessions. Required if you would like to use <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Inbox.md"><code>Inbox</code></a>, <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/PushNotifications.md"><code>Push Notifications</code></a> and <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Preferences.md"><code>Preferences</code></a>.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                2
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Inbox.md">
                    <code>Inbox</code>
                </a>
            </td>
            <td align="left">
                An in-app notification center you can use to notify your users. Comes with a prebuilt UI and also supports fully custom UIs.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                3
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/PushNotifications.md">
                    <code>Push Notifications</code>
                </a>
            </td>
            <td align="left">
                Automatically manages push notification device tokens and gives convenient functions for handling push notification receiving and clicking.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                4
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Preferences.md">
                    <code>Preferences</code>
                </a>
            </td>
            <td align="left">
                Allow users to update which types of notifications they would like to receive.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Example Projects

<table>
    <thead>
        <tr>
            <th width="1100px" align="left">Project Link</th>
        </tr>
    </thead>
    <tbody>
        <tr width="1100px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/tree/master/example">
                    <code>Example</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# **Share feedback with Courier**

We want to make this the best SDK for managing notifications! Have an idea or feedback about our SDKs? Here are some links to contact us:

- [Courier Feedback](https://feedback.courier.com/)
- [Courier Flutter Issues](https://github.com/trycourier/courier-flutter/issues)

