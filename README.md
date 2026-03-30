# 📚 E-Learning Blog Platform

Platform blog modern yang dibangun menggunakan **Eks-Cent Ruby Framework**. Dirancang khusus untuk materi e-learning dengan estetika *glass-morphism* yang elegan, performa tinggi, dan fitur manajemen konten yang lengkap.

![Aesthetic](https://img.shields.io/badge/Aesthetic-Glass--morphism-blue?style=for-the-badge)
![Ruby](https://img.shields.io/badge/Ruby-v3.0+-red?style=for-the-badge&logo=ruby)
![MySQL](https://img.shields.io/badge/Database-MySQL-blue?style=for-the-badge&logo=mysql)
![Deployment](https://img.shields.io/badge/Deploy-Railway-green?style=for-the-badge)

## ✨ Fitur Unggulan

- 🎨 **Desain Glass-morphism**: Antarmuka modern yang transparan dan responsif.
- ✍️ **Markdown Support**: Tulis materi belajar dengan kemudahan GFM (GitHub Flavored Markdown).
- 🖼️ **Cloudinary Image Upload**: Dukungan upload gambar otomatis ke Cloudinary.
- 🏷️ **Manajemen Kategori**: Kelompokkan materi belajar Anda dengan mudah.
- 💬 **Moderasi Komentar**: Sistem komentar yang aman dengan persetujuan admin.
- 🔍 **Pencarian Cepat**: Temukan materi dengan kata kunci secara *full-text search*.
- 📈 **SEO Ready**: Tag kanonikal, OpenGraph, sitemap, dan robots.txt dinamis.
- 🛡️ **Security Focused**: Proteksi CSRF, Signed Sessions, dan BCrypt hashing.

## 🚀 Persiapan Lokal

### 1. Prasyarat
- Ruby v3.0 atau lebih baru.
- MySQL Server.
- Cloudinary Account (untuk upload gambar).

### 2. Instalasi
1. Salin repositori ini:
   ```bash
   git clone https://github.com/IshikawaUta/blog-e-learning.git
   cd blog-e-learning
   ```
2. Instal dependensi:
   ```bash
   bundle install
   ```
3. Konfigurasi Environment:
   Salin file `.env.example` menjadi `.env` dan lengkapi datanya:
   ```bash
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=your_password
   DB_NAME=elearning_db
   CLOUDINARY_URL=cloudinary://your_api_key:your_api_secret@your_cloud_name
   ```

### 3. Jalankan Server
Gunakan perintah `ekscentup` untuk memulai:
```bash
ekscentup config.eks
```
Buka `http://localhost:3000` di browser Anda.

## 🚢 Deployment ke Railway

Proyek ini sudah dilengkapi dengan **Procfile** dan **Gemfile** untuk deployment instan di Railway:

1. Hubungkan GitHub Anda ke Railway.
2. Tambahkan layanan **MySQL** di dalam proyek.
3. Atur variabel environment (`APP_ENV=production`, `CLOUDINARY_URL`, dsb) di tab **Variables**.
4. Blog Anda akan online secara otomatis!

## 📄 Lisensi

Proyek ini dilisensikan di bawah **MIT License**. Lihat file [LICENSE](LICENSE) untuk detail lebih lanjut.