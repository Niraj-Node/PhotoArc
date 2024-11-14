# PhotoArc Gallery App

PhotoArc is a feature-rich gallery application built using Flutter, providing seamless access and management of photos and videos on local devices as well as cloud storage. The app boasts a user-friendly interface, essential photo management tools, and integration with Firebase for cloud functionalities.

## Features

### 1. User Authentication
- **Sign In and Sign Up**: Users can create an account and sign in to access the app.
- **Email Verification** (future enhancement): Ensure a verified user base.
- **Forgot Password** (future enhancement): Allow users to recover their accounts.
- **Google Authorization** (future enhancement): Easy sign-in with Google accounts.

### 2. Gallery Access
- **Photo Permissions**: The app requests user permission to access local photos.
- **Gallery Screen**: Displays all folders on the local device with a sleek card-based UI and folder thumbnails.
- **Folder View**: Tap on a folder to view all photos and videos within, with options to select multiple items for deletion or sharing.

### 3. Image and Video Management
- **Select and Manage Media**:
  - Long press to select multiple photos/videos.
  - Options to delete or share selected items.
- **Single Image View**:
  - View images in full-screen mode.
  - Zoom functionality.
  - Edit options for local images.
- **Camera Integration**:
  - Capture new photos directly within the app.
  - Approve captured images for upload to Firebase cloud storage.
  - Share captured images or save them locally.
- **Cloud Image Management**:
  - View cloud images (with zoom functionality).
  - Share cloud images via Firebase links.
  - Delete images from cloud storage.
  - Note: Cloud images do not have edit options.

### 4. Navigation and Usability
- **Navigation Bar**: Positioned at the bottom of the app for easy access.

## Future Enhancements

### 1. User Interface Enhancements
- **Slide Functionality**: Add the ability to swipe left/right to view previous or next images in the full-screen ImageView.
- **Cloud Image Full-Screen View**: Implement a full-screen view for cloud images, similar to the local ImageView but without edit options.

### 2. Security and User Management
- **Forgot Password**: Implement a password recovery feature in the sign-in process.
- **Email Verification**: Add a verification step for new users.
- **Google Authorization**: Integrate Google sign-in for seamless user access.
- **Edit Profile**: Allow users to update their profile information and change their password.
- **Hidden Folder/Album**: Add a feature to create hidden folders/albums, with passcode reset functionality via email.

### 3. Local Storage Management
- **Recently Deleted**: Implement a feature for recently deleted items, allowing users to restore deleted photos/videos for a limited time.

## Getting Started

### Prerequisites
Ensure you have the following installed:
- [Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or Visual Studio Code with Flutter plugin
- Firebase project set up with Firestore and Storage

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/username/photoarc-gallery.git
   ```
2. Navigate to the project directory:
   ```bash
   cd photoarc-gallery
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Firebase Configuration
1. **Set up your Firebase project**:
   - Create a project in the [Firebase console](https://console.firebase.google.com/).
   - Enable Authentication, Firestore Database, and Cloud Storage.

2. **Download `google-services.json`**:
   - Navigate to **Project Settings** > **General**.
   - Download `google-services.json` for Android and place it in `android/app`.
   - For iOS, download `GoogleService-Info.plist` and place it in `ios/Runner`.

3. **Update Gradle Files**:
   - Add Firebase dependencies in `android/build.gradle` and `android/app/build.gradle`.

4. **FlutterFire CLI Setup**:
   - Run the following command to set up Firebase automatically:
     ```bash
     flutterfire configure --project={Project ID}
     ```
   - Refer to the [YouTube tutorial](https://youtu.be/fm79vu4hTKo) for more details.

5. **Add Firebase Core Dependencies**:
   - Include the required dependencies in `pubspec.yaml`:
     ```yaml
     dependencies:
       firebase_core: ^{latest_version}
       firebase_auth: ^{latest_version}
       firebase_storage: ^{latest_version}
     ```

6. **Generate `firebase_options.dart`**:
   - Run the project once with `flutterfire configure` to automatically create `firebase_options.dart` in the `lib` directory.

## Screenshots


## Contributing
Contributions are welcome! Feel free to submit a pull request or open an issue.

---

**Enjoy using PhotoArc and experience seamless photo management at your fingertips!**