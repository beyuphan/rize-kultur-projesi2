// routes/mekanRoutes.js (GÜVENLİ VE TUTARLI HALİ)

const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth'); // Güvenlik için middleware'i dahil ediyoruz
const Mekan = require('../models/Mekan');
const Yorum = require('../models/Yorum');

// @route   GET api/mekanlar
// @desc    Tüm mekanları veya kategoriye göre filtrelenmiş mekanları getirir
// @access  Public
r
// @route   GET api/mekanlar
// @desc    Tüm mekanları getirir (filtreleme, arama, sıralama ve sayfalama ile)
// @access  Public
router.get('/', async (req, res) => {
    try {
        // 1. Flutter'dan gelebilecek tüm parametreleri alıyoruz.
        // Parametre gelmezse kullanılacak varsayılan değerleri de atıyoruz.
        const { kategori, sortBy, arama, limit = 20, page = 1 } = req.query;

        // 2. MongoDB sorgusunu oluşturmak için boş bir obje hazırlıyoruz.
        let sorgu = {};

        // 3. Parametrelere göre sorgu objesini dinamik olarak dolduruyoruz.
        // Eğer bir kategori filtresi geldiyse, sorguya ekle.
        if (kategori && kategori !== 'categoryAll') {
            sorgu.kategori = kategori;
        }

        // Eğer bir arama kelimesi geldiyse, sorguya ekle.
        if (arama) {
            // 'i' parametresi büyük/küçük harf duyarsız arama (case-insensitive) sağlar.
            // Sadece mekanların Türkçe isminde arama yapıyoruz, istersen 'isim.en' de eklenebilir.
            sorgu['isim.tr'] = new RegExp(arama, 'i');
        }

        // 4. Sıralama seçeneklerini belirliyoruz.
        let siralamaSecenekleri = {};
        if (sortBy === 'puan') {
            siralamaSecenekleri = { ortalamaPuan: -1 }; // -1: Büyükten küçüğe sırala
        } else if (sortBy === 'yeni') {
            siralamaSecenekleri = { eklenmeTarihi: -1 };
        } else {
            siralamaSecenekleri = { eklenmeTarihi: -1 }; // Varsayılan olarak en yeniye göre sırala
        }
        
        // 5. Sayfalama (Pagination) için ayarları yapıyoruz.
        const sayfaLimiti = parseInt(limit);
        const atlanacakKayitSayisi = (parseInt(page) - 1) * sayfaLimiti;

        // 6. Son sorguyu oluşturup veritabanından mekanları çekiyoruz.
        const mekanlar = await Mekan.find(sorgu)
            .sort(siralamaSecenekleri) // Sırala
            .skip(atlanacakKayitSayisi) // Belirli sayıda kaydı atla (ör: 2. sayfa için ilk 20'yi atla)
            .limit(sayfaLimiti);      // Sadece limit kadarını al (ör: 20 tane)
        
        // (Opsiyonel ama çok faydalı) Toplam sonuç sayısını da bulup gönderiyoruz.
        const toplamMekanSayisi = await Mekan.countDocuments(sorgu);

        // 7. Flutter'a hem mekanları hem de sayfa bilgilerini gönderiyoruz.
        res.json({
            mekanlar,
            toplamSayfa: Math.ceil(toplamMekanSayisi / sayfaLimiti),
            mevcutSayfa: parseInt(page),
        });

    } catch (err) {
        console.error(err.message);
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


// @route   GET api/mekanlar/yakinimdakiler
// @desc    Verilen koordinatlara en yakın mekanları getirir (DETAYLI LOG'LAMA İLE)
// @access  Public
router.get('/yakinimdakiler', async (req, res) => {
    console.log("\n--- YAKINIMDAKİLER ROTASI TETİKLENDİ ---");
    try {
        const { enlem, boylam, mesafe = 500000 } = req.query;
        console.log(`[1] Gelen Parametreler -> Enlem: ${enlem}, Boylam: ${boylam}`);

        if (!enlem || !boylam) {
            console.log("[HATA] Enlem veya boylam parametresi eksik.");
            return res.status(400).json({ msg: 'Enlem ve boylam gereklidir.' });
        }

        const lat = parseFloat(enlem);
        const lon = parseFloat(boylam);
        console.log(`[2] Parse Edilmiş Değerler -> Enlem: ${lat}, Boylam: ${lon}`);

        const sorgu = {
            konum: {
                $nearSphere: {
                    $geometry: {
                        type: "Point",
                        coordinates: [lon, lat]
                    },
                    $maxDistance: parseInt(mesafe)
                }
            }
        };
        console.log("[3] MongoDB'ye gönderilecek sorgu oluşturuldu.");

        const mekanlar = await Mekan.find(sorgu).select('isim kategori fotograflar ortalamaPuan konum');
        console.log(`[4] Sorgu başarılı. ${mekanlar.length} adet mekan bulundu.`);

        res.json(mekanlar);

    } catch (err) {
        console.error("\n!!! YAKINIMDAKİLER ROTASINDA KRİTİK HATA !!!");
        console.error(err); // Hatanın tamamını ve sebebini terminale yazdır
        
        res.status(500).json({
            msg: 'Sunucu tarafında bir hata oluştu. Lütfen terminal loglarını kontrol edin.',
            error: err.message,
        });
    }
});

// @route   GET api/mekanlar/:id
// @desc    ID ile tek bir mekanın detayını ve yorumlarını getirir
// @access  Public
router.get('/:id', async (req, res) => {
    console.log(`\n--- MEKAN DETAYI İSTEĞİ GELDİ: ID = ${req.params.id} ---`);
    try {
        console.log("[1] Mekan bilgisi aranıyor...");
        const mekan = await Mekan.findById(req.params.id)

        if (!mekan) {
            console.log("[HATA] Mekan bulunamadı.");
            return res.status(404).json({ msg: 'Mekan bulunamadı' });
        }
        console.log("[2] Mekan bulundu:", mekan.isim.tr);

        console.log("[3] Bu mekana ait yorumlar aranıyor ve populate ediliyor...");
        const yorumlar = await Yorum.find({ mekan: req.params.id })
            .populate('yazar', 'kullaniciAdi profilFotoUrl')
            .sort({ yorumTarihi: -1 });
        console.log(`[4] Yorumlar başarıyla bulundu ve populate edildi. Adet: ${yorumlar.length}`);

        res.json({
            mekan: mekan,
            yorumlar: yorumlar
        });
        console.log("--- MEKAN DETAYI İSTEĞİ BAŞARIYLA BİTTİ ---");

    } catch (err) {
        console.error("\n!!! MEKAN DETAYI ROTASINDA KRİTİK HATA !!!");
        console.error(err);
        res.status(500).json({ msg: 'Sunucu Hatası', error: err.message });
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



// @route   POST api/mekanlar/by-ids
// @desc    Verilen ID dizisindeki mekanların detaylarını getirir
// @access  Public
router.post('/by-ids', async (req, res) => {
    try {
        const ids = req.body.ids;
        if (!ids || !Array.isArray(ids)) {
            return res.status(400).json({ msg: 'ID dizisi gereklidir.' });
        }

        const mekanlar = await Mekan.find({ '_id': { $in: ids } })
            .select('isim kategori fotograflar ortalamaPuan');

        res.json(mekanlar);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Sunucu Hatası' });
    }
});



module.exports = router;