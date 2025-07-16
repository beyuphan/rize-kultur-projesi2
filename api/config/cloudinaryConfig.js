// config/cloudinaryConfig.js (YENİ DOSYA)
const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');

// Cloudinary API bilgileriyle konfigürasyon
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Multer için depolama motorunu ayarla
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'rize-kultur-projesi/profil-fotograflari', // Cloudinary'de resimlerin yükleneceği klasör
    allowed_formats: ['jpg', 'png', 'jpeg'],
    // Yüklenen her dosyaya benzersiz bir isim ver
    public_id: (req, file) => 'profil-' + req.kullanici.id + '-' + Date.now(),
  },
});

// Multer'ı bu depolama motoruyla yapılandır
const upload = multer({ storage: storage });

module.exports = upload;