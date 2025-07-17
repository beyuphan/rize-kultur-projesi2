// models/Yorum.js (GÜNCELLENMİŞ HALİ)

const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const YorumSchema = new Schema({
    icerik: {
        type: String,
        trim: true // Başındaki ve sonundaki boşlukları temizler
    },
    puan: {
        type: Number,
        min: 1,
        max: 5
    },
    // ... yazar, mekan, yorumTarihi alanları aynı ...
    yazar: {
        type: Schema.Types.ObjectId,
        ref: 'Kullanici',
        required: true
    },
    mekan: {
        type: Schema.Types.ObjectId,
        ref: 'Mekan',
        required: true
    },
    yorumTarihi: {
        type: Date,
        default: Date.now
    }
}, {
    // Sanal alanların JSON'a dahil edilmesini sağlar
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Yorum kaydedilmeden önce kontrol et: içerik veya puan'dan en az biri olmalı.
YorumSchema.pre('save', function(next) {
    if (!this.icerik && !this.puan) {
        next(new Error('Yorum içeriği veya puan alanlarından en az biri dolu olmalıdır.'));
    } else {
        next();
    }
});


// Yorum eklendikten veya silindikten sonra mekanın ortalama puanını hesaplamak için statik bir metod
YorumSchema.statics.hesaplaOrtalamaPuan = async function(mekanId) {
    const obj = await this.aggregate([
        {
            $match: { mekan: mekanId, puan: { $ne: null } } // Sadece puanı olan yorumları eşleştir
        },
        {
            $group: {
                _id: '$mekan',
                ortalamaPuan: { $avg: '$puan' }
            }
        }
    ]);

    try {
        if (obj.length > 0) {
            // Eğer sonuç varsa, Mekan modelini bul ve ortalamaPuan'ı güncelle
            await this.model('Mekan').findByIdAndUpdate(mekanId, {
                ortalamaPuan: obj[0].ortalamaPuan.toFixed(1) // Virgülden sonra 1 basamak
            });
        } else {
            // Eğer hiç puanlı yorum kalmadıysa, ortalama puanı 0 yap
            await this.model('Mekan').findByIdAndUpdate(mekanId, {
                ortalamaPuan: 0
            });
        }
    } catch (err) {
        console.error(err);
    }
};

// Yorum kaydedildikten sonra ortalama puanı tetikle
YorumSchema.post('save', function() {
    this.constructor.hesaplaOrtalamaPuan(this.mekan);
});

// Yorum silindikten sonra ortalama puanı tetikle (findByIdAndDelete için)
YorumSchema.post('findOneAndDelete', async function(doc) {
    if (doc) {
        await doc.constructor.hesaplaOrtalamaPuan(doc.mekan);
    }
});


module.exports = mongoose.model('Yorum', YorumSchema);