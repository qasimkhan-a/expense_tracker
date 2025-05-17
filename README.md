# Expense Tracker App

A beautiful, modern expense tracking application built with Flutter.

## Features

- Track your daily expenses
- Categorize expenses (food, transportation, shopping, etc.)
- View budget overview with progress indicator
- Visual breakdown of expenses by category
- Add new expenses with a sleek modal form
- Delete expenses with swipe action
- Modern and futuristic UI design

## Screenshots

(Screenshots will be available after running the app)

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android / iOS emulator or physical device

### Installation

1. Install Flutter by following the [official documentation](https://flutter.dev/docs/get-started/install)
2. Clone this repository:
   ```
   git clone https://github.com/yourusername/expense_tracker.git
   ```
3. Navigate to the project directory:
   ```
   cd expense_tracker
   ```
4. Install dependencies:
   ```
   flutter pub get
   ```
5. Run the app:
   ```
   flutter run
   ```

## Dependencies

- [provider](https://pub.dev/packages/provider) - State management
- [intl](https://pub.dev/packages/intl) - Date formatting
- [flutter_slidable](https://pub.dev/packages/flutter_slidable) - Slidable list items
- [google_fonts](https://pub.dev/packages/google_fonts) - Custom fonts
- [fl_chart](https://pub.dev/packages/fl_chart) - Beautiful charts

## Architecture

The app follows a simple Provider-based architecture:

- **Models**: Data structures for expenses and categories
- **Providers**: State management for expenses and budget
- **Screens**: Main UI components
- **Widgets**: Reusable UI components

## Future Enhancements

- Data persistence using SQLite or Hive
- User authentication
- Cloud sync
- Dark mode
- Multiple currency support
- Expense filtering and search
- Budget planning features
- Recurring expenses
- Export data to CSV/PDF

## License

This project is licensed under the MIT License - see the LICENSE file for details. 