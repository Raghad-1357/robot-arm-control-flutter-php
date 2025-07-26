# 🤖 Robot Arm Control Panel (Flutter & PHP/MySQL)

This is a web application initially built with PHP, MySQL, and JavaScript to control a robot arm by saving and loading different motor positions. The project was completed as part of a training task for Smart Methods, and later extended with a Flutter mobile application to provide a dedicated control interface.

---

## 🚀 Features

### Flutter Mobile App:
* Intuitive UI: Modern and easy-to-use interface built with Flutter.
* Motor Control: Interactive sliders for 6 motors (0-180° range).
* Save Pose: Store current motor positions to the MySQL database.
* Run Pose: Send motor values to a web page (simulating commands for the arm).
* Manage Poses: Display, load, and soft-delete (mark as inactive) saved poses from the database.

### PHP/MySQL Backend (Web Interface):
* Interactive Sliders: To control each of the 6 motors (0-180° range).
* Save & Load Poses: Store current and recall saved motor positions.
* Remove Poses: Sets status=0 for inactive poses in the database (non-destructive deletion), preserving all poses.
* Run Pose: Executes current pose in format: 1,s90,s90,... (intended for Arduino/robot communication).
* Reset All Motors: To default 90° position.
* Dynamic Table: Displays all saved poses.

---

## 🛠 Technologies Used

### Mobile App:
* Flutter (Dart)
* http package for API communication.
* url_launcher for opening web links.

### Backend:
* PHP (Backend Logic)
* MySQL (Database)
* HTML/CSS (Frontend Structure for Web Interface)
* JavaScript (Interactive Controls for Web Interface)

### Environment:
* XAMPP (Apache + MySQL Server)
* Android Studio (for Android SDK, NDK & device management)

---

## 📁 File Structure


.
├── robot_arm_app/          # Flutter Project Root
│   ├── lib/
│   │   └── main.dart       # Main Flutter app logic & UI
│   ├── android/            # Android-specific project files
│   │   └── app/
│   │       └── src/
│   │           └── main/
│   │               └── AndroidManifest.xml # Android app permissions             
│   └── pubspec.yaml        # Flutter dependencies
│   └── ...                 # Other Flutter project files
└── robot_arm_control/      # PHP Backend & Web Interface (Place inside XAMPP htdocs)
├── index.html          # Main control panel interface (web)
├── connectToDB.php     # Database connection handler
├── get_run_pose.php    # Retrieves all active poses for table
├── load_pose_values.php# Loads specific pose values
├── remove_pose.php     # Soft-deletes a pose (sets status=0)
├── run_pose.php        # Executes current pose (web)
├── save_pose.php       # Saves new pose (web)
├── update_status.php   # Helper to update pose status (e.g., to 0)
├── script.js           # Frontend functionality (web)
├── style.css           # Styling (web)
└── README.md           # Project documentation

---

## ⚙️ Setup Instructions

### Part 1: Backend Setup (PHP & MySQL via XAMPP)

