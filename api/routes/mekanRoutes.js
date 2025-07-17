// routes/mekanRoutes.js (GÜVENLİ VE TUTARLI HALİ)

const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth'); // Güvenlik için middleware'i dahil ediyoruz
const Mekan = require('../models/Mekan');
const Yorum = require('../models/Yorum');

// @route   GET api/mekanlar
// @desc    Tüm mekanları veya kategoriye göre filtrelenmiş mekanları getirir
// @access  Public
router.get('/', async (req, res) => {
    try {
        const { kategori } = req.query;
        const filtre = {};
        if (kategori && kategori !== 'categoryAll') {
            filtre.kategori = kategori;
        }

        // İYİLEŞTİRME: .select() ile sadece liste için gerekli alanları çekiyoruz.
        // Bu, gönderilen veri miktarını azaltır ve performansı artırır.
        const mekanlar = await Mekan.find(filtre)
            .select('isim kategori fotograflar ortalamaPuan konum')
            .sort({ eklenmeTarihi: -1 });
        
        res.json(mekanlar);
    } catch (err) {
        console.error(err.message);
        // DÜZELTME: Artık tüm hatalar JSON formatında gönderiliyor.
        res.status(500).json({ msg: 'Sunucu Hatası' });
    }
});

// @route   POST api/mekanlar
// @desc    Yeni bir mekan oluşturur
// @access  Private (Sadece giriş yapmış ve admin yetkisine sahip kullanıcılar)
router.post('/', auth, async (req, res) => { // GÜVENLİK: 'auth' middleware eklendi.
    try {
        // DÜZELTME: Çok-dilli yapıya uygun veri alımı
        const { isim, aciklama, kategori, konum, fotograflar } = req.body;

        // Gerekli alanların kontrolü
        if (!isim || !isim.tr || !isim.en || !aciklama || !kategori || !konum) {
            return res.status(400).json({ msg: 'Lütfen gerekli tüm alanları doldurun.' });
        }

        const yeniMekan = new Mekan({
            isim,
            aciklama,
            kategori,
            konum,
            fotograflar
        });

        const mekan = await yeniMekan.save();
        res.status(201).json(mekan);

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Sunucu Hatası' });
    }
});

// @route   GET api/mekanlar/:id
// @desc    ID ile tek bir mekanın detayını ve yorumlarını getirir
// @access  Public
router.get('/:id', async (req, res) => {
    try {
        const mekan = await Mekan.findById(req.params.id);
        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }

        const yorumlar = await Yorum.find({ mekan: req.params.id })
            .populate('yazar', 'kullaniciAdi profilFotoUrl')
            .sort({ yorumTarihi: -1 });

        res.json({
            mekan: mekan,
            yorumlar: yorumlar
        });
    } catch (err) {
        console.error("MEKAN DETAYI ÇEKİLİRKEN HATA OLUŞTU:", err);
        if (err.kind === 'ObjectId') {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }
        res.status(500).json({ 
            msg: 'Sunucu tarafında bir hata oluştu.', 
            error: err.message
        });
    }
});

// @route   PUT api/mekanlar/:id
// @desc    Mevcut bir mekanı günceller
// @access  Private
router.put('/:id', auth, async (req, res) => { // GÜVENLİK: 'auth' middleware eklendi.
    try {
        const mekan = await Mekan.findById(req.params.id);
        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }
        
        // DÜZELTME: req.body'yi doğrudan kullanmak yerine güncellenecek alanları belirliyoruz.
        const { isim, aciklama, kategori, konum, fotograflar } = req.body;
        const guncellenecekAlanlar = {};
        if (isim) guncellenecekAlanlar.isim = isim;
        if (aciklama) guncellenecekAlanlar.aciklama = aciklama;
        if (kategori) guncellenecekAlanlar.kategori = kategori;
        if (konum) guncellenecekAlanlar.konum = konum;
        if (fotograflar) guncellenecekAlanlar.fotograflar = fotograflar;
        
        const guncellenmisMekan = await Mekan.findByIdAndUpdate(
            req.params.id,
            { $set: guncellenecekAlanlar },
            { new: true }
        );

        res.json(guncellenmisMekan);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Sunucu Hatası' });
    }
});

// @route   DELETE api/mekanlar/:id
// @desc    Bir mekanı ve ilgili tüm yorumları siler
// @access  Private
router.delete('/:id', auth, async (req, res) => { // GÜVENLİK: 'auth' middleware eklendi.
    try {
        const mekan = await Mekan.findById(req.params.id);
        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }

        // VERİ BÜTÜNLÜĞÜ: Mekanı silmeden önce, o mekana ait tüm yorumları da siliyoruz.
        await Yorum.deleteMany({ mekan: req.params.id });

        // Şimdi mekanı silebiliriz.
        await Mekan.findByIdAndDelete(req.params.id);

        res.json({ msg: 'Mekan ve ilgili yorumlar başarıyla silindi' });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Sunucu Hatası' });
    }
});

module.exports = router;