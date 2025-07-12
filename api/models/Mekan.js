// models/Mekan.js

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const MekanSchema = new Schema({
    isim: {
        type: String,
        required: true // Bu alanın zorunlu olduğunu belirtir
    },
    aciklama: {
        type: String,
        required: true
    },
    kategori: {
        type: String,
        required: true
    },
    fotograflar: {
        type: [String], // Bir String dizisi (birden fazla fotoğraf URL'si olabilir)
        required: false // Zorunlu değil
    },
    konum: {
        enlem: { type: Number, required: true },
        boylam: { type: Number, required: true }
    },
    ortalamaPuan: {
        type: Number,
        default: 0 // Varsayılan değeri 0 olacak
    },
    eklenmeTarihi: {
        type: Date,
        default: Date.now // Otomatik olarak eklenme tarihini atar
    }
});

module.exports = mongoose.model('Mekan', MekanSchema);