1.  📥 Install XAMPP:
    * Download from official site: 🔗 [https://www.apachefriends.org/download.html](https://www.apachefriends.org/download.html)
    * Install on your system.

2.  ▶️ Start Services:
    * Open XAMPP Control Panel.
    * Start these services:
        * Apache (Web server)
        * MySQL (Database)

3.  🗄️ Database Setup:
    * Access phpMyAdmin in your web browser:
        🔗 http://localhost/phpmyadmin
    * Create Database:
        * Click "New" on the left sidebar.

* Name the database: robot_arm_flutt_db (ensure this name matches connectToDB.php).
    * **Create robot_arm_flutt table:**
        * Select the robot_arm_flutt_db database.
        * Go to the SQL tab and execute the following query:
           
            CREATE TABLE robot_arm_flutt (
                id INT AUTO_INCREMENT PRIMARY KEY,
                motor1 INT,
                motor2 INT,
                motor3 INT,
                motor4 INT,
                motor5 INT,
                motor6 INT,
                status TINYINT(1) DEFAULT 1
            );
            
📂 Deploy Project Files:**
    * Copy the entire robot_arm_control folder (containing your PHP, HTML, JS, CSS files) to your XAMPP's htdocs directory.
    * Example path: C:\xampp\htdocs\robot_arm_control

✅ Test Database Connection (Optional):**
    * If needed, edit connectToDB.php to match your MySQL credentials (default XAMPP: user root, no password).
    * Open in browser: 🔗 http://localhost/robot_arm_control/connectToDB.php
        * You should see "Connection failed:" if there's an error, or nothing if successful (meaning it connected without issues).

🌐 Launch Web Application (Optional):**
    * Open in browser: 🔗 http://localhost/robot_arm_control/index.html
    * You can now test the web interface directly.

---

### Part 2: Flutter Application Setup

📥 Install Flutter SDK:K:**
    * Follow the official Flutter installation guide for your OS:
        🔗 [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

⬇️ Clone the Flutter Project:t:**
    * Open your terminal (e.g., Command Prompt, PowerShell, Git Bash).
    * Navigate to your desired development directory.
    * Clone this repository:
       
        git clone your-github-repo-url
        cd robot_arm_app # Navigate into the Flutter project folder
        
📦 Install Flutter Packages:s:**
    * Inside the robot_arm_app directory, run:
       
        flutter pub get
        
4.  **⚙️ Configure Backend IP Address (baseUrl):*CRUCIAL STEP: STEP:** The Flutter app needs to know your PC's local IP address to communicate with the XAMPP serverFind your PC's IP (Windows):dows):** Open Command Prompt and type ipconfig. Look for "IPv4 Address" under your active network adapter (Wi-Fi or Ethernet). E.g., 192.168.1.100.
    * Open robot_arm_app/lib/main.dart and update the baseUrl variable:
       
        final String baseUrl = "http://YOUR_PC_IP_ADDRESS/robot_arm_control";
        // Example: final String baseUrl = "[http://192.168.1.100/robot_arm_control](http://192.168.1.100/robot_arm_control)";
        
    * **IMPORTANT:** Both your Android phone and PC must be connesame local network (same Wi-Fi router)Fi rout🔧 Configure Android NDK Version:K Version:**
    * If you encounter NDK-related build errors (e.g., NDK not configured, Daemon compilation failed), you need to explicitly set the NDK version.
    * Open robot_arm_app/android/app/build.gradle.kts.
    * Inside the android { ... } block, add/update the ndkVersion property to match the required version (e.g., 27.0.12877973):
       
        android {
            // ... other configurations
            ndkVersion = "27.0.12877973" // Update this based on the error message (e.g., from url_launcher)
        }
        
    * **To Install NDK via Android Studio:**
        * Open Android Studio -> File -> Settings -> Appearance & Behavior -> System Settings -> Android SDK.
        * Go to "SDK Tools" tab, check "Android NDK (Side by side)".
        * Ensure the specific version (e.g., 27.0.12877973) is selected and "Installed". If not, download/install it.

رغد الرشيدي, [01/02/47 11:44 ص]
6.  🔐 Configure Android Manifest Permissions:
    * Open robot_arm_app/android/app/src/main/AndroidManifest.xml.
    * Ensure the following lines are present:
        * Inside the <manifest> tag (outside <application>):
           
            <uses-permission android:name="android.permission.INTERNET"/>
            
        * Inside the <application> tag:
           
            <application
                android:usesCleartextTraffic="true"
                android:label="robot_arm_app"
                android:name="${applicationName}"
                android:icon="@mipmap/ic_launcher">
                </application>
            
        * android:usesCleartextTraffic="true" is crucial for connecting to http:// (non-HTTPS) servers on Android 9+ devices.

---

## 🚀 Running the Flutter App

1.  📱 Prepare your Android Phone:
    * Enable Developer Options: Go to Phone Settings -> About Phone -> Tap "Build Number" 7 times.
    * Enable USB Debugging: Go to Phone Settings -> Developer Options -> Enable "USB Debugging".
    * Allow USB Access: When connecting your phone to your PC via USB, allow "USB debugging" and "Always allow from this computer" when prompted.

2.  ▶️ Launch the App:
    * Ensure your phone is connected and recognized by your development environment (e.g., visible in VS Code's status bar or Android Studio's device dropdown).
    * In your terminal (within the robot_arm_app directory), run:
       
        flutter run
        
    * Flutter will build and install the app on your phone. The first build may take some time.

---

## ❓ Troubleshooting

* "Timeout reached waiting for exclusive access to file" / "Gradle threw an error while downloading artifacts":
    * Cause: Antivirus/firewall blocking Gradle, or an unstable/slow internet connection.
    * Solution: Temporarily disable antivirus/firewall, ensure stable internet. Clear Gradle cache by deleting contents of C:\Users\YOUR_USERNAME\.gradle\wrapper\dists\. Then run flutter clean and flutter run.

* "Timeout waiting to lock build logic queue":
    * Cause: A stuck Gradle process or conflicting build attempts.
    * Solution: End java.exe or Gradle Daemon processes in Task Manager. Delete C:\flutter_projects\robot_arm_app\android\.gradle\noVersion\buildLogic.lock. Restart your computer for a clean slate, then flutter clean and flutter run.

* "NDK not configured. Download it with SDK manager.":
    * Cause: The specific NDK version required is not installed on your system.
    * Solution: Install the required NDK version (e.g., 27.0.12877973) via Android Studio SDK Manager (SDK Tools -> Android NDK (Side by side)).

* Buttons (Run / Save Pose) Not Working on Phone:
    * Cause: Connectivity issue between your Flutter app and the XAMPP server.
    * Solution:
        1.  Verify baseUrl in main.dart is your PC's correct local IP.
        2.  Ensure phone & PC are on the exact same Wi-Fi network.
        3.  Confirm Apache & MySQL are running in XAMPP.
        4.  Temporarily disable your PC's firewall for testing.
        5.  Double-check android:usesCleartextTraffic="true" and android.permission.INTERNET in AndroidManifest.xml.

* General Issues:
    * Run flutter doctor -v in your terminal and review its output for detailed diagnostics and suggested fixes.

---

## 👩‍💻 Author

Developed by Raghad Alrashidi

---
