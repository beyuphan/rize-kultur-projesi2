// api/routes/rotaRoutes.js

const express = require('express');
const router = express.Router();
const Rota = require('../models/Rota');

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
