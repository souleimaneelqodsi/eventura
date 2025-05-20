# 🚀 Eventura

![Build](https://img.shields.io/badge/build-passing-brightgreen)
![Version](https://img.shields.io/badge/version-1.0-blue)
![License](https://img.shields.io/badge/license-MIT-orange)

**Eventura** is a cross-platform mobile application designed to simplify event planning and management. Built with **Flutter** and powered by **Supabase**, Eventura allows users to create, organize, and manage events seamlessly.

---

### 🌟 Features

- **Event Creation** : Easily create events with details like date, time, location, and description.
- **Guest Management** : Invite guests and manage RSVPs directly from the app.
- **Cross-Platform** : Works on both iOS and Android devices.
- **Real-Time Sync** : Data is synchronized in real-time using Supabase as the backend.

---

### 🛠️ Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)

---

📦 Installation

### Prerequisites

Before you begin, ensure you have the following installed and set up on your system:

*   **Flutter SDK**: This is essential for building and running Flutter applications. You can find installation instructions for your operating system on the official Flutter website ([https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)).
*   **Git**: Required to clone the project repository from GitHub. If you don't have Git, you can download it from the official Git website ([https://git-scm.com/downloads](https://git-scm.com/downloads)).
*   **A code editor or IDE**: While not strictly required for these command-line steps, a code editor like VS Code, Android Studio, or IntelliJ IDEA with the Flutter and Dart plugins is highly recommended for development.
*   **Web Browser**: Specifically Chrome, as recommended for compatibility.

Now, follow these steps to get the project set up:

1.  **Clone the repository** :
    ```bash
    git clone https://github.com/souleimaneelqodsi/eventura.git
    ```

2.  **Navigate to the project directory** :
    ```bash
    cd eventura
    ```

3.  **Obtain and create the .env file**:
    This project requires a `.env` file containing necessary environment variables to function correctly.
    Please contact Souleimane El Qodsi on LinkedIn at [https://linkedin.com/in/souleimaneelqodsi](https://linkedin.com/in/souleimaneelqodsi) to request the content for this file.
    Once you receive the content, create a file named `.env` in the root of the project directory (next to the `.env.example` file) and paste the provided content into it.

4.  **Add web platform support** :
    ```bash
    flutter create .
    ```
    This command updates the current project to include support for available platforms like web, adding the necessary files and the `web` folder if they are not already present.

5.  **Install dependencies** :
    ```bash
    flutter pub get
    ```

6.  **Build the web output** (optional, but good practice to ensure everything is set up):
    ```bash
    flutter build web
    ```
    This command creates the `build/web` directory containing the files needed to run the app in a web browser.

7.  **Run the app** :
    ```bash
    flutter run
    ```
    
-   Choose Chrome preferably to ensure compatibility.
  
---

### 📄 License

See the [LICENSE](LICENSE) file for details.

---

### 📬 Contact

For any questions or feedback, feel free to reach out:

- **GitHub** : [souleimaneelqodsi](https://github.com/souleimaneelqodsi)
- **LinkedIn** : [Souleimane El Qodsi](https://www.linkedin.com/in/souleimaneelqodsi)
- **Email** : souleimaneelqods@gmail.com
