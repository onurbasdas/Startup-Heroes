# Startup Heroes - iOS App Architecture

## Folder Structure

```
Startup Heroes/
├── Models/                    # Data models and entities
│   └── News.swift
│   └── NewsSource.swift
│
├── Views/                    # UI Components
│   ├── ViewControllers/      # View Controllers
│   │   └── NewsListViewController.swift
│   │   └── NewsDetailViewController.swift
│   └── CustomViews/          # Custom UI Components
│       └── NewsTableViewCell.swift
│
├── Services/                 # Network and API services
│   └── NewsAPIService.swift
│   └── NetworkService.swift
│
├── Managers/                 # Business logic managers
│   └── ReadingListManager.swift
│   └── NetworkMonitor.swift
│
├── Utilities/                # Helpers and extensions
│   └── Extensions/
│   └── Constants.swift
│
└── Resources/                # Assets, Storyboards
    └── Assets.xcassets/
    └── Base.lproj/
```

## Architecture Principles

- **SOLID Principles**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **MVVM Pattern**: Model-View-ViewModel for better testability
- **Dependency Injection**: For better testability and loose coupling
- **Protocol-Oriented Programming**: Using protocols for abstraction

## Layer Responsibilities

### Models
- Data structures representing API responses
- Codable conforming models for JSON parsing

### Views
- ViewControllers handle UI presentation
- CustomViews for reusable UI components
- No business logic in views

### Services
- API communication layer
- Network request handling
- Response parsing

### Managers
- Business logic implementation
- Data persistence (Reading List)
- Network monitoring

### Utilities
- Helper functions
- Extensions for UIKit/Swift types
- Constants and configuration

