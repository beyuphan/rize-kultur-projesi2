// models/Yorum.js

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const YorumSchema = new Schema({
    icerik: {
        type: String,
        required: true
    },
    puan: {
        type: Number,
        min: 1, // En az 1
        max: 5, // En fazla 5
        required: true
    },
    fotografUrl: {
        type: String, // Yoruma eklenen fotoğrafın URL'si
        required: false
    },
    yazar: {
        type: Schema.Types.ObjectId,
        ref: 'Kullanici', // Kullanici modeline bir referans
        required: true
    },
    mekan: {
        type: Schema.Types.ObjectId,
        ref: 'Mekan', // Mekan modeline bir referans
        required: true
    },
    yorumTarihi: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Yorum', YorumSchema);