## 🚀 App Setup Steps

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.0.0 recommended)  
- Android Studio / VS Code  
- Emulator or Physical Device  
- Dart >=3.0.0  

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/priya-patel155/Crypto-Portfolio-Tracker.git
   cd Crypto-Portfolio-Tracker.git
2. Install dependencies:
    ```bash
    flutter pub get
3. Run the app:
    ```bash
    flutter run
### **2️⃣ Instructions on How to Run the Application**

## ▶️ Instructions to Run the Application

1. Ensure that all prerequisites (Flutter SDK, IDE, emulator/device) are properly set up.  
2. Navigate to the project directory:
   ```bash
   cd Crypto-Portfolio-Tracker
3. Connect a physical device or start an emulator.
4. Execute the following command:
    ```bash
    flutter run
### **3️⃣ Provide a Recorded Video of the Performed Task**
## 🎥 Demo Video

A recorded demonstration of the app usage is included in the [`media`](./media) folder.  
👉 https://github.com/priya-patel155/Crypto-Portfolio-Tracker/blob/main/media/screen-20250927-125917.mp4  

## 4️⃣🏗️ Architectural Choices

This application follows **Clean Architecture** with a separation of concerns:  

- **Presentation Layer**  
  - Flutter widgets  
  - `flutter_bloc` for state management  

- **Domain Layer**  
  - Business logic  
  - Use cases and entities  

- **Data Layer**  
  - **Remote**: API integration using `dio`  
  - **Local**: SQLite storage via `sqflite` and `path`  

This structure ensures maintainability, scalability, and easier testing.  

## 5️⃣📦 Third-Party Libraries

The following dependencies are used in this project:

| Package         | Version   | Purpose                                  |
|-----------------|-----------|------------------------------------------|
| `flutter_bloc`  | ^8.1.6    | State management (Bloc & Cubit).         |
| `dio`           | ^5.5.0+1  | HTTP client for API requests.            |
| `sqflite`       | ^2.3.0    | SQLite database support.                 |
| `path`          | ^1.9.0    | Path manipulation for local storage.     |
| `intl`          | ^0.19.0   | Internationalization & date formatting.  |

