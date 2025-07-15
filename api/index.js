// index.js
require('dotenv').config(); // .env dosyasını yüklemek için

const cors = require('cors');
const express = require('express');
const mongoose = require('mongoose'); // mongoose'u dahil et

const app = express();
const PORT = process.env.PORT || 3000; // Render'ın verdiği portu kullan, yoksa 3000'i kullan

app.use(cors()); // Gelen tüm isteklere izin ver
// JSON verilerini okuyabilmek için middleware
app.use(express.json());

// Veritabanı bağlantısı
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB veritabanına başarıyla bağlanıldı.');
    // Veritabanı bağlantısı başarılı olursa sunucuyu başlat
    app.listen(PORT, () => {
      console.log(`API sunucusu http://localhost:${PORT} adresinde başlatıldı`);
    });
  })
  .catch((err) => {
    console.error('Veritabanı bağlantı hatası:', err);
  });




// Ana yol için bir GET isteği oluşturuyoruz
app.get('/', (req, res) => {
  res.send('Rize Kültür Projesi API Çalışıyor ve Veritabanına Bağlı!!');
});

// Sunucuyu dinlemeye başlıyoruz
app.listen(port, () => {
  console.log(`API sunucusu http://localhost:${port} adresinde başlatıldı`);
});

// Rotaları Kullan
app.use('/api/mekanlar', require('./routes/authRoutes'));
app.use('/api/auth', require('./routes/authRoutes')); 
app.use('/api/yorumlar', require('./routes/yorumRoutes')); 