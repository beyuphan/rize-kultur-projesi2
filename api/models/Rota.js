// api/models/Rota.js

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Mekanlardaki gibi çok dilli metin için bir alt şema
const CokDilliMetinSchema = new Schema({
    tr: { type: String, required: true },
    en: { type: String, required: true }
}, { _id: false });

// Rotanın her bir durağının yapısını tanımlayan alt şema
const DurakSchema = new Schema({
    mekanId: {
        type: Schema.Types.ObjectId,
        ref: 'Mekan', // Bu ID'nin 'Mekan' koleksiyonuna ait olduğunu belirtir
        required: true
    },
    sonrakiDuragaMesafe: { type: String }, // Örn: "15 km"
    sonrakiDuragaSure: { type: String }   // Örn: "25 dk"
}, { _id: false });

// Bilgiler sekmesindeki her bir maddenin yapısını tanımlayan alt şema
const BilgiItemSchema = new Schema({
    iconKey: { type: String, required: true }, // Flutter'da hangi ikonu göstereceğimizi belirler
    baslik: CokDilliMetinSchema,
    aciklama: CokDilliMetinSchema,
}, { _id: false });


// Ana Rota Şeması
const RotaSchema = new Schema({
    ad: CokDilliMetinSchema,
    aciklama: CokDilliMetinSchema,
    tahminiSure: CokDilliMetinSchema,
    zorlukSeviyesi: CokDilliMetinSchema,
    
    kapakFotografiUrl: { type: String, required: true },
    
    // Rota duraklarını ve aralarındaki bilgiyi tutan dizi
    duraklar: [DurakSchema],

    // "Bilgiler" sekmesi için dinamik veri
    hazirlikIpuclari: [BilgiItemSchema],
    guvenlikIpuclari: [BilgiItemSchema],
});

module.exports = mongoose.model('Rota', RotaSchema);
