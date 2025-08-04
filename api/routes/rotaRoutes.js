// api/routes/rotaRoutes.js

const express = require('express');
const router = express.Router();
const Rota = require('../models/Rota');
const { Client } = require("@googlemaps/google-maps-services-js");

// Rota durakları arasındaki mesafeyi ve süreyi hesaplayıp güncelleyen fonksiyon (SÜPER DEBUG VERSİYONU)
async function mesafeleriHesaplaVeGuncelle(rotaId) {
  console.log("--- HESAPLAMA FONKSİYONU BAŞLADI ---");
  try {
    const googleMapsClient = new Client({});
    
    console.log(`[1] Rota aranıyor... ID: ${rotaId}`);
    const rota = await Rota.findById(rotaId).populate('duraklar.mekanId').lean();

    if (!rota) {
      console.error("!!!! HATA: Rota veritabanında bulunamadı. !!!!");
      return;
    }
    console.log(`[2] Rota bulundu: '${rota.ad.tr}'. Durak sayısı: ${rota.duraklar.length}`);

    if (rota.duraklar.length < 2) {
      console.log("[!] Mesafe hesaplaması için en az 2 durak gerekli. İşlem sonlandırıldı.");
      return;
    }

    console.log("[3] Duraklar arası mesafe hesaplama döngüsü başlıyor...");
    for (let i = 0; i < rota.duraklar.length - 1; i++) {
      console.log(`\n  -> Döngü Adımı: ${i}`);
      
      const baslangicDurak = rota.duraklar[i];
      const bitisDurak = rota.duraklar[i+1];

      if (!baslangicDurak.mekanId || !bitisDurak.mekanId) {
          console.error(`  !!!! HATA: Durak ${i} veya ${i+1} için mekan bilgisi (mekanId) populate edilememiş. Atlanıyor.`);
          continue;
      }
      if (!baslangicDurak.mekanId.konum || !bitisDurak.mekanId.konum) {
          console.error(`  !!!! HATA: Durak ${i} veya ${i+1} için 'konum' objesi eksik. Atlanıyor.`);
          continue;
      }

      const baslangic_enlem = baslangicDurak.mekanId.konum.enlem;
      const baslangic_boylam = baslangicDurak.mekanId.konum.boylam;
      const bitis_enlem = bitisDurak.mekanId.konum.enlem;
      const bitis_boylam = bitisDurak.mekanId.konum.boylam;

      console.log(`  [A] Koordinatlar okundu: BAŞLANGIÇ(${baslangic_enlem}, ${baslangic_boylam}) -> BİTİŞ(${bitis_enlem}, ${bitis_boylam})`);

      if (!baslangic_enlem || !baslangic_boylam || !bitis_enlem || !bitis_boylam) {
        console.error("  !!!! HATA: Enlem veya boylam değerlerinden biri boş (null/undefined). Bu adım atlanıyor.");
        continue;
      }
      
      const requestParams = {
        origin: { lat: baslangic_enlem, lng: baslangic_boylam },
        destination: { lat: bitis_enlem, lng: bitis_boylam },
        mode: 'DRIVING',
        key: '... senin API anahtarının son 4 hanesi ...', // API anahtarını buraya loglama, sadece kontrol et
      };
      
      console.log("  [B] Google Maps'e istek gönderiliyor...");
      try {
        const response = await googleMapsClient.directions({ params: requestParams });
        
        if (response.data.status === 'OK' && response.data.routes.length > 0) {
          const leg = response.data.routes[0].legs[0];
          baslangicDurak.sonrakiDuragaMesafe = leg.distance.text;
          baslangicDurak.sonrakiDuragaSure = leg.duration.text;
          console.log(`  [C] BAŞARILI: Mesafe=${leg.distance.text}, Süre=${leg.duration.text}. Veri modele yazıldı.`);
        } else {
          console.error(`  !!!! GOOGLE API HATASI: Status: ${response.data.status}. Hata Mesajı: ${response.data.error_message || 'Yok'}`);
        }

      } catch (apiError) {
         console.error(`  !!!! GOOGLE API ÇAĞRISINDA KRİTİK HATA !!!!`);
         console.error(apiError.response ? apiError.response.data : apiError.message);
      }
    }

    console.log("\n[4] Döngü bitti. Veritabanına kaydetme işlemi deneniyor...");
    rota.markModified('duraklar');
    await rota.save();
    console.log("[5] BAŞARILI: Değişiklikler veritabanına kaydedildi.");

  } catch (error) {
    console.error("--- FONKSİYONDA YAKALANAMAYAN BÜYÜK HATA ---");
    console.error(error);
  }
  console.log("--- HESAPLAMA FONKSİYONU BİTTİ ---");
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
