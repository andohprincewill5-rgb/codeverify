# CodeVerify - Setup Instructions

## What This App Does
CodeVerify lets you scan QR codes, barcodes, license keys, and any other code,
then checks them against your Supabase database to verify if they are legit or fake.

---

## Step 1: Install Flutter
1. Go to https://flutter.dev/docs/get-started/install/windows
2. Download and extract Flutter to C:\flutter
3. Add C:\flutter\bin to your System PATH
4. Open Command Prompt and run: flutter doctor

## Step 2: Install Android Studio (for Android)
1. Download from https://developer.android.com/studio
2. Install and open Android Studio
3. Go to SDK Manager → install Android SDK
4. Run: flutter doctor (should show Android toolchain as OK)

## Step 3: Run the App
1. Open Command Prompt in the codeverify folder
2. Run: flutter pub get
3. Connect your Android phone via USB (enable USB Debugging in Developer Options)
4. Run: flutter run

---

## Supabase Setup (Already Done)
- URL: https://iiqwpzwwnontcdfmhhnf.supabase.co
- Table: codes (with columns: id, code_value, code_type, is_legit, source, created_at)

## Adding Codes to the Registry
Use the **Admin Panel** inside the app to add codes manually.
Or go to your Supabase dashboard → Table Editor → codes → Insert row.

---

## App Features
- 📷 Camera scanner (QR codes, barcodes)
- ⌨️ Manual code entry
- ✅ Instant legit/fake/unknown result
- 🔧 Admin panel to manage your code registry
- 🔒 All data stored securely in Supabase
