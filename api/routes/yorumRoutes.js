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
// @desc    Bir mekana yeni bir yorum ekler
// @access  Private (Sadece giriş yapanlar)
router.post('/:mekanId', auth, async (req, res) => {
    try {
        // Güvenlik görevlimiz sayesinde isteğin içinde kullanıcı ID'si var
        const kullanici = await Kullanici.findById(req.kullanici.id).select('-sifre');
        const mekan = await Mekan.findById(req.params.mekanId);

        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }

        const yeniYorum = new Yorum({
            icerik: req.body.icerik,
            puan: req.body.puan,
            yazar: req.kullanici.id, // Yorumu yapan kişi
            mekan: req.params.mekanId // Yorumun yapıldığı mekan
        });

        const yorum = await yeniYorum.save();

        res.status(201).json(yorum);

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});

module.exports = router;