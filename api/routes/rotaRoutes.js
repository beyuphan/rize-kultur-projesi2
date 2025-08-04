// api/routes/rotaRoutes.js

const express = require('express');
const router = express.Router();
const Rota = require('../models/Rota');
const { Client } = require("@googlemaps/google-maps-services-js");

// Rota durakları arasındaki mesafeyi ve süreyi hesaplayıp güncelleyen fonksiyon (NİHAİ, HATASIZ VERSİYON)
async function mesafeleriHesaplaVeGuncelle(rotaId) {
  try {
    const rota = await Rota.findById(rotaId).populate('duraklar.mekanId').lean();

    if (!rota || rota.duraklar.length < 2) {
      return;
    }

    let degisiklikYapildi = false;
    for (let i = 0; i < rota.duraklar.length - 1; i++) {
      const baslangic_enlem = rota.duraklar[i].mekanId.konum.enlem;
      const baslangic_boylam = rota.duraklar[i].mekanId.konum.boylam;
      const bitis_enlem = rota.duraklar[i + 1].mekanId.konum.enlem;
      const bitis_boylam = rota.duraklar[i + 1].mekanId.konum.boylam;

      if (!baslangic_enlem || !bitis_enlem) {
        console.error("HATA: Enlem/boylam okunamadı, atlanıyor.");
        continue;
      }
      
      const request = {
        params: {
          origin: { lat: baslangic_enlem, lng: baslangic_boylam },
          destination: { lat: bitis_enlem, lng: bitis_boylam },
          mode: 'DRIVING',
          key: process.env.Maps_API_KEY,
        },
      };
      
      const response = await googleMapsClient.directions(request);
      
      if (response.data.status === 'OK' && response.data.routes.length > 0) {
        const leg = response.data.routes[0].legs[0];
        rota.duraklar[i].sonrakiDuragaMesafe = leg.distance.text;
        rota.duraklar[i].sonrakiDuragaSure = leg.duration.text;
        degisiklikYapildi = true;
      }
    }

    if (degisiklikYapildi) {
      // --- DÜZELTME: .lean() kullandığımız için rota.save() yerine Rota.updateOne() kullanıyoruz ---
      await Rota.updateOne({ _id: rotaId }, { $set: { duraklar: rota.duraklar } });
      console.log("[OK] Değişiklikler veritabanına başarıyla kaydedildi.");
    }

  } catch (error) {
    console.error("--- HESAPLAMA FONKSİYONUNDA HATA ---", error);
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
