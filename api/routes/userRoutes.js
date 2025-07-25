// api/routes/userRoutes.js

const express = require('express');
const router = express.Router();
const Kullanici = require('../models/Kullanici');
const Yorum = require('../models/Yorum');

// @route   GET api/users/:userId
// @desc    ID ile tek bir kullanıcının halka açık profil bilgilerini getirir
// @access  Public
router.get('/:userId', async (req, res) => {
    try {
        // 1. Sadece halka açık olması gereken kullanıcı bilgilerini seçerek al
        const kullanici = await Kullanici.findById(req.params.userId).select('kullaniciAdi profilFotoUrl');

        if (!kullanici) {
            return res.status(404).json({ msg: 'Kullanıcı bulunamadı' });
        }

        // 2. Bu kullanıcının yaptığı tüm yorumları al
        const yorumlar = await Yorum.find({ yazar: req.params.userId })
            .populate('mekan', 'isim fotograflar') // Yorumun hangi mekana yapıldığını göster
            .populate('yazar', 'kullaniciAdi profilFotoUrl') // <-- BU SATIRI EKLE
            .sort({ yorumTarihi: -1 });

        // 3. Kullanıcı bilgileri ve yorumlarını birleştirip gönder
        res.json({
            kullanici: kullanici,
            yorumlar: yorumlar
        });

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Sunucu Hatası' });
    }
});

module.exports = router;