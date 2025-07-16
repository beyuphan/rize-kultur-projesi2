// routes/authRoutes.js

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const auth = require('../middleware/auth'); // Auth middleware'ini dahil ediyoruz
const Kullanici = require('../models/Kullanici'); // Kullanici modelimizi dahil ediyoruz

// @route   POST api/auth/kayit
// @desc    Yeni bir kullanıcı kaydı oluşturur
// @access  Public
router.post('/kayit', async (req, res) => {
    const { kullaniciAdi, email, sifre } = req.body;

    try {
        // 1. Kullanıcı zaten var mı diye kontrol et (e-posta ile)
        let kullanici = await Kullanici.findOne({ email });
        if (kullanici) {
            return res.status(400).json({ msg: 'Bu e-posta adresi ile bir kullanıcı zaten mevcut' });
        }

        // 2. Yeni kullanıcı nesnesini oluştur
        kullanici = new Kullanici({
            kullaniciAdi,
            email,
            sifre
        });

        // 3. Şifreyi hash'le
        const salt = await bcrypt.genSalt(10);
        kullanici.sifre = await bcrypt.hash(sifre, salt);

        // 4. Kullanıcıyı veritabanına kaydet
        await kullanici.save();

        // 5. Kullanıcıya bir JWT (JSON Web Token) vererek oturumunu başlat
        const payload = {
            kullanici: {
                id: kullanici.id
            }
        };

        jwt.sign(
            payload,
            process.env.JWT_SECRET, // .env dosyamıza ekleyeceğimiz gizli bir anahtar
            { expiresIn: 360000 }, // Token'ın geçerlilik süresi
            (err, token) => {
                if (err) throw err;
                res.status(201).json({ token }); // Cevap olarak token'ı dön
            }
        );

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});



// @route   POST api/auth/giris
// @desc    Kullanıcı girişi yapar ve token döndürür
// @access  Public
router.post('/giris', async (req, res) => {
    const { email, sifre } = req.body;

    try {
        // 1. Kullanıcı e-postası veritabanında var mı diye kontrol et
        let kullanici = await Kullanici.findOne({ email });
        if (!kullanici) {
            return res.status(400).json({ msg: 'Geçersiz kullanıcı bilgileri' });
        }

        // 2. Girilen şifre ile veritabanındaki hash'lenmiş şifreyi karşılaştır
        const isMatch = await bcrypt.compare(sifre, kullanici.sifre);
        if (!isMatch) {
            return res.status(400).json({ msg: 'Geçersiz kullanıcı bilgileri' });
        }
        // Not: Güvenlik için "şifre yanlış" veya "kullanıcı bulunamadı" demek yerine
        // her iki durumda da aynı genel hata mesajını dönüyoruz.

        // 3. Şifre doğruysa, kullanıcıya yeni bir JWT vererek oturumunu başlat
        const payload = {
            kullanici: {
                id: kullanici.id
            }
        };

        jwt.sign(
            payload,
            process.env.JWT_SECRET,
            { expiresIn: 360000 },
            (err, token) => {
                if (err) throw err;
                res.json({ token }); // Cevap olarak token'ı dön
            }
        );

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});

// @route   GET api/auth/me
// @desc    Giriş yapmış kullanıcının kendi bilgilerini getirir
// @access  Private
router.get('/me', auth, async (req, res) => {
    try {
        // auth middleware'i, token'dan aldığı kullanıcı id'sini req.kullanici.id'ye koyar.
        // Şifre hariç diğer tüm bilgileri seçerek kullanıcıyı buluyoruz.
        const kullanici = await Kullanici.findById(req.kullanici.id).select('-sifre');
        if (!kullanici) {
            return res.status(404).json({ msg: 'Kullanıcı bulunamadı' });
        }
        res.json(kullanici);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});


// @route   PUT api/auth/favorites/:mekanId
// @desc    Bir mekanı kullanıcının favorilerine ekler/çıkarır
// @access  Private
router.put('/favorites/:mekanId', auth, async (req, res) => {
    try {
        const kullanici = await Kullanici.findById(req.kullanici.id);
        const mekanId = req.params.mekanId;

        // Kullanıcının favorilerinde bu mekan zaten var mı diye kontrol et
        const favoriIndex = kullanici.favoriMekanlar.indexOf(mekanId);

        if (favoriIndex > -1) {
            // Eğer varsa, favorilerden çıkar
            kullanici.favoriMekanlar.splice(favoriIndex, 1);
        } else {
            // Eğer yoksa, favorilere ekle
            kullanici.favoriMekanlar.push(mekanId);
        }

        await kullanici.save();
        res.json(kullanici.favoriMekanlar);

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});




// @route   PUT api/auth/update
// @desc    Giriş yapmış kullanıcının profilini günceller
// @access  Private
router.put('/update', auth, async (req, res) => {
    // 1. Güncellenecek bilgileri isteğin body'sinden al
    const { kullaniciAdi, email } = req.body;

    // 2. Güncellenecek alanları bir nesnede topla
    const profilAlanlari = {};
    if (kullaniciAdi) profilAlanlari.kullaniciAdi = kullaniciAdi;
    if (email) profilAlanlari.email = email;

    try {
        // 3. auth middleware'inden gelen ID ile kullanıcıyı bul ve güncelle
        // { new: true } -> güncellenmiş halini geri döndürmesini sağlar
        // .select('-sifre') -> güvenlik için şifreyi cevaptan çıkarır
        const kullanici = await Kullanici.findByIdAndUpdate(
            req.kullanici.id,
            { $set: profilAlanlari },
            { new: true }
        ).select('-sifre');

        if (!kullanici) {
            return res.status(404).json({ msg: 'Kullanıcı bulunamadı' });
        }

        // 4. Başarılı olursa güncellenmiş kullanıcı bilgisini geri dön
        res.json(kullanici);

    } catch (err) {
        // Bu email'in veya kullanıcı adının başka bir kullanıcı tarafından
        // alınıp alınmadığını kontrol edip daha spesifik bir hata dönebiliriz.
        if (err.code === 11000) {
             return res.status(400).json({ msg: 'Bu kullanıcı adı veya e-posta zaten kullanımda.' });
        }
        console.error(err.message);
        res.status(500).send('Sunucu Hatası');
    }
});


module.exports = router;