
## 5.0.1

- Release courier_flutter 5.0.1
- Align ExampleService with courier-android 6.1.0 and bump example build
- Bump courier-android to 6.1.0
- chore(example): clarify ExampleService demo vs. Courier integration comments
- Update Android push notification docs to use named args
- Bump example app version to 1.0.0+30
- Simplify deploy workflow

## v5.0.0

- Add 5.0.0 entry to CHANGELOG.md
- Upgrade actions/checkout from v5 to v6
- Restore CHANGELOG commit step in deploy workflow
- Fix deploy workflow: remove direct push to protected main branch
- Update docs Firebase BOM version to match example app
- Fix duplicate push notification click events on Android
- Bump courier-android to 6.0.0 and remove bundled Firebase dependency
- Android example: load signing files from shared flutter keystore folder.

## v4.3.2

- Update CHANGELOG.md for 4.3.2 [skip ci]
- Deploy: use v-prefixed tags for pub.dev OIDC allowlist

## 4.3.2

- Update CHANGELOG.md for 4.3.2 [skip ci]
- Deploy: trigger pub.dev publish from tag-dispatch run
- Update CHANGELOG.md for 4.3.2 [skip ci]
- Deploy: checkout tag ref for publish so CHANGELOG is included
- Update CHANGELOG.md for 4.3.2 [skip ci]
- Retrigger deploy for 4.3.2
- Fix CHANGELOG generation to include current version entry
- Update CHANGELOG.md for 4.3.2 [skip ci]
- Bump version to 4.3.2 and simplify deploy workflow

## 4.3.1

- Update CHANGELOG.md for 4.3.1 [skip ci]
- Deploy: publish from tag ref to satisfy pub.dev OIDC requirements
- Deploy: add [skip ci] to CHANGELOG commit to prevent re-trigger loop
- Update CHANGELOG.md for 4.3.1
- Deploy: auto-generate CHANGELOG.md from git tags at release time
- Add CHANGELOG.md for pub.dev publishing
- Deploy: use official dart-lang publish workflow for OIDC auth
- Retrigger deploy for 4.3.1
- Deploy: use OIDC for pub.dev auth instead of token
- Trigger deploy for 4.3.1
- Fix deploy: write pub token without heredoc whitespace issues
- Bump version to 4.3.1
- Rewrite update_version.sh to use gum, matching Android style
- Track example devtools_options.yaml
- Consolidate update_version.sh and update_native_plugin_version.sh
- Deploy: use pub token for pub.dev authentication
- CI: remove push-to-main trigger to match Android
- CI: specify test files explicitly to avoid running helper files
- CI: run all integration tests in a single build pass
- Implement feedMessages and archivedMessages on Dart and iOS
- CI: pass --no-fatal-infos to flutter analyze
- Fix CI: use string concatenation instead of f-strings to avoid dict/set confusion
- CI: generate real firebase_options.dart and google-services.json from secrets
- Fix CI: generate env.dart and firebase_options.dart before analyze
- Add CI/CD workflows and clean up scripts for Android parity
- feat: EU API/backend URLs and iOS 15 minimum
- Add Android example signing aligned with courier-android-keystores/native_android
- Bump courier-android to 5.3.0
- Bump Courier_iOS to 5.8.0

## 4.2.0

- Bump
- SUP-604 Widen intl dependency to support Flutter 3.32+
- docs: sync README from mintlify-docs (2026-03-23 19:10 UTC)
- Add deprecation notices to Docs/ and update README links
- Add AUTO-GENERATED-OVERVIEW markers to README

## 4.1.8

- 🚀 4.1.8
- Remove GoogleService-Info.plist from tracking - file should remain gitignored

## 4.1.7

- 🚀 4.1.7
- Added test trigger on push request
- Bump
- Android
- New android bundle
- Update README.md
- Run SDK app tests on push to master on mobile

## 4.1.6

- 🚀 4.1.6

## 4.1.5

- 🚀 4.1.5

## 4.1.4

- 🚀 4.1.4

## 4.1.3

- 🚀 4.1.3

## 4.1.2

- 🚀 4.1.2
- Set proper read message style in semantics label

## 4.1.1

