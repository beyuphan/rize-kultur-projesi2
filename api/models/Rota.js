// api/models/Rota.js

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Mekanlardaki gibi çok dilli metin için bir alt şema
const CokDilliMetinSchema = new Schema({
    tr: { type: String, required: true },
    en: { type: String, required: true }
}, { _id: false });

const RotaSchema = new Schema({
    // DÜZELTME: Artık 'adKey' yerine çok dilli bir 'ad' objesi var
    ad: CokDilliMetinSchema,
    aciklama: CokDilliMetinSchema,
    tahminiSure: CokDilliMetinSchema,
    zorlukSeviyesi: CokDilliMetinSchema,
    
    kapakFotografiUrl: { type: String, required: true },
    
    mekanIdleri: [{
        type: Schema.Types.ObjectId,
        ref: 'Mekan',
        required: true
    }]
});

module.exports = mongoose.model('Rota', RotaSchema);