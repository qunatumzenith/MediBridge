# MediBridge - Healthcare Mobile Application

MediBridge is a comprehensive healthcare mobile application built with Flutter and Firebase, designed to provide users with easy access to healthcare services and medication management.

## Features

1. **Authentication & User Profile**
   - Google Sign-in
   - Detailed user profile with personal information
   - Emergency contact (nominee) management

2. **Medicine Reminder System**
   - Set reminders for medicines
   - Track medication adherence
   - Multiple time slots (morning, afternoon, night)

3. **Online Pharmacy**
   - Browse and search medicines
   - Add to cart functionality
   - Place orders

4. **Nearby Laboratories**
   - View list of available labs
   - Contact information
   - Services offered

5. **Doctor Appointment Booking**
   - Search by speciality
   - View doctor profiles
   - Book appointments with preferred time slots

6. **Health Chatbot Support**
   - Basic health advice
   - Symptom-based suggestions
   - Medical consultation recommendations

7. **Emergency Support**
   - Quick access emergency button
   - Sends emergency alerts with user information

## Setup Instructions

1. **Prerequisites**
   - Flutter SDK (2.19.0 or higher)
   - Firebase account
   - Android Studio / VS Code

2. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Google Sign-in)
   - Set up Cloud Firestore
   - Download and add google-services.json to android/app/
   - Add Firebase configuration to iOS/Runner/

3. **Project Setup**
   ```bash
   # Clone the repository
   git clone [repository-url]

   # Navigate to project directory
   cd medibridge

   # Install dependencies
   flutter pub get

   # Run the application
   flutter run
   ```

4. **Firebase Collections Structure**
   - users
     - profile information
     - nominees
     - health issues
   - medicines
     - name
     - description
     - price
   - doctors
     - name
     - speciality
     - experience
     - fee
   - appointments
     - user details
     - doctor details
     - date and time
   - orders
     - user details
     - items
     - status

## Environment Setup

1. Create a `.env` file in the project root with the following variables:
   ```
   FIREBASE_API_KEY=your_api_key
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   ```

2. Update the Firebase configuration in `lib/firebase_options.dart`

## Contributing

1. Fork the repository
2. Create a new branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@medibridge.com or create an issue in the repository. 