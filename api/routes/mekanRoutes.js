// routes/mekanRoutes.js

const express = require('express');
const router = express.Router();
const Mekan = require('../models/Mekan'); // Daha önce oluşturduğumuz Mekan modelini içeri alıyoruz

// @route   GET api/mekanlar
// @desc    Tüm mekanları getirir
// @access  Public (Herkes erişebilir)
router.get('/', async (req, res) => {
    try {
        // Veritabanındaki tüm Mekan'ları bul ve en yeniden eskiye doğru sırala
        const mekanlar = await Mekan.find().sort({ eklenmeTarihi: -1 });
        res.json(mekanlar); // Bulunan mekanları JSON formatında cevap olarak gönder
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});

// @route   POST api/mekanlar
// @desc    Yeni bir mekan oluşturur
// @access  Private (Şimdilik Public, sonra admin yetkisi ekleyeceğiz)
router.post('/', async (req, res) => {
    try {
        // İstekle gelen verilerden yeni bir mekan oluşturuyoruz
        const yeniMekan = new Mekan({
            isim: req.body.isim,
            aciklama: req.body.aciklama,
            kategori: req.body.kategori,
            konum: req.body.konum
            // fotograflar gibi zorunlu olmayan alanlar daha sonra eklenebilir
        });

        // Yeni mekanı veritabanına kaydediyoruz
        const mekan = await yeniMekan.save();

        // Başarılı olursa, kaydedilen mekanı cevap olarak dönüyoruz
        res.status(201).json(mekan);

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});


// @route   GET api/mekanlar/:id
// @desc    ID ile tek bir mekanın detayını getirir
// @access  Public
router.get('/:id', async (req, res) => {
    try {
        // Adres çubuğundan gelen ID'yi kullanarak veritabanında mekanı bul
        const mekan = await Mekan.findById(req.params.id);

        // Eğer o ID ile bir mekan bulunamazsa, 404 Not Found hatası dön
        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }

        // Mekan bulunduysa, JSON olarak cevap dön
        res.json(mekan);
    } catch (err) {
        console.error(err.message);
        // Eğer gelen ID formatı geçersizse (örn: çok kısa veya çok uzunsa)
        // bu da bir "bulunamadı" hatasıdır.
        if (err.kind === 'ObjectId') {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }
        res.status(500).send('Sunucu Hatası');
    }
});


// @route   PUT api/mekanlar/:id
// @desc    Mevcut bir mekanı günceller
// @access  Private (Şimdilik Public)
router.put('/:id', async (req, res) => {
    try {
        // ID ile güncellenecek mekanı bul
        let mekan = await Mekan.findById(req.params.id);

        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }

        // Yeni verilerle mekanı güncelle
        // { new: true } parametresi, güncellenmiş halini cevap olarak dönmesini sağlar
        mekan = await Mekan.findByIdAndUpdate(
            req.params.id,
            { $set: req.body },
            { new: true }
        );

        res.json(mekan);

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});


// @route   DELETE api/mekanlar/:id
// @desc    Bir mekanı siler
// @access  Private (Şimdilik Public)
router.delete('/:id', async (req, res) => {
    try {
        let mekan = await Mekan.findById(req.params.id);

        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }

        await Mekan.findByIdAndDelete(req.params.id);

        res.json({ msg: 'Mekan başarıyla silindi' });

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});

module.exports = router; // Bu rotaları dışarıya açıyoruz