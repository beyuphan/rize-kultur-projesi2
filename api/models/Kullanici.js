const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const KullaniciSchema = new Schema({
    kullaniciAdi: {
        type: String,
        required: true,
        unique: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    sifre: {
        type: String,
        required: true
    },
    // YENİ EKLENDİ: Kullanıcının favori mekanlarının ID'lerini tutacak dizi.
    // 'ref' ile bu ID'lerin 'Mekan' koleksiyonuna ait olduğunu belirtiyoruz.
    favoriMekanlar: [{
        type: Schema.Types.ObjectId,
        ref: 'Mekan'
    }],
    kayitTarihi: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Kullanici', KullaniciSchema);