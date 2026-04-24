# 🚀 HireHub: Professional Job Portal & Admin Management System

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=dart&logoColor=white)

Welcome to **HireHub**, a comprehensive, cross-platform job portal application built with **Flutter** and powered by **Firebase**. This repository contains two main applications that work seamlessly together:

1. **Job Portal App** (`jobportal/`): The main application for both **Job Seekers** and **Employers**, facilitating smooth recruitment processes.
2. **Admin Portal App** (`jobportalAdmin/`): A dedicated management platform for administrators to oversee platform activity, manage users, and monitor job listings.

---

## 🌟 Key Features

### 👨‍💼 For Job Seekers
* **Smart User Authentication:** Secure login and registration using Firebase Auth.
* **Profile Management:** Build a comprehensive professional profile, upload resumes, and manage personal data.
* **Job Discovery:** Browse and search for jobs with intuitive UI and advanced filtering.
* **Seamless Applications:** Apply to jobs with a single click and track application statuses in real-time.

### 🏢 For Employers
* **Company Profiles:** Create and manage company details to attract top talent.
* **Job Posting & Management:** Post new job opportunities, edit existing listings, and manage their lifecycle.
* **Applicant Tracking:** View, filter, and manage applications received for posted jobs. Streamline the hiring pipeline efficiently.

### 🛡️ For Administrators (Admin App)
* **Centralized Dashboard:** A comprehensive overview of platform statistics using graphical charts (`fl_chart`).
* **User Management:** Monitor, suspend, or manage both job seekers and employers.
* **Job Moderation:** Review, approve, or remove job postings to maintain platform quality.
* **Analytics:** Gain insights into platform growth, job trends, and user engagement metrics.

---

## 🛠️ Technology Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Cloud Firestore, Firebase Authentication)
* **Cloud Storage:** Firebase Storage (for resumes, profile pictures, and company logos)
* **State Management:** Riverpod (App) / Stateful Widgets (Admin)
* **Data Visualization:** FL Chart (Admin Dashboard analytics)
* **File Handling:** `file_picker`, `image_picker`
* **Routing / Links:** `url_launcher`

---

## 📂 Repository Structure

```text
JobPortal_App/
│
├── jobportal/                 # Main User & Employer Application
│   ├── lib/
│   │   ├── features/          # Feature-first architecture (seeker, employer)
│   │   ├── main.dart          # App entry point
│   │   └── ...
│   └── pubspec.yaml           # App dependencies
│
├── jobportalAdmin/            # Administrator Management Application
│   ├── lib/
│   │   ├── features/          # Admin specific features (jobs, users, dashboard)
│   │   ├── main.dart          # Admin entry point
│   │   └── ...
│   └── pubspec.yaml           # Admin dependencies
│
└── README.md                  # Detailed Project Documentation
```

---

## 🚀 Getting Started

Follow these instructions to set up the project locally on your machine.

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (Version > 3.0.0)
* [Dart](https://dart.dev/get-dart)
* [Firebase Account](https://firebase.google.com/)
* IDE (VS Code, Android Studio, IntelliJ)

### Installation Guide

#### 1. Clone the Repository
```bash
git clone https://github.com/Saad-sema/JobPortal_App.git
cd JobPortal_App
```

#### 2. Setup Firebase
You need to connect both applications to your Firebase project.
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project.
3. Enable **Authentication** (Email/Password), **Firestore Database**, and **Firebase Storage**.
4. Use the `flutterfire_cli` to configure both apps:
   ```bash
   # Configure the main app
   cd jobportal
   flutterfire configure
   
   # Configure the admin app
   cd ../jobportalAdmin
   flutterfire configure
   ```

#### 3. Install Dependencies
Navigate to each project directory and install the required packages:

**For the Main App:**
```bash
cd jobportal
flutter pub get
```

**For the Admin App:**
```bash
cd jobportalAdmin
flutter pub get
```

#### 4. Run the Apps
You can run the applications on your preferred emulator or device.

**Run Main App:**
```bash
cd jobportal
flutter run
```

**Run Admin App:**
```bash
cd jobportalAdmin
flutter run
```

---

## 📸 Screenshots
*(Coming Soon)*
> Add screenshots of your Main App and Admin dashboard here to showcase the beautiful UI!

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with ❤️ using Flutter and Firebase.*
