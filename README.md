# 🌾 Civic Harvest – National Food Security (e-PDS) Digital Portal

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod_2.x-blue)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Civic Harvest** is a modern, transparent, and user-centric digital Public Distribution System (e-PDS) application designed to empower citizens under the **National Food Security Act (NFSA)** and **PMGKAY (Pradhan Mantri Garib Kalyan Anna Yojana)**. 

The platform bridges the gap between beneficiaries and Fair Price Shops (FPS) with real-time entitlement tracking, live shop stock updates, digital receipts, grievance filing, and multi-scheme support.

---

## 📱 Key Features

### 👤 1. Beneficiary Portal
* **Realtime Quota & Entitlement Tracking**: Live tracking of subsidized monthly allocations (Rice, Wheat, Fortified Sugar, Toor Dal, Kerosene/Oil).
* **One-Tap Claim & Digital Receipts**: Mark commodities as collected with real-time sync, generating verifiable e-PDS digital receipts.
* **Fair Price Shop (FPS) Locator & Live Stock**: View assigned ration shop details, real-time grain availability, live queue lengths, and dealer contact information.
* **Family Member Management**: Add, remove, and manage family units with Aadhaar e-KYC verification indicators.
* **Notice Board & Urgent Alerts**: Dealer announcements regarding stock arrivals, special distribution drives, and shop timings.
* **Grievance Redressal**: In-app complaint filing for overcharging, under-weighing, or shop closures with status tracking.

### 🏪 2. Shopkeeper / FPS Dealer Portal
* **Dealer Dashboard**: Manage shop status (Open/Closed), live queue wait times, and inventory levels.
* **Stock & Notice Announcements**: Post public announcements and broadcast urgent stock availability alerts directly to assigned beneficiaries.
* **Restricted Access Security**: Segregated dealer view ensuring privacy of individual citizen entitlement records.

### 💳 3. Multi-Card Scheme Support
* **BPL (Below Poverty Line)**: Subsidized staple allocations calculated per family member.
* **AAY (Antyodaya Anna Yojana)**: Fixed 35 kg foodgrain allocation for the poorest households.
* **PHH (Priority Household)**: Tailored state welfare quotas.
* **APL (Above Poverty Line)**: Non-subsidized white card access.

---

## 🏗️ Tech Stack & Architecture

* **Frontend Framework**: [Flutter](https://flutter.dev) (Dart)
* **Design System**: Material 3 with custom Deep Forest Green & Amber Gold palette (`GoogleFonts.plusJakartaSans` & `GoogleFonts.inter`)
* **State Management**: [Flutter Riverpod](https://riverpod.dev) (Reactive Stream Providers & StateNotifier)
* **Backend / Database**: [Cloud Firestore](https://firebase.google.com/docs/firestore) & [Firebase Auth](https://firebase.google.com/docs/auth) with offline-first in-memory fallback
* **Architecture**: Feature-first Clean Architecture (`core/`, `features/auth/`, `features/home/`, `features/entitlements/`, `features/shop/`, `features/notices/`)

---

## 📂 Project Structure

```
lib/
├── app.dart                        # MaterialApp root & Theme configuration
├── firebase_options.dart           # Multiplatform Firebase configuration
├── main.dart                       # App entry point
├── core/
│   ├── models/models.dart          # Domain data models (User, Commodity, Shop, Transaction)
│   ├── services/firebase_service.dart # Realtime Firestore CRUD & fallback sync engine
│   └── theme/app_theme.dart        # Civic Harvest design system & color tokens
└── features/
    ├── auth/                       # Dual portal authentication (Beneficiary / Dealer)
    ├── entitlements/               # Monthly quota breakdown & digital receipt dialogs
    ├── home/                       # Unified dashboard & quick actions
    ├── notices/                    # Community announcement feed & dealer alerts
    ├── shell/                      # Navigation shell with reactive badge counters
    └── shop/                       # Fair Price Shop inventory & dealer details
```

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.0.0`)
* Android Studio / VS Code with Flutter extensions
* A Firebase Project (with Firestore / Authentication enabled)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/<YOUR-USERNAME>/<YOUR-REPO-NAME>.git
   cd ration
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Connect your Firebase project
   flutterfire configure
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 🗄️ Database Setup (Optional Seed Data)

To populate your database with realistic Indian e-PDS sample beneficiaries, commodities, and FPS shops:
1. Open your [Firebase Console](https://console.firebase.google.com/).
2. Navigate to **Realtime Database** or **Firestore Database**.
3. Import the included [`firebase_seed_data.json`](firebase_seed_data.json) file.

---

## 🔒 Security & Privacy
* Built with zero-trust architectural boundaries between dealers and beneficiaries.
* Family biometric data indicators follow Aadhaar privacy guidelines.
* OTP-verified distribution workflow preventing black-market leakage.

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
