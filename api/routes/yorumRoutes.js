// routes/yorumRoutes.js

const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth'); // Güvenlik görevlimizi dahil ediyoruz
const Yorum = require('../models/Yorum');
const Mekan = require('../models/Mekan');
const Kullanici = require('../models/Kullanici');

// @route   GET api/yorumlar/:mekanId
// @desc    Bir mekana ait tüm yorumları getirir
// @access  Public
router.get('/:mekanId', async (req, res) => {
    try {
        const yorumlar = await Yorum.find({ mekan: req.params.mekanId })
            .populate('yazar', ['kullaniciAdi']) // Yazarın sadece kullanıcı adını getir
            .sort({ yorumTarihi: -1 }); // En yeni yorumlar en üstte

        res.json(yorumlar);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});



// @route   POST api/yorumlar/:mekanId
// @desc    Bir mekana yeni bir yorum/puan ekler veya mevcut olanı günceller
// @access  Private
router.post('/:mekanId', auth, async (req, res) => {
    try {
        const mekan = await Mekan.findById(req.params.mekanId);
        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }

        // Kullanıcının bu mekana daha önce yorum yapıp yapmadığını kontrol et
        let yorum = await Yorum.findOne({ mekan: req.params.mekanId, yazar: req.kullanici.id });

        if (yorum) {
            // Yorum zaten var: Güncelle
            if (req.body.puan) yorum.puan = req.body.puan;
            if (req.body.icerik) yorum.icerik = req.body.icerik;
        } else {
            // Yorum yok: Yeni oluştur
            yorum = new Yorum({
                icerik: req.body.icerik,
                puan: req.body.puan,
                yazar: req.kullanici.id,
                mekan: req.params.mekanId
            });
        }

        await yorum.save();

        // Cevabı, yazar bilgileriyle birlikte zenginleştirip gönder
        const populatedYorum = await yorum.populate('yazar', ['kullaniciAdi', 'profilFotoUrl']);
        res.status(yorum.isNew ? 201 : 200).json(populatedYorum);

    } catch (err) {
        console.error("YORUM GÖNDERME HATASI:", err);
        // Hataları her zaman JSON olarak gönder
        res.status(500).json({ msg: 'Sunucu Hatası', error: err.message });
    }
});


// @route   GET api/yorumlar/kullanici/me
// @desc    Giriş yapmış kullanıcının tüm yorumlarını getirir
// @access  Private
router.get('/kullanici/me', auth, async (req, res) => {
   console.log(`\n--- KULLANICI YORUMLARI İSTEĞİ GELDİ: UserID = ${req.kullanici.id} ---`);
    try {
        console.log("[1] Kullanıcının yorumları aranıyor ve mekan bilgileri populate ediliyor...");
        const yorumlar = await Yorum.find({ yazar: req.kullanici.id })
            .populate('mekan', 'isim fotograflar')
            .sort({ yorumTarihi: -1 });
        console.log(`[2] Yorumlar başarıyla bulundu ve populate edildi. Adet: ${yorumlar.length}`);

        res.json(yorumlar);
        console.log("--- KULLANICI YORUMLARI İSTEĞİ BAŞARIYLA BİTTİ ---");
    } catch (err) {
        console.error("\n!!! KULLANICI YORUMLARI ROTASINDA KRİTİK HATA !!!");
        console.error(err);
        res.status(500).json({ msg: 'Sunucu Hatası', error: err.message });
    }
});

module.exports = router;