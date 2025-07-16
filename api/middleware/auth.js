// middleware/auth.js

const jwt = require('jsonwebtoken');

module.exports = function (req, res, next) {
  // 1. Header'dan 'Authorization' başlığını al. Standart budur.
  const authHeader = req.header('Authorization');

  // 2. Authorization başlığı yok mu diye kontrol et.
  if (!authHeader) {
    return res.status(401).json({ msg: 'Token bulunamadı, yetkilendirme reddedildi' });
  }

  // 3. Token'ın "Bearer " kısmını ayıkla.
  // Gelen başlık "Bearer eyJhbGciOi..." şeklinde olacaktır.
  const token = authHeader.split(' ')[1];

  // "Bearer " ön eki veya token'ın kendisi yoksa hata ver.
  if (!token) {
    return res.status(401).json({ msg: 'Token formatı hatalı, yetkilendirme reddedildi' });
  }

  // 4. Ayıklanmış token'ı doğrula.
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Decode edilen kullanıcı bilgisini isteğin (request) içine koy.
    req.kullanici = decoded.kullanici;
    next(); // Her şey yolundaysa, bir sonraki adıma (asıl rota fonksiyonuna) geç.
  } catch (err) {
    res.status(401).json({ msg: 'Token geçerli değil' });
  }
};
