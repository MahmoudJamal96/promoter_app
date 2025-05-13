# Promoter App

A Flutter application for field representatives (promoters) to manage client visits and tasks.

## Project Architecture

This project uses:

- **Clean Architecture** principles for structural organization
- **BLoC Pattern** for state management
- **GetIt** for dependency injection
- **Dio** with logger cubits for HTTP requests 
- **Dartz** for functional error handling

## Project Structure

```
lib/
│
├── core/                  # Core functionality and utilities
│   ├── di/                # Dependency injection
│   ├── error/             # Exception and failure handling
│   ├── loggers/           # Logging with cubits
│   │   ├── logger_cubit/  # Cubit for logging
│   │   └── interceptors/  # Dio interceptors for logging
│   ├── network/           # Network layer
│   └── usecases/          # Base usecases
│
├── features/              # Application features
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Data layer
│   │   ├── domain/        # Domain layer
│   │   └── presentation/  # Presentation layer with BLoC
│   │
│   ├── client/            # Client management feature
│   │   ├── data/  
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── dashboard/         # Dashboard and main navigation
│
└── main.dart              # Application entry point
```

## Getting Started

1. Install dependencies:

```bash
flutter pub get
```

2. Run the application:

```bash
flutter run
```

## Architecture Overview

### Layers

1. **Presentation Layer**
   - BLoC/Cubit: Manages state and UI logic
   - Screens: UI components

2. **Domain Layer**
   - Entities: Business objects
   - Repositories: Abstract repository definitions
   - Usecases: Business logic operations

3. **Data Layer**
   - Models: Data representations of entities
   - Repositories: Implementations of domain repositories
   - Datasources: Data providers (API, local storage)

### State Management

The app uses the BLoC (Business Logic Component) pattern with cubits for simpler state management flows. This provides:

- Clear separation of UI and business logic
- Predictable state transitions
- Testable components

### Networking

The networking layer uses:

- Dio for HTTP requests
- LoggerCubit for intercepting and logging requests/responses
- Functional error handling with Either from Dartz

## Styling and Theming

The app follows a consistent theme defined in `app_theme.dart` and uses:

- Material Design components
- RTL support for Arabic language
- Custom animations with Flutter Animate
- Responsive sizing with ScreenUtil
