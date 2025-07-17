// routes/mekanRoutes.js

const express = require('express');
const router = express.Router();
const Mekan = require('../models/Mekan'); // Daha önce oluşturduğumuz Mekan modelini içeri alıyoruz


// @route   GET api/mekanlar
// @desc    Tüm mekanları veya kategoriye göre filtrelenmiş mekanları getirir
// @access  Public
router.get('/', async (req, res) => {
    try {
        const { kategori } = req.query; // URL'den gelen ?kategori=... parametresini al

        const filtre = {}; // Boş bir filtre nesnesi oluştur
        if (kategori && kategori !== 'categoryAll') {
            // Eğer bir kategori geldiyse ve bu 'Tümü' değilse, filtreye ekle
            filtre.kategori = kategori;
        }

        // Veritabanında filtreye göre arama yap
        const mekanlar = await Mekan.find(filtre).sort({ eklenmeTarihi: -1 });
        
        res.json(mekanlar);
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
// @desc    ID ile tek bir mekanın detayını ve YORUMLARINI getirir
// @access  Public
router.get('/:id', async (req, res) => {
    try {
        // ID ile mekanı bul ve bu mekana ait tüm yorumları getir.
        // populate ile referanslı alanları gerçek verilerle dolduruyoruz.
        const mekan = await Mekan.findById(req.params.id);
        
        const yorumlar = await Yorum.find({ mekan: req.params.id })
            .populate({
                path: 'yazar', // Yorum modelindeki 'yazar' alanını doldur
                select: 'kullaniciAdi profilFotoUrl' // Yazardan sadece bu bilgileri al
            })
            .sort({ yorumTarihi: -1 });

        if (!mekan) {
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }

        // Mekan ve yorumları tek bir JSON nesnesinde birleştirip gönder
        res.json({
            mekan: mekan,
            yorumlar: yorumlar
        });

    } catch (err) {
        // ... mevcut catch bloğu aynı kalabilir ...
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