# VolunQueer

VolunQueer connects volunteers with LGBTQ+ events, streamlines coordination, and tracks community impact.

## Firebase + Firestore setup (required)

This repo does **not** commit `GoogleService-Info.plist`. Each developer must add their own copy locally.

1. Create or select a Firebase project.
2. Add an iOS app to the project:
   - Bundle ID: `com.Cephalopod.VolunQueer`
   - (Optional) App nickname: VolunQueer
3. Download `GoogleService-Info.plist`.
   - If you change the bundle ID in Xcode, you must register that new ID in Firebase and re-download the plist.
4. In Xcode, add the plist to the app target:
   - Open `VolunQueer/VolunQueer.xcodeproj`
   - Drag `GoogleService-Info.plist` into the `VolunQueer` target
   - Ensure "Copy items if needed" and the `VolunQueer` target are checked
5. In the Firebase console, enable Firestore:
   - Build > Firestore Database
   - Create a database (start in Test Mode for local dev if desired)

Note: `GoogleService-Info.plist` is ignored by git in this repo. Do not commit it.

## Run

1. Open `VolunQueer/VolunQueer.xcodeproj` in Xcode.
2. Build and run on a simulator or device.
