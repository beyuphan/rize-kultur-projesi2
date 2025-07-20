// .env dosyasındaki değişkenleri yükler
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

// Rota dosyalarını dahil ediyoruz
const authRoutes = require('./routes/authRoutes');
const mekanRoutes = require('./routes/mekanRoutes');
const yorumRoutes = require('./routes/yorumRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware'ler
app.use(cors());
app.use(express.json());

// Veritabanı Bağlantısı
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB veritabanına başarıyla bağlanıldı.');

    // --- İŞTE ÇÖZÜM BURADA ---
    // Sunucuyu başlatmadan ve rotaları kullanmadan önce,
    // tüm modelleri bir kere burada çağırarak Mongoose'a tanıtıyoruz.
    require('./models/Kullanici');
    require('./models/Mekan');
    require('./models/Yorum');
    // -------------------------

    // Rotaları Kullanma
    app.use('/api/auth', authRoutes);
    app.use('/api/mekanlar', mekanRoutes);
    app.use('/api/yorumlar', yorumRoutes);

    // Ana yol için bir GET isteği
    app.get('/', (req, res) => {
      res.send('Rize Kültür Projesi API Çalışıyor!');
    });

    // Sunucuyu Başlatma
    app.listen(PORT, () => {
      console.log(`API sunucusu http://localhost:${PORT} adresinde başlatıldı`);
    });
  })
  .catch((err) => {
    console.error('Veritabanı bağlantı hatası:', err);
    process.exit(1); // Bağlantı hatası varsa uygulamayı sonlandır.
  });
