# ⚡ ElektrikBil — Monthly Electricity Bill Estimator
### Flutter Android Application | Mobile Technology Assignment

---

## 📱 App Overview
ElektrikBil is a Flutter Android application that estimates monthly electricity bills using TNB tariff block rates. It features a local SQLite database, full CRUD operations, and a polished dark UI with electric amber theming.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code with Flutter plugin
- Android device or emulator (API 21+)

### Setup Steps

```bash
# 1. Clone the repo
git clone https://github.com/Mrhelper-01/electricity_bill_app.git
cd ElectricityBill

# 2. Install dependencies
flutter pub get

# 3. Run on device/emulator
flutter run

# 4. Build APK (release)
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                   # App entry point + BottomNav shell
├── utils/
│   └── app_theme.dart          # Colors, ThemeData, ElectricityCalculator
├── models/
│   └── bill_record.dart        # BillRecord data model
├── database/
│   └── database_helper.dart    # SQLite CRUD via sqflite
└── screens/
    ├── splash_screen.dart       # Animated splash screen
    ├── calculator_screen.dart   # Bill calculator (main input/output)
    ├── history_screen.dart      # ListView of all saved records
    ├── detail_screen.dart       # View / Edit / Delete a record
    └── about_screen.dart        # About page with student info + instructions
```

---

## ⚡ Tariff Calculation Logic

| Block | kWh Range | Rate (sen/kWh) |
|-------|-----------|----------------|
| 1 | 1 – 200 | 21.8 |
| 2 | 201 – 300 | 33.4 |
| 3 | 301 – 600 | 51.6 |
| 4 | 601 – 1000 | 54.6 |

**Formula:**
```
Total Charges = Σ (units_in_block × block_rate)
Final Cost = Total Charges - (Total Charges × rebate%)
```

**Example (467 kWh, 0% rebate):**
```
200 × 0.218 = RM 43.60
100 × 0.334 = RM 33.40
167 × 0.516 = RM 86.17
─────────────────────
Total       = RM 163.17
```

---

## ✅ Assignment Rubric Checklist

### 1. Input & Output (5 marks) ✅
- [x] Month: Dropdown (radio-style selection)
- [x] Units: TextFormField with numeric keyboard (1–1000 kWh)
- [x] Rebate: Slider + TextFormField (0–5%) — two input types
- [x] Output: Total Charges (formatted RM)
- [x] Output: Final Cost after rebate (formatted RM)
- [x] Results displayed on the same page

### 2. Database (5 marks) ✅
- [x] All inputs AND outputs stored in SQLite (sqflite)
- [x] ListView in History tab: Month + Final Cost
- [x] Tap to open Detail page: Month, Units, Total Charges, Rebate, Final Cost
- [x] Edit record → recalculates and updates DB
- [x] Delete record with confirmation dialog

### 3. Layout — Themes, Title Bar, Icons (5 marks) ✅
- [x] Custom color theme: Deep navy + electric amber (#F5A623)
- [x] Custom app title in AppBar: "⚡ ELEKTRIK BIL" using Orbitron font
- [x] App icon: ⚡ bolt icon with custom background
- [x] Consistent Material3 dark theme throughout all screens

### 4. About Page (5 marks) ✅
- [x] Student photo placeholder
- [x] Full name, Student ID, Course code and name
- [x] App description
- [x] Copyright statement
- [x] Clickable GitHub URL (url_launcher)
- [x] Detailed instructions on how to use the app

### 5. Good Design Practice (5 marks) ✅
- [x] Error messages: empty fields, out-of-range values, duplicate month
- [x] Helpful notices: Info banner on calculator, empty state for history
- [x] Instructions: Step-by-step guide in About page
- [x] Input validation: validators on all FormFields
- [x] Snackbar confirmations: save, update, delete

---

## 📦 Dependencies

```yaml
sqflite: ^2.3.0          # Local SQLite database
path: ^1.8.3             # DB path resolution
url_launcher: ^6.2.4     # Open GitHub URL
google_fonts: ^6.1.0     # Orbitron + Poppins fonts
```

---

## 🎥 Demo Video
https://youtu.be/X05ak4t_93E

## 🔗 GitHub
https://github.com/Mrhelper-01/electricity_bill_app.git
---

## 👤 Author
- **Name:** Zhanyar Dldar Adham
- **Student ID:** QIU230-147
- **Course:** Mobile Technology (ICT602)
- **© 2026 ElektrikBil. All rights reserved.**
