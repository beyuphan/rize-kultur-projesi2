// middleware/auth.js

const jwt = require('jsonwebtoken');

module.exports = function(req, res, next) {
    // 1. İstek başlığından (header) token'ı al
    const token = req.header('x-auth-token');

    // 2. Token yoksa, yetkisi olmadığını söyle
    if (!token) {
        return res.status(401).json({ msg: 'Yetkiniz yok, token bulunamadı' });
    }

    // 3. Token varsa, geçerli mi diye kontrol et
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // Token geçerliyse, içindeki kullanıcı bilgisini isteğe ekle
        req.kullanici = decoded.kullanici;
        next(); // Her şey yolunda, isteğin devam etmesine izin ver
    } catch (err) {
        res.status(401).json({ msg: 'Token geçersiz' });
    }
};