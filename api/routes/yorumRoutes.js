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
// @desc    Bir mekana yeni bir yorum/puan ekler
// @access  Private
router.post('/:mekanId', auth, async (req, res) => {
    try {
        const mekan = await Mekan.findById(req.params.mekanId);
        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }
        
        // Önce kullanıcının bu mekana daha önce yorum yapıp yapmadığını kontrol et
        const mevcutYorum = await Yorum.findOne({ mekan: req.params.mekanId, yazar: req.kullanici.id });
        if (mevcutYorum) {
            // Eğer sadece puan veya sadece yorumu güncellemek istiyorsa
            if (req.body.puan) mevcutYorum.puan = req.body.puan;
            if (req.body.icerik) mevcutYorum.icerik = req.body.icerik;
            
            const guncellenenYorum = await mevcutYorum.save();
            return res.status(200).json(guncellenenYorum);
        }

        // Yeni yorum oluştur
        const yeniYorum = new Yorum({
            icerik: req.body.icerik,
            puan: req.body.puan,
            yazar: req.kullanici.id,
            mekan: req.params.mekanId
        });

        const yorum = await yeniYorum.save();

        // Yorumu döndürürken yazar bilgilerini de ekle
        const populatedYorum = await yorum.populate('yazar', ['kullaniciAdi', 'profilFotoUrl']);

        res.status(201).json(populatedYorum);

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});

module.exports = router;