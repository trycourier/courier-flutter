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
                <code>15.0</code>
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

### 1. Support iOS 15.0+ in your Project

<img width="470" alt="Screenshot 2025-01-21 at 12 55 34 PM" src="https://github.com/user-attachments/assets/ee7722b2-ce6a-4dc4-8b30-94f42494d80a" />

Update your deployment target to iOS 15

### 2. Install the Cocoapod

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

### 3. Gradle Sync

Your app must support at least gradle `8.4`

&emsp;

# Getting Started

These are all the available features of the SDK.

<table>
    <thead>
        <tr>
            <th width="25px"></th>
            <th width="250px" align="left">Feature</th>
            <th width="725px" align="left">Description</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="center">
                1
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/1_Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Manages user credentials between app sessions. Required if you would like to use <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/2_Inbox.md"><code>Inbox</code></a>, <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/3_PushNotifications.md"><code>Push Notifications</code></a> and <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/4_Preferences.md"><code>Preferences</code></a>.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                2
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/2_Inbox.md">
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
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/3_PushNotifications.md">
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
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/4_Preferences.md">
                    <code>Preferences</code>
                </a>
            </td>
            <td align="left">
                Allow users to update which types of notifications they would like to receive.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                5
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/5_Client.md">
                    <code>CourierClient</code>
                </a>
            </td>
            <td align="left">
                The base level API wrapper around the Courier endpoints. Useful if you have a highly customized user experience or codebase requirements.
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

[Courier Flutter Issues](https://github.com/trycourier/courier-flutter/issues)

