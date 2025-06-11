# Campsite Finder 🏕️

A Flutter web application for discovering and exploring campsites. Built as part of a mobile development coding challenge, this app provides a comprehensive platform for campers to browse, filter, and view detailed information about camping sites.

## 🌟 Features

### Core Functionality
- **Campsite Listing**: Browse all available campsites in a responsive grid layout
- **Advanced Filtering**: Filter campsites by multiple criteria:
    - Search by name or country
    - Close to water availability
    - Campfire permissions
    - Host languages
    - Price range
    - Country selection
- **Detailed View**: View comprehensive campsite information
- **Map Integration**: Visualize campsites on an interactive map
- **Responsive Design**: Optimized for mobile, tablet, and desktop

### Technical Features
- **State Management**: Powered by Riverpod for robust state management
- **API Integration**: Real-time data fetching from RESTful API
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Loading States**: Smooth loading indicators and skeleton screens
- **Navigation**: Clean routing with GoRouter

## 🚀 Live Demo

**[View Live App](https://mhdamhd.github.io/campsite-finder/)**

## 🛠️ Tech Stack

- **Framework**: Flutter 3.32.2
- **Language**: Dart 3.8.1
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Maps**: Flutter Map with OpenStreetMap
- **Testing**: Unit tests with flutter_test

## 🔧 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/mhdamhd/campsite-finder
   cd campsite-finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3**Run the app**
   ```bash
   # For web
   flutter run -d chrome
   
   # For mobile (with device connected)
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/         # App constants
│   └── utils/            # Utility functions
├── models/               # Data models
├── providers/            # Riverpod providers
├── presentation/
│   ├── views/           # Screen widgets
│   └── widgets/         # Reusable widgets
├── services/            # API and external services
└── main.dart           # App entry point
```

## 🔧 Key Components

### State Management
The app uses **Riverpod** for state management with the following key providers:

- `campsitesProvider`: Fetches campsite data from API
- `filtersProvider`: Manages filter state
- `filteredCampsitesProvider`: Provides filtered campsite results
- `campsiteByIdProvider`: Retrieves individual campsite details

### API Integration
- **Base URL**: `https://62ed0389a785760e67622eb2.mockapi.io/spots/v1`
- **Endpoint**: `/campsites`
- **Error Handling**: Comprehensive error handling with custom exceptions
- **Timeout Configuration**: 10-second connection and receive timeouts

### Filtering System
Advanced filtering capabilities include:
- Search query (name/country)
- Close to water (boolean)
- Campfire allowed (boolean)
- Host languages (multi-select)
- Price range (min/max)
- Country selection


## 🧪 Testing

Run the test suite:
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 📱 Platform Support

- ✅ **Web** (Primary target)
- ✅ **Android**
- ✅ **iOS**

## 🚀 Deployment

### GitHub Pages Deployment
This app is automatically deployed to GitHub Pages. See the deployment section below for setup instructions.

### Manual Build
```bash
# Build for web
flutter build web --release

# Build for Android
flutter build apk --release
```

## 🔄 API Data Structure

The app consumes campsite data with the following structure:
```json
{
  "id": "string",
  "label": "string",
  "photo": "string (URL)",
  "geoLocation": {
    "lat": "number",
    "long": "number"
  },
  "isCloseToWater": "boolean",
  "isCampFireAllowed": "boolean",
  "hostLanguages": ["string"],
  "pricePerNight": "number (cents)",
  "suitableFor": ["string"],
  "createdAt": "ISO date string"
}
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 Development Guidelines

- Follow Flutter/Dart best practices
- Use Riverpod for state management
- Write unit tests for new features
- Maintain responsive design principles
- Keep code well-documented

## 🔮 Future Enhancements

- [ ] Map clustering for better visualization
- [ ] Offline caching
- [ ] User favorites/bookmarks
- [ ] Advanced sorting options
- [ ] Campsite reviews and ratings
- [ ] Dark mode support

## 👨‍💻 Author

**Mohammad Mohammad**
- GitHub: https://github.com/mhdamhd
- LinkedIn: https://www.linkedin.com/in/mhdamhd/
- Website: https://mhdaeoubmhd.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod community for state management solutions
- OpenStreetMap for map tiles
- MockAPI for providing test data

---

**Built with ❤️ using Flutter**