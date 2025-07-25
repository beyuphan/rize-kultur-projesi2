// index.js (NİHAİ VE DOĞRU SIRALAMALI HALİ)

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware'ler
app.use(cors());
app.use(express.json());

// Veritabanı Bağlantısı
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB veritabanına başarıyla bağlanıldı.');

    // --- ADIM 1: ÖNCE TÜM MODELLERİ TANITIYORUZ ---
    // Bu, Mongoose'un tüm referansları ('populate') doğru şekilde
    // çözebilmesi için kritik öneme sahiptir.
    require('./models/Kullanici');
    require('./models/Mekan');
    require('./models/Yorum');
    
    // --- ADIM 2: MODELLER TANINDIKTAN SONRA ROTALARI ÇAĞIRIYORUZ ---
    const authRoutes = require('./routes/authRoutes');
    const mekanRoutes = require('./routes/mekanRoutes');
    const yorumRoutes = require('./routes/yorumRoutes');

    // Rotaları Kullan
    app.use('/api/auth', authRoutes);
    app.use('/api/mekanlar', mekanRoutes);
    app.use('/api/yorumlar', yorumRoutes);
    app.use('/api/users', require('./routes/userRoutes')); 

    app.get('/', (req, res) => {
      res.send('Rize Kültür Projesi API Çalışıyor!');
    });

    // --- ADIM 3: HER ŞEY HAZIR, SUNUCUYU BAŞLAT ---
    app.listen(PORT, () => {
      console.log(`API sunucusu http://localhost:${PORT} adresinde başlatıldı`);
    });
  })
  .catch((err) => {
    console.error('Veritabanı bağlantı hatası:', err);
    process.exit(1);
  });