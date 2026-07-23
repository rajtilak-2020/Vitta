# Pre-Release Data Safety Audit Checklist

This document provides a mandatory checklist for AI agents and developers before releasing any update or feature to ensure existing user data remains safe and intact across app upgrades.

---

## 1. Data Model & Deserialization Compatibility

Whenever `lib/models.dart` or any data structure is modified:

- [ ] **Optional / Nullable New Fields**: Any newly added field in `Transaction` or other models **must** be nullable (e.g. `String? tag`) or provide a non-breaking default fallback (e.g. `json['field'] ?? defaultValue`).
- [ ] **Type Cast Safety**: Ensure type casting in `.fromJson()` uses defensive conversion (e.g. `(json['amount'] as num).toDouble()`) rather than strict type casting (`json['amount'] as double`), preventing runtime crashes if JSON numeric formats vary.
- [ ] **Legacy Data Deserialization Test**: Verify that legacy JSON objects stored in existing installations (which lack new keys) parse successfully without throwing `TypeError` or `NullRejection`.
- [ ] **Round-Trip Serialization**: Confirm `toJson()` output matches expected schema for both old and new app versions.

---

## 2. Storage & Persistence Safeguards

- [ ] **Key Immutability**: Verify that `SharedPreferences` keys (`'transactions'`, `'custom_tags'`, `'local_auth_enabled'`, `'app_pin'`) are unchanged.
- [ ] **Defensive Load Failure Handling**: Ensure that `_loadTransactions()` or other loading methods do not immediately clear or overwrite existing `SharedPreferences` data if an error occurs during parsing.
- [ ] **Tag & Setting Persistence**: Confirm custom tags and pin security settings retain state when updated models load.

---

## 3. Platform & Release Configuration

- [ ] **Android Package Name Integrity**: Confirm `applicationId` in `android/app/build.gradle` is identical to previous release builds (changing this creates a new app identity and loses access to existing app data).
- [ ] **Signing Certificate Consistency**: Ensure Android APKs are signed with the matching key store.
- [ ] **Web Deployment Domain**: Ensure web releases deploy to the same domain/origin so browser `localStorage` is preserved.

---

## 4. Pre-Release Verification Protocol

Execute the following verification routine prior to cutting a release:

1. **Legacy State Emulation**: Load a dummy dataset representing an older schema version into local storage.
2. **Upgrade Execution**: Compile and launch the new build (`flutter build apk --release` or `flutter build web --release`).
3. **Data Inspection**: Verify that all past transactions, date groups, running balances, and settings display correctly.
4. **Write Verification**: Perform new transactions (Add, Edit, Delete) and restart the app to confirm state persists without corruption.
