// api/routes/rotaRoutes.js

const express = require('express');
const router = express.Router();
const Rota = require('../models/Rota');
const { Client } = require("@googlemaps/google-maps-services-js");

// Rota durakları arasındaki mesafeyi ve süreyi hesaplayıp güncelleyen fonksiyon
async function mesafeleriHesaplaVeGuncelle(rotaId) {
  try {
    const googleMapsClient = new Client({});
    const rota = await Rota.findById(rotaId).populate('duraklar.mekanId');

    if (!rota || rota.duraklar.length < 2) {
      console.log('Mesafe hesaplaması için en az 2 durak gerekli.');
      return;
    }

    console.log("Koordinatlar okunuyor...");

    for (let i = 0; i < rota.duraklar.length - 1; i++) {
      
      // --- ANA DÜZELTME: KOORDİNATLARI DOĞRU YERDEN OKUMA ---
      const baslangic_enlem = rota.duraklar[i].mekanId.konum.enlem;
      const baslangic_boylam = rota.duraklar[i].mekanId.konum.boylam;
      
      const bitis_enlem = rota.duraklar[i + 1].mekanId.konum.enlem;
      const bitis_boylam = rota.duraklar[i + 1].mekanId.konum.boylam;

      console.log(`Durak ${i}: ${baslangic_enlem}, ${baslangic_boylam} -> Durak ${i+1}: ${bitis_enlem}, ${bitis_boylam}`);

      if (!baslangic_enlem || !bitis_enlem) {
        console.error("HATA: Enlem veya boylam bilgisi eksik, bu durak atlanıyor.");
        continue; // Bu durağı atla, döngüye devam et
      }
      
      const request = {
        params: {
          // Google Maps'in istediği formatta { lat: ..., lng: ... } gönderiyoruz.
          origin: { lat: baslangic_enlem, lng: baslangic_boylam },
          destination: { lat: bitis_enlem, lng: bitis_boylam },
          mode: 'DRIVING',
          key: process.env.Maps_API_KEY,
        },
      };
      
      const response = await googleMapsClient.directions(request);
      
      if (response.data.routes.length > 0 && response.data.routes[0].legs.length > 0) {
        const leg = response.data.routes[0].legs[0];
        // Hesaplanan veriyi ilgili durağın içine yazıyoruz.
        rota.duraklar[i].sonrakiDuragaMesafe = leg.distance.text;
        rota.duraklar[i].sonrakiDuragaSure = leg.duration.text;
        console.log(` -> Mesafe: ${leg.distance.text}, Süre: ${leg.duration.text}`);
      } else {
        console.log(` -> Google Maps'ten bu iki nokta için rota bulunamadı.`);
      }
    }

    // Değişikliği Mongoose'a bildiriyoruz.
    rota.markModified('duraklar');
    // Ve kaydediyoruz.
    await rota.save();
    console.log(`'${rota.ad.tr}' rotası için mesafeler başarıyla güncellendi ve kaydedildi.`);

  } catch (error) {
    // Hatayı daha detaylı loglayalım
    console.error("Mesafe hesaplama fonksiyonunda büyük bir hata oluştu:", error.response ? error.response.data : error.message);
  }
}
// @route   GET api/rotalar
// @desc    Tüm rotaların listesini getirir
// @access  Public
router.get('/', async (req, res) => {
    try {
        // Not: Rota listesi için mekan detaylarını göndermiyoruz,
        // bu yüzden burada populate'e gerek yok. Bu, listeyi daha hızlı yükler.
        const rotalar = await Rota.find();
        res.json(rotalar);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Sunucu Hatası' });
    }
});

// @route   GET api/rotalar/:id
// @desc    Belirli bir rotanın detayını, içindeki mekan bilgileriyle birlikte getirir
// @access  Public
router.get('/:id', async (req, res) => {
    try {
        // --- DÜZELTME BURADA ---
        // Artık 'mekanIdleri' yerine, 'duraklar' dizisinin içindeki 'mekanId' alanını populate ediyoruz.
        const rota = await Rota.findById(req.params.id)
            .populate('duraklar.mekanId'); // Mongoose'un bu "nested populate" özelliği harika!

        if (!rota) {
            return res.status(404).json({ msg: 'Rota bulunamadı' });
        }
        res.json(rota);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Sunucu Hatası' });
    }
});


// --- YENİ KODU BURAYA EKLE ---
// @route   GET api/rotalar/hesapla/:id
// @desc    Belirli bir rota için duraklar arası mesafeyi hesaplar ve veritabanına kaydeder.
// @access  Public (Sadece sen bileceğin için sorun yok)
router.get('/hesapla/:id', async (req, res) => {
  try {
    const rotaId = req.params.id;
    console.log(`'${rotaId}' ID'li rota için mesafe hesaplama işlemi başlatıldı...`);
    
    // Daha önce yazdığımız ana fonksiyonu burada çağırıyoruz.
    await mesafeleriHesaplaVeGuncelle(rotaId);
    
    // İşlem bittikten sonra tarayıcıya basit bir mesaj gönderiyoruz.
    res.send(`'${rotaId}' ID'li rota için mesafe ve süre bilgileri başarıyla hesaplanıp veritabanına kaydedildi. Uygulamayı kontrol edebilirsin.`);

  } catch (err) {
    console.error("Manuel hesaplama sırasında hata:", err);
    res.status(500).json({ msg: 'Hesaplama sırasında sunucu hatası oluştu.' });
  }
});


module.exports = router;
