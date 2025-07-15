// .env dosyasındaki değişkenleri yükler
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

// Rota dosyalarını en başta dahil ediyoruz
const authRoutes = require('./routes/authRoutes');
const mekanRoutes = require('./routes/mekanRoutes');
const yorumRoutes = require('./routes/yorumRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware'ler
app.use(cors());
app.use(express.json());

// Rotaları Doğru Şekilde Kullanma
// Her rotayı kendi dosyasına doğru bir şekilde yönlendiriyoruz
app.use('/api/auth', authRoutes);
app.use('/api/mekanlar', mekanRoutes); // DÜZELTİLDİ: Artık mekanRoutes'e gidiyor
app.use('/api/yorumlar', yorumRoutes);

// Ana yol için bir GET isteği
app.get('/', (req, res) => {
  res.send('Rize Kültür Projesi API Çalışıyor!');
});

// Veritabanı Bağlantısı ve Sunucuyu Başlatma
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB veritabanına başarıyla bağlanıldı.');
    // Sunucuyu SADECE veritabanı bağlantısı başarılı olursa başlatıyoruz.
    // Bu, en doğru ve güvenli yöntemdir.
    app.listen(PORT, () => {
      console.log(`API sunucusu http://localhost:${PORT} adresinde başlatıldı`);
    });
  })
  .catch((err) => {
    console.error('Veritabanı bağlantı hatası:', err);
  });
