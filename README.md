# Rize Kültür – Cultural Heritage Platform

Rize şehrinin kültürel mirasını, yerel etkinlikleri ve turizm faaliyetlerini dijital ortamda tanıtan ve paylaşan bir platform. Backend API + Flutter mobil uygulama kombinasyonuyla, hem web hem mobil kullanıcılara erişim sağlar.

## 🎯 Proje Amacı

Rize'nin zengin kültürel değerlerini ve etkinliklerini:
- Dijitalleştirmek
- Yerel ve turist kullanıcılara ulaştırmak
- Etkileşimli bir platform üzerinde sunmak
- Gerçek zamanlı event bilgilendirmesi sağlamak

## 🏗️ Mimari

**Two-tier Architecture:**

```
┌─────────────────────┐
│   Flutter Mobile    │  (Android/iOS)
└──────────┬──────────┘
           │ REST API + JSON
           ▼
┌─────────────────────┐
│  Node.js Express    │  (Backend API)
│  - Routes           │
│  - Controllers      │
│  - Middleware       │
└──────────┬──────────┘
           │ Driver
           ▼
┌─────────────────────┐
│   MongoDB / MySQL   │  (Database)
└─────────────────────┘
```

## 📂 Project Structure

```
rize-kultur-projesi2/
├── api/                      # Node.js Express backend
│   ├── index.js             # Entry point
│   ├── config/              # Configuration
│   ├── routes/              # API routes
│   ├── controllers/         # Business logic
│   ├── models/              # Data models
│   ├── middleware/          # Auth, validation
│   ├── package.json         # Dependencies
│   └── Procfile             # Deployment config
│
└── mobil_flutter/           # Flutter mobile app
    ├── lib/
    │   ├── main.dart        # App entry
    │   ├── screens/         # UI screens
    │   ├── services/        # API client
    │   ├── models/          # Data classes
    │   └── widgets/         # Reusable components
    ├── pubspec.yaml         # Flutter deps
    └── README.md            # Mobile setup
```

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend API** | Node.js, Express.js, JavaScript |
| **Mobile App** | Flutter (Dart) |
| **Database** | MongoDB or MySQL |
| **Authentication** | JWT (JSON Web Tokens) |
| **API Style** | RESTful with JSON responses |
| **Build Tool** | Maven (backend), Flutter build (mobile) |

## ✨ Features

### Backend API
- ✅ Event management (create, read, update, delete)
- ✅ User authentication & authorization
- ✅ Image upload & media handling
- ✅ Search & filtering capabilities
- ✅ Real-time event notifications
- ✅ CORS support for mobile clients
- ✅ Error handling & validation

### Mobile App
- ✅ Browse cultural events & attractions
- ✅ Event details with images & descriptions
- ✅ User profile & saved favorites
- ✅ Real-time notifications
- ✅ Location-based features
- ✅ Smooth UI with Material Design 3
- ✅ Offline caching support

## 🚀 Quick Start

### Backend Setup

```bash
cd api/

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your database credentials

# Start development server
npm start
# Server runs on http://localhost:3000
```

### Mobile App Setup

```bash
cd mobil_flutter/

# Get Flutter dependencies
flutter pub get

# Configure API endpoint
# Edit lib/services/api_config.dart with your backend URL

# Run on emulator/device
flutter run

# Build APK (release)
flutter build apk --release
```

## 🔌 API Endpoints

```bash
# Events
GET    /api/events              # Get all events
GET    /api/events/:id          # Get event details
POST   /api/events              # Create event (admin)
PUT    /api/events/:id          # Update event (admin)
DELETE /api/events/:id          # Delete event (admin)

# Users
POST   /api/auth/register       # Register user
POST   /api/auth/login          # Login
GET    /api/users/:id           # Get user profile
PUT    /api/users/:id           # Update profile

# Images
POST   /api/upload              # Upload image
GET    /api/images/:id          # Get image
```

## 🔐 Environment Variables

Create `.env` in `api/` folder:

```env
# Server
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=mongodb://user:password@localhost:27017/rize_kultur
# OR for MySQL:
# DATABASE_URL=mysql://user:password@localhost:3306/rize_kultur

# Authentication
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRE=7d

# Mobile Client
MOBILE_API_URL=http://localhost:3000

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5000000

# Email (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
```

## 💾 Database Schema

### Events Collection
```json
{
  "_id": ObjectId,
  "title": "Rize Çay Festivali",
  "description": "Geleneksel çay yapım gösterisi",
  "category": "festival",
  "location": { "lat": 40.5, "lng": 40.5 },
  "date": "2024-06-21",
  "images": ["url1", "url2"],
  "createdBy": userId,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### Users Collection
```json
{
  "_id": ObjectId,
  "name": "Kullanıcı Adı",
  "email": "user@example.com",
  "password": "hashed_password",
  "profileImage": "url",
  "favorites": [eventIds],
  "createdAt": timestamp
}
```

## 🧪 Development Workflow

### Backend Development
```bash
cd api/

# Watch mode (auto-restart on changes)
npm run dev

# Run tests
npm test

# Format code
npm run format
```

### Mobile Development
```bash
cd mobil_flutter/

# Hot reload (during development)
flutter run
# Press 'r' in terminal for hot reload

# Run tests
flutter test

# Build for production
flutter build apk --release
flutter build ios --release
```

## 📦 Deployment

### API Deployment (Railway/Heroku)

```bash
cd api/

# Push to Railway
railway link
railway up

# Or Heroku
heroku create your-app-name
git push heroku main
```

See `api/DEPLOYMENT.md` for detailed instructions.

### Mobile Deployment

**Android:**
```bash
flutter build apk --release
# Upload to Google Play Store
```

**iOS:**
```bash
flutter build ios --release
# Archive and submit to App Store
```

## 🐛 Troubleshooting

### API Connection Error
- Check backend is running: `curl http://localhost:3000`
- Verify API endpoint in mobile app config
- Check CORS is enabled

### Database Connection Failed
- Verify DATABASE_URL format
- Check credentials
- Ensure database server is running

### Flutter Build Error
```bash
flutter clean
flutter pub get
flutter run
```

## 👥 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -m 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Open Pull Request

## 📄 Code Style

- **Backend**: Use ESLint config in `.eslintrc`
- **Mobile**: Follow Dart style guide
- Meaningful commit messages
- Clear variable & function names

## 📜 License

MIT License - see LICENSE file

## 📞 Contact & Support

- 📧 Email: eyuphan546@gmail.com
- 🔗 GitHub: https://github.com/beyuphan
- 🌐 Portfolio: https://eyuphan.netlify.app

---

**Last Updated**: June 2024  
**Status**: Active Development
