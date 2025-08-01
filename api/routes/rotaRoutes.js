// api/routes/rotaRoutes.js

const express = require('express');
const router = express.Router();
const Rota = require('../models/Rota');
const { Client } = require("@googlemaps/google-maps-services-js");
const Rota = require('../models/Rota'); // Rota modelini import et

// Rota durakları arasındaki mesafeyi ve süreyi hesaplayıp güncelleyen fonksiyon
async function mesafeleriHesaplaVeGuncelle(rotaId) {
  try {
    const googleMapsClient = new Client({});
    const rota = await Rota.findById(rotaId).populate('duraklar.mekanId');

    if (!rota || rota.duraklar.length < 2) {
      console.log('Mesafe hesaplaması için en az 2 durak gerekli.');
      return;
    }

    // Duraklar arasında sırayla gezip Directions API'ye istek atacağız
    for (let i = 0; i < rota.duraklar.length - 1; i++) {
      const baslangic = rota.duraklar[i].mekanId.konum.coordinates;
      const bitis = rota.duraklar[i + 1].mekanId.konum.coordinates;

      const request = {
        params: {
          origin: { lat: baslangic[1], lng: baslangic[0] },
          destination: { lat: bitis[1], lng: bitis[0] },
          mode: 'DRIVING', // Araba ile
          key: process.env.Maps_API_KEY,
        },
      };
      
      const response = await googleMapsClient.directions(request);
      
      if (response.data.routes.length > 0) {
        const leg = response.data.routes[0].legs[0];
        // Bulunan mesafe ve süre bilgisini rotanın ilgili durağına kaydet
        rota.duraklar[i].sonrakiDuragaMesafe = leg.distance.text; // "21.4 km"
        rota.duraklar[i].sonrakiDuragaSure = leg.duration.text;   // "35 mins"
      }
    }

    // Değişiklikleri veritabanına kaydet
    await rota.save();
    console.log(`'${rota.ad.tr}' rotası için mesafeler başarıyla güncellendi.`);

  } catch (error) {
    console.error("Mesafe hesaplama hatası:", error);
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

module.exports = router;
