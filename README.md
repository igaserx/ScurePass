# scure_pass
My CS50 Final Project - A Secure Password Manager

#### Video : https://youtu.be/0EJ6O0OnWbA

#### Description:

Scure Pass is a comprehensive mobile password manager built with Flutter that helps users securely store and manage their passwords locally on their devices. This application was created as my final project for CS50.

## Features

### Core Features
- **Secure Authentication**: User registration and login system with SHA-256 password hashing
- **Password Encryption**: All stored passwords are encrypted using AES-256 encryption
- **Password Management**: Add, view, edit, and delete password entries
- **Search Functionality**: Quickly find passwords by title, username, or URL
- **Password Generator**: Built-in tool to generate strong, random passwords
- **User Profile**: View account information and change master password
- **Session Management**: Secure session handling with automatic logout

### Security Features
- Local SQLite database storage (no cloud dependency)
- AES-256 encryption for password storage
- SHA-256 hashing for user passwords
- Secure key and IV (Initialization Vector) management
- Password visibility toggle for secure viewing

## 🛠️ Technologies Used

### Frontend
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language for Flutter applications
- **flutter_bloc**: Basic state management with Cubit

### Backend & Database
- **SQLite (sqflite)**: Local database for data persistence
- **shared_preferences**: Session management

### Security
- **encrypt**: AES encryption/decryption
- **crypto**: SHA-256 hashing for passwords

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TEXT NOT NULL
)
```

### Passwords Table
```sql
CREATE TABLE passwords (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  url TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
```

## 🚀 Installation & Setup

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android Emulator or Physical Device

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/igaserx/scure_pass.git
cd scure_pass
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the application**
```bash
flutter run
```

## 📱 How to Use

1. **Sign Up**: Create a new account with your name, username, and secure password
2. **Login**: Access your account using your credentials
3. **Add Passwords**: Click the floating action button (+) to add new password entries
4. **View Passwords**: Tap any password card to view details, copy credentials, or delete
5. **Search**: Use the search tab to quickly find specific passwords
6. **Generate Passwords**: Use the password generator tool to create strong passwords
7. **Profile Management**: View your profile

## 👨‍💻 Author
**Gasser Alaa**
- CS50 Student
- GitHub: [@igaserx](https://github.com/igaserx)
- Email: gasseralaa11@gmail.com

## 🙏 Acknowledgments

- CS50 Staff and David J. Malan for the amazing course
- Flutter and Dart teams for the excellent framework
- The open-source community for the packages used

---

**This was CS50!**
