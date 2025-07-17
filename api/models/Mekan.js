// models/Mekan.js

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const MekanSchema = new Schema({
    // DÜZENLENDİ: Artık birer nesne
    isim: {
        tr: { type: String, required: true },
        en: { type: String, required: true }
    },
    // DÜZENLENDİ: Artık birer nesne
    aciklama: {
        tr: { type: String, required: true },
        en: { type: String, required: true }
    },
    kategori: {
        type: String,
        required: true
    },
    fotograflar: {
        type: [String],
        required: false
    },
    konum: {
        enlem: { type: Number, required: true },
        boylam: { type: Number, required: true }
    },
    ortalamaPuan: {
        type: Number,
        default: 0
    },
    eklenmeTarihi: {
        type: Date,
        default: Date.now
    }
});

// İndeks tanımın aynı kalacak, ona dokunma
MekanSchema.index({ mekan: 1 }); // Bu satır YorumSchema'daydı, burada değil. Karıştırmayalım.

module.exports = mongoose.model('Mekan', MekanSchema);