- 🚀 4.1.1
- MERGE and FCM upgrade
- Move semantic labels to widget extensions
- Add SemanticProperties class
- Move semantics label functions to utils
- Expose more UI element attribute values in Semantics component
- Expose UI element attribute values in Semantics component
- Update 3_PushNotifications.md
- Update 3_PushNotifications.md
- Update 3_PushNotifications.md
- Update 3_PushNotifications.md
- Update 2_Inbox.md
- Update 2_Inbox.md
- Markdown files
- Update Inbox.md

## 4.1.0

- 🚀 4.1.0
- 🚀
- Pagination fix
- Working through pagination
- Android building
- Inbox page
- Custom error messages
- Custom error message
- Better error handling
- Show footer flag
- Pagination
- Inbox View Updates
- iOS Updates

## 4.0.3

- 🚀 4.0.3
- Update README.md
- Update README.md
- Update README.md

## 4.0.2

- 🚀 4.0.2
- Android namespace
- Fullscreen Inbox example
- Update Inbox.md
- Update Inbox.md
- Update Inbox.md
- Update Inbox.md
- Update Inbox.md
- Update Inbox.md

## 4.0.1

- 🚀 4.0.1

## 4.0.0

- 🚀 4.0.0
- Merge prep
- Mounted check
- Inbox gestures working
- Styles complete
- New styles
- Increase delay
- More interaction polish
- Global key issue
- Backup
- Gestures working well. Need key support
- Animation fixes
- Better enter and exit animations
- Archive slide
- Animations
- Start over
- Removed slider working on pagination
- Many gestures
- Backup broken
- UI base
- List updates
- Loading count
- Size updates
- Backup
- iOS listener id events
- iOS
- Update Authentication.md
- Update Authentication.md
- Update Authentication.md

## 3.5.0

- 🚀 3.5.0

## 3.4.1

- 🚀 3.4.1

## 3.4.0

- 🚀 3.4.0
- Update scripting

## 3.2.0

- 🚀 3.2.0
- Android Client updates
- iOS Client updates
- Removed objc
- Update Client.md
- Update Client.md
- Update Client.md
- Removing unneeded file
- Update PushNotifications.md
- Update Preferences.md
- Update Preferences.md
- Update Inbox.md
- Test docs
- Update Inbox.md
- Update Inbox.md
- Update Inbox.md
- Update Authentication.md
- Update Client.md
- Update Client.md
- Create Client.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Import cleanup

## 3.1.2

- 🚀 3.1.2

## 3.1.1

- 🚀 3.1.1
- Bump
- iOS fixes

## 3.1.0

- 🚀 3.1.0
- Main thread for channel fetch
- Opened messages
- Scrollbar updagtes
- Removed tests dir
- Script update

## 3.0.2

- 🚀 Bump version to 3.0.2

## 3.0.1

- 🚀 Bump version to 3.0.1
- 🚀 Bump version to 3.0.0
- Update PushNotifications.md

## 3.0.0

- 🚀 3.0.0
- Archiving in inbox message models
- Get message improvements
- Android low level threading fixes
- Threading partial fix
- Android polish
- Android apis
- Flutter method channels
- Polish
- Push listener working well
- Custom Inbox Listener adjustments
- Polish
- Listener polish
- Polish
- Errors
- Test
- Updated client
- Pagination and refresh
- Inbox Message gets
- APNS fix
- Local token test
- Client working on iOS
- Podspec update func
- Remove all authentication listeners
- Authentication Listener Adjustment
- Shared instance calls
- Test bump
- Client ready
- Socket attempt
- Inbox and Preferences support for iOS
- Inbox Client APIs
- Token client for Android
- Token endpoints for iOS
- Integrated tests for Android
- Client test flow
- Tests init
- Bump
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Update Preferences.md
- Bump
- Bump
- Polish
- Tenant support
- Theming adjustments
- Custom Preferences Editor
- UI
- Style init
- Only theming and polish left
- Saving
- Sheet
- Preferences init
- Update Authentication.md
- Update README.md
- Update Inbox.md

## 2.4.1

- Bump
- Bump
- Bump
- Polish
- Tenant support
- Theming adjustments
- Custom Preferences Editor
- UI
- Style init
- Only theming and polish left
- Saving
- Sheet
- Preferences init
- Update Authentication.md
- Update README.md
- Update Inbox.md

## 2.4.0

- Bump
- Polish
- Tenant support
- Theming adjustments
- Custom Preferences Editor
- UI
- Style init
- Only theming and polish left
- Saving
- Sheet
- Preferences init

