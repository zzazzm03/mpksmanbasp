# 🎓 MPK SMAN 1 Bangil — Setup Backend Aspirasi
## Panduan Lengkap Supabase (Gratis, ~10 menit)

---

## Arsitektur Sistem

```
[Siswa]                     [Publik]              [Admin MPK]
   │                           │                      │
   │ Submit aspirasi           │ Lihat counter        │ Login → baca isi
   ▼                           ▼                      ▼
[index.html] ──INSERT──► [Supabase DB]  ◄──SELECT──[admin_dashboard.html]
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
             tabel: aspirasi       tabel: aspirasi_counter
             (isi tersembunyi)     (angka saja, publik)
                    │
                    └── Trigger otomatis update counter
```

### Prinsip Privasi:
- **Siapa saja** bisa INSERT aspirasi (anonim, tanpa login)
- **Siapa saja** bisa READ tabel `aspirasi_counter` → hanya angka, tanpa isi
- **Hanya admin** (login Supabase Auth) bisa READ isi aspirasi
- Row Level Security (RLS) diterapkan di database level

---

## LANGKAH 1 — Buat Akun Supabase

1. Buka https://supabase.com → **Start your project** (gratis)
2. Daftar dengan GitHub atau email
3. Klik **New Project**:
   - Name: `mpk-aspirasi`
   - Database Password: buat password yang kuat (simpan!)
   - Region: **Southeast Asia (Singapore)**
4. Tunggu ~2 menit hingga project siap

---

## LANGKAH 2 — Jalankan Schema Database

1. Di dashboard Supabase, klik **SQL Editor** (ikon terminal di sidebar kiri)
2. Klik **New query**
3. Copy seluruh isi file `01_schema.sql`
4. Paste ke SQL Editor → klik **Run** (Ctrl+Enter)
5. Pastikan muncul pesan **"Success. No rows returned"**

---

## LANGKAH 3 — Ambil Konfigurasi API

1. Di Supabase, klik **Settings** → **API**
2. Catat dua nilai ini:
   - **Project URL** → contoh: `https://abcdefghijk.supabase.co`
   - **anon public key** → string panjang

---

## LANGKAH 4 — Pasang Config di HTML

Buka `index.html` dan `admin_dashboard.html`, cari baris ini dan ganti:

```javascript
var SUPABASE_URL      = 'GANTI_DENGAN_SUPABASE_URL';
var SUPABASE_ANON_KEY = 'GANTI_DENGAN_SUPABASE_ANON_KEY';
```

Jadi seperti (contoh):
```javascript
var SUPABASE_URL      = 'https://abcdefghijk.supabase.co';
var SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## LANGKAH 5 — Buat Akun Admin MPK

1. Di Supabase → **Authentication** → **Users**
2. Klik **Add user** → **Create new user**
3. Masukkan email dan password untuk anggota MPK yang boleh lihat aspirasi
4. Ulangi untuk setiap admin yang dibutuhkan

---

## LANGKAH 6 — Deploy (Upload ke Hosting)

### Opsi A: Netlify (Paling Mudah, Gratis)
1. Buka https://netlify.com → daftar gratis
2. Drag & drop folder ini ke halaman Netlify
3. Website langsung live dengan URL seperti `https://mpk-bangil.netlify.app`

### Opsi B: Vercel (Gratis)
1. Buka https://vercel.com
2. Import dari GitHub atau drag & drop

### Opsi C: GitHub Pages (Gratis)
1. Buat repo GitHub baru
2. Upload semua file
3. Settings → Pages → Deploy from branch

---

## File dalam Package Ini

| File | Fungsi |
|------|--------|
| `01_schema.sql` | Jalankan sekali di Supabase SQL Editor |
| `index.html` | Website publik (siswa submit aspirasi) |
| `admin_dashboard.html` | Dashboard admin MPK (lihat & kelola isi) |
| `README.md` | Panduan ini |

---

## Fitur Dashboard Admin

- **Login aman** dengan Supabase Auth (email + password)
- Lihat semua aspirasi beserta isi lengkap
- Filter berdasarkan status, kategori, atau pencarian teks
- Update status: Diterima → Diproses → Selesai
- Export semua data ke CSV

## Fitur Website Publik

- Submit aspirasi 100% anonim (tidak ada sesi, tidak ada cookie identitas)
- Counter realtime (update otomatis tanpa refresh)
- Kode tiket unik untuk tracking status
- Tidak ada halaman "lihat semua aspirasi" untuk publik

---

## Pertanyaan Umum

**Q: Apakah isi aspirasi bisa bocor ke publik?**
A: Tidak. Row Level Security di Supabase memastikan hanya user yang login (admin) yang bisa SELECT dari tabel `aspirasi`. Tabel `aspirasi_counter` hanya berisi angka.

**Q: Apakah gratis?**
A: Ya. Supabase free tier mencakup 500MB database dan 50.000 baris — lebih dari cukup untuk portal aspirasi sekolah.

**Q: Bagaimana cara reset password admin?**
A: Supabase Dashboard → Authentication → Users → klik user → Reset password.
