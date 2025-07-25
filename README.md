
<div align="right">
  <details>
    <summary >🌐 Language</summary>
    <div>
      <div align="center">
        <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=en">English</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=zh-CN">简体中文</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=zh-TW">繁體中文</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=ja">日本語</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=ko">한국어</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=hi">हिन्दी</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=th">ไทย</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=fr">Français</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=de">Deutsch</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=es">Español</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=it">Italiano</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=ru">Русский</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=pt">Português</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=nl">Nederlands</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=pl">Polski</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=ar">العربية</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=fa">فارسی</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=tr">Türkçe</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=vi">Tiếng Việt</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=id">Bahasa Indonesia</a>
        | <a href="https://openaitx.github.io/view.html?user=peterferguson&project=react-native-passkeys&lang=as">অসমীয়া</
      </div>
    </div>
  </details>
</div>

# React Native Passkeys

This is an Expo module to help you create and authenticate with passkeys on iOS, Android & web with the same api. The library aims to stay close to the standard [`navigator.credentials`](https://w3c.github.io/webappsec-credential-management/#framework-credential-management). More specifically, we provide an api for `get` & `create` functions (since these are the functions available cross-platform).

The adaptations we make are simple niceties like providing automatic conversion of base64-url encoded strings to buffer. This is also done to make it easier to pass the values to the native side.

Further niceties include some flag functions that indicate support for certain features.

## Installation

```sh
npx expo install react-native-passkeys
```

## iOS Setup

#### 1. Host an Apple App Site Association (AASA) file

For Passkeys to work on iOS, you'll need to host an AASA file on your domain. This file is used to verify that your app is allowed to handle the domain you are trying to authenticate with. This must be hosted on a site with a valid SSL certificate.

The file should be hosted at:

```
https://<your_domain>/.well-known/apple-app-site-association
```

Note there is no `.json` extension for this file but the format is json. The contents of the file should look something like this:

```json
{
  "webcredentials": {
    "apps": ["<teamID>.<bundleID>"]
  }
}
```

Replace `<teamID>` with your Apple Team ID and `<bundleID>` with your app's bundle identifier.

#### 2. Add Associated Domains

Add the following to your `app.json`:

```json
{
  "expo": {
    "ios": {
      "associatedDomains": ["webcredentials:<your_domain>"]
    }
  }
}
```

Replace `<your_domain>` with the domain you are hosting the AASA file on. For example, if you are hosting the AASA file on `https://example.com/.well-known/apple-app-site-association`, you would add `example.com` to the `associatedDomains` array.

#### 3. Add minimum deployment target

Add the following to your `app.json`:

```json
{
  "expo": {
    "plugins": [
      [
        "expo-build-properties",
        {
          "ios": {
            "deploymentTarget": "15.0"
          }
        }
      ]
    ]
  }
}
```

#### 4. Prebuild and run your app

```sh
npx expo prebuild -p ios
npx expo run:ios # or build in the cloud with EAS
```

## Android Setup

#### 1. Host an `assetlinks.json` File

For Passkeys to work on Android, you'll need to host an `assetlinks.json` file on your domain. This file is used to verify that your app is allowed to handle the domain you are trying to authenticate with. This must be hosted on a site with a valid SSL certificate.

The file should be hosted at:

```
https://<your_domain>/.well-known/assetlinks.json
```

and should look something like this (you can generate this file using the [Android Asset Links Assistant](https://developers.google.com/digital-asset-links/tools/generator)):

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "<package_name>",
      "sha256_cert_fingerprints": ["<sha256_cert_fingerprint>"]
    }
  }
]
```

Replace `<package_name>` with your app's package name and `<sha256_cert_fingerprint>` with your app's SHA256 certificate fingerprint.

#### 2. Modify Expo Build Properties

Next, you'll need to modify the `compileSdkVersion` in your `app.json` to be at least 34.

```json
{
  "expo": {
    "plugins": [
      [
        "expo-build-properties",
        {
          "android": {
            "compileSdkVersion": 34
          }
        }
      ]
    ]
  }
}
```

#### 3. Prebuild and run your app

```sh
npx expo prebuild -p android
npx expo run:android # or build in the cloud with EAS
```
