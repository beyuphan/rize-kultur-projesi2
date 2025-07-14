const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { check, validationResult } = require("express-validator");
const Kullanici = require("../models/Kullanici");

router.post(
  "/kayit",
  [
    check("kullaniciAdi", "Kullanıcı adı gereklidir").not().isEmpty(),
    check("email", "Lütfen geçerli bir e-posta adresi girin").isEmail(),
    check(
      "sifre",
      "Lütfen 6 veya daha fazla karakterli bir şifre girin"
    ).isLength({ min: 6 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { kullaniciAdi, email, sifre } = req.body;

    try {
      let kullanici = await Kullanici.findOne({ email });
      if (kullanici) {
        return res
          .status(400)
          .json({ msg: "Bu e-posta adresi ile zaten bir kullanıcı var" });
      }

      kullanici = new Kullanici({
        kullaniciAdi,
        email,
        sifre,
      });

      const salt = await bcrypt.genSalt(10);
      kullanici.sifre = await bcrypt.hash(sifre, salt);

      await kullanici.save();

      const payload = {
        kullanici: {
          id: kullanici.id,
        },
      };

      jwt.sign(
        payload,
        process.env.JWT_SECRET,
        { expiresIn: 360000 },
        (err, token) => {
          if (err) throw err;
          res.json({ token });
        }
      );
    } catch (err) {
      console.error(err.message);
      res.status(500).send("Sunucu Hatası");
    }
  }
);

router.post(
  "/giris",
  [
    check("email", "Lütfen geçerli bir e-posta adresi girin").isEmail(),
    check("sifre", "Şifre gereklidir").exists(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, sifre } = req.body;

    try {
      let kullanici = await Kullanici.findOne({ email });
      if (!kullanici) {
        return res.status(400).json({ msg: "Geçersiz kullanıcı bilgileri" });
      }

      const isMatch = await bcrypt.compare(sifre, kullanici.sifre);
      if (!isMatch) {
        return res.status(400).json({ msg: "Geçersiz kullanıcı bilgileri" });
      }

      const payload = {
        kullanici: {
          id: kullanici.id,
        },
      };

      jwt.sign(
        payload,
        process.env.JWT_SECRET,
        { expiresIn: 360000 },
        (err, token) => {
          if (err) throw err;
          res.json({ token });
        }
      );
    } catch (err) {
      console.error(err.message);
      res.status(500).send("Sunucu Hatası");
    }
  }
);

module.exports = router;
