// models/Mekan.js (SANAL ALANLAR İLE GÜNCELLENMİŞ NİHAİ KOD)

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// 1. Konum için ayrı bir şema oluşturuyoruz. Bu, sanal alanları eklemeyi kolaylaştırır.
const KonumSchema = new Schema({
    type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
    },
    coordinates: {
        type: [Number], // [boylam, enlem]
        required: true
    }
}, { 
    _id: false, // Alt şemaların kendi ID'si olmasına gerek yok
    toJSON: { virtuals: true }, // Sanal alanların JSON'a eklenmesini sağla
    toObject: { virtuals: true }
});

// 2. SANAL ALANLARI TANIMLIYORUZ
// 'enlem' adında sanal bir alan oluştur. Bu alana erişildiğinde...
KonumSchema.virtual('enlem').get(function() {
    // ...coordinates dizisinin ikinci elemanını (enlemi) döndür.
    return this.coordinates[1];
});

// 'boylam' adında sanal bir alan oluştur. Bu alana erişildiğinde...
KonumSchema.virtual('boylam').get(function() {
    // ...coordinates dizisinin ilk elemanını (boylamı) döndür.
    return this.coordinates[0];
});


// 3. ANA MEKAN ŞEMAMIZI GÜNCELLİYORUZ
const MekanSchema = new Schema({
    isim: {
        tr: { type: String, required: true },
        en: { type: String, required: true }
    },
    aciklama: {
        tr: { type: String, required: true },
        en: { type: String, required: true }
    },
    kategori: String,
    fotograflar: [String],
    // Konum alanı olarak yukarıda oluşturduğumuz KonumSchema'yı kullanıyoruz.
    konum: KonumSchema, 
    ortalamaPuan: {
        type: Number,
        default: 0
    },
    eklenmeTarihi: {
        type: Date,
        default: Date.now
    }
}, {
    // Ana şemada da sanal alanları aktif etmeyi unutmuyoruz.
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});




// Coğrafi sorgular için indeksi ana şemaya ekliyoruz
MekanSchema.index({ 'konum': '2dsphere' });

module.exports = mongoose.model('Mekan', MekanSchema);

// İndeks tanımın aynı kalacak, ona dokunma