## 2.2.0

- Android
- JWT and brand updates

## 2.1.2

- Bump
- Android build
- Testing
- Update Inbox.md
- Update Inbox.md
- Update Inbox.md
- Update Inbox.md
- Update Inbox.md
- Bump
- Inbox Retry button
- Footer
- Brands
- Test
- Update Inbox.md
- Update Inbox.md
- Update README.md

## 2.1.1

- Bump
- Inbox Retry button
- Footer
- Brands
- Test

## 2.1.0

- Core SDK updates
- Styles
- Theme updates
- Scroll controller and pagination limit
- Basic Layout
- Init
- Core SDK updates
- Styles
- Theme updates
- Scroll controller and pagination limit
- Basic Layout
- Init
- Update PushNotifications.md
- Update PushNotifications.md
- Update PushNotifications.md

## 2.0.1

- Bump
- Removed sample env

## 2.0.0

- Test update
- Update Inbox.md
- Update Preferences.md
- Update PushNotifications.md
- Update PushNotifications.md
- Update PushNotifications.md
- Update PushNotifications.md
- Update PushNotifications.md
- Update PushNotifications.md
- Update PushNotifications.md
- Update Authentication.md
- Update README.md
- Update README.md
- Update README.md
- Docs init
- Cleanup
- Demo App
- Sample app inbox
- Firebase Init
- Push Token updates
- Preferences Types
- Updated iOS Provider support
- Android
- Polish
- Preferences apis
- Remaining calls
- iOS headless
- Sync

## 1.0.70

- Bump

## 1.0.61

- Android Flutter Fragment Activity

## 1.0.7

- Bump

## 1.0.6

- Bump

## 1.0.5

- Bump

## 1.0.4

- Init
- Update README.md

## 1.0.3

- Bump
- remove providers field :fire:
- Update README.md
- remove providers field :fire:
- Script for building the app
- iOS example notification service version
- Example name
- App Icons
- Firebase Credential Cleanup
- disable auto suggestion
- add userId alert
- update send push ui

## 1.0.2

- Bump
- update native sdk :package:
- Update CONTRIBUTING.md
- Contributing file
- docs(Contributing): upate Contributing.md
- docs(Contributing): add Contributing.md

## 1.0.1

- Bump
- Release script change

## 1.0.0

- Bump
- Build increment
- Update README.md
- Update README.md
- refactor(courier): :truck: rename ios and android bundle name

## 0.0.7

- bump
- Release script
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md

## 0.0.6

- Bump
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Init
- Version bump
- Core SDK bump
- Removed coverage
- Implementation working well
- Env update
- Env update
- Env config updates
- ENV change
- Comments removed
- Tests
- Plugin polish
- Polish comments and testing changes
- FCM working
- Better provider support on iOS
- Permissions Message Conversions and isProduction send exposure
- Break
- Print change
- ios presentation options
- iOS integration
- iOS usage
- iOS working well
- iOS Implementation
- Backup
- More android functions
- More android functions
- Most of the SDK functionality is linked
- Push click listener auto fetch
- Basic push handling in all states

## 0.0.5

- Bump
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Init
- Version bump
- Core SDK bump
- Removed coverage
- Implementation working well
- Env update
- Env update
- Env config updates
- ENV change
- Comments removed
- Tests
- Plugin polish
- Polish comments and testing changes
- FCM working
- Better provider support on iOS
- Permissions Message Conversions and isProduction send exposure
- Break
- Print change
- ios presentation options
- iOS integration
- iOS usage
- iOS working well
- iOS Implementation
- Backup
- More android functions
- More android functions
- Most of the SDK functionality is linked
- Push click listener auto fetch
- Basic push handling in all states

## "0.0.5"

- Bump
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Update README.md
- Init
- Version bump
- Core SDK bump
- Removed coverage
- Implementation working well
- Env update
- Env update
- Env config updates
- ENV change
- Comments removed
- Tests
- Plugin polish
- Polish comments and testing changes
- FCM working
- Better provider support on iOS
- Permissions Message Conversions and isProduction send exposure
- Break
- Print change
- ios presentation options
- iOS integration
- iOS usage
- iOS working well
- iOS Implementation
- Backup
- More android functions
- More android functions
- Most of the SDK functionality is linked
- Push click listener auto fetch
- Basic push handling in all states

