// models/Kullanici.js

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const KullaniciSchema = new Schema({
    kullaniciAdi: {
        type: String,
        required: true,
        unique: true // Her kullanıcı adı benzersiz olmalı
    },
    email: {
        type: String,
        required: true,
        unique: true // Her e-posta adresi benzersiz olmalı
    },
    sifre: {
        type: String,
        required: true
    },
    kayitTarihi: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Kullanici', KullaniciSchema);