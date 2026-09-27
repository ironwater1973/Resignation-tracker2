# Apple App Store Submission Guide for Resignation Tracker

This guide details step-by-step instructions for compiling, testing, and submitting the **Resignation Tracker** Swift/SwiftUI iOS app to the **Apple App Store**.

---

## Prerequisites

1. **Apple Developer Program Account** ($99/year enrollment at [developer.apple.com](https://developer.apple.com)).
2. **Mac Computer running macOS** with **Xcode 15+** installed from the Mac App Store.
3. **App Icon Assets**: 1024x1024 px PNG image for App Store metadata.

---

## Step 1: Open Xcode Project on macOS

1. Open the native Xcode project directly at `iOS/WorkVibeTracker.xcodeproj`.
2. Target Name: `WorkVibeTracker`, Bundle Identifier: `com.IronWaterMk88.app`.
3. The project comes pre-configured with all `.swift` source files, `Info.plist`, `Assets.xcassets`, and shared Xcode scheme `WorkVibeTracker`.

---

## Step 2: Configure Signing & Capabilities

1. In Xcode, click on the top-level **WorkVibeTracker** project target.
2. Select **Signing & Capabilities**.
3. Enable **Automatically manage signing**.
4. Select your **Apple Developer Team**.

---

## Step 3: Create App in App Store Connect

1. Log into [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **My Apps** > click **+ New App**.
3. Fill in details:
   - **Platform**: iOS
   - **Name**: Resignation Tracker - 30-Day Work Decision
   - **Primary Language**: English
   - **Bundle ID**: `com.IronWaterMk88.app`
   - **SKU**: `resignation-tracker-30day-ios`

---

## Step 4: Build & Archive in Xcode

1. Connect an iPhone or select **Any iOS Device (arm64)** as the target build destination in Xcode.
2. Go to **Product > Archive**.
3. Once archiving finishes, the **Organizer** window will open.
4. Click **Distribute App** > Select **App Store Connect** > Click **Upload**.
5. Xcode will sign, validate, and upload your build to App Store Connect automatically.

---

## Step 5: Test via TestFlight

1. In App Store Connect, go to the **TestFlight** tab.
2. Add your email address under **Internal Testing**.
3. Install the **TestFlight App** on your iPhone and accept the invitation to test the app on live hardware.

---

## Step 6: Complete App Store Listing & Submit

1. In App Store Connect, under **App Store > Prepare for Submission**:
   - **Screenshots**: Upload iPhone 6.7" and 6.5" screenshots (take screenshots from iOS Simulator or Web Preview).
   - **Description**: Explain the 30-day workplace emotion and resignation decision tracker with 3 signature emotions (`FCUK!!`, `On Fire`, `Happy Chick`) and final verdict slot (`I WILL STAY for now` vs `FCUK THIS I QUIT!! 🤬💣`).
   - **Keywords**: `resignation tracker, work emotion, mood tracker, daily vibe, stress tracker, office mood, 30 day grid`
   - **Support URL**: Your website or support page.
   - **App Privacy**: Select "Data Not Collected" or "Data Stored On Device Only".
2. Click **Save** and then click **Submit for Review**.
3. App Store review usually takes 24 to 48 hours.

---

🎉 **Congratulations! Your Resignation Tracker app is ready for the App Store!**
