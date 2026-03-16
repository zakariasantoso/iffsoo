# CLAUDE.md — IFFSOO Gold Herbal Landing Pages

This file helps AI assistants understand the codebase, business context, and development conventions for the IFFSOO Gold Herbal project.

---

## Project Overview

**IFFSOO Gold Herbal Original** adalah produk herbal stamina/energi yang dijual langsung via WhatsApp. Project ini berisi multiple landing page (LP) variations yang dipakai untuk A/B testing iklan berbayar (Meta Ads / Instagram).

- **Target audience:** Warm audience — orang yang sudah lihat iklan atau konten Instagram IFFSOO
- **Conversion goal:** Klik tombol WhatsApp → chat langsung dengan admin
- **No backend, no checkout page** — semua closing dilakukan manual via WA

---

## Repository Structure

```
iffsoo/
├── lp-hard-sell-direct.html   # Variant: hard sell, penawaran langsung, bonus kurma
├── lp-video-first.html        # Variant: video/reel sebagai anchor utama
├── lp-testimoni-grid.html     # Variant: grid testimoni pelanggan
├── lp-quiz-quick.html         # Variant: quiz interaktif dengan urgency popup
├── assets/                    # Foto produk, lifestyle, testimoni
│   └── Photos-3-001/          # Koleksi foto tambahan
├── README.txt                 # Setup instructions (WA number, Pixel ID)
├── .gitignore                 # Excludes video files (MOV, MP4, AVI, etc.)
└── CLAUDE.md                  # This file
```

**Stack:** Pure HTML5 + inline CSS + inline JavaScript. Tidak ada build system, framework, atau package manager.

---

## Key Configuration (Hardcoded per File)

Setiap LP file memiliki konstanta konfigurasi di bagian `<script>` yang wajib ada:

```javascript
const WA_NUMBER = '6285182096568';           // Nomor WhatsApp admin (tanpa +)
const WA_TEXT = encodeURIComponent('...');   // Pre-filled pesan WA (unik per LP)
const WA_LINK = `https://wa.me/${WA_NUMBER}?text=${WA_TEXT}`;
```

**Facebook Pixel ID:** `948013317787488`
Diinisiasi di bagian `<head>` setiap LP:

```javascript
fbq('init', '948013317787488');
fbq('track', 'PageView');
```

> Jangan ubah atau hapus Pixel ID dan WA_NUMBER tanpa konfirmasi eksplisit dari user.

---

## Conversion Rules — WAJIB Dipatuhi AI

Ini adalah aturan non-negotiable saat mengedit atau membuat LP baru:

1. **Selalu ada minimal 3 WA CTA button** per halaman: atas, tengah, dan sticky/bottom
2. **Facebook Pixel events wajib di semua CTA click handler:**
   ```javascript
   fbq('track', 'InitiateCheckout');
   fbq('track', 'Lead');
   fbq('trackCustom', 'ClickWhatsApp', { label: 'nama-placement' });
   ```
3. **Sticky bottom button** harus selalu visible saat scroll (position: fixed, z-index tinggi)
4. **WA button color:** `#25D366` (WhatsApp hijau) atau gold/dark sesuai tema — jangan pakai warna lain
5. **Jangan hapus elemen urgency** (countdown timer, stok terbatas, badge "Hari Ini") tanpa alasan kuat
6. **Semua link keluar harus ke WA** — jangan tambah link ke website lain atau checkout eksternal

---

## Copywriting Tone & Business Context

IFFSOO menjual ke audiens Indonesia, umumnya pria dewasa yang mencari stamina/energi. Tone yang digunakan:

- **Bahasa:** Indonesia, boleh campur sedikit Inggris untuk feel premium
- **Tone:** Direct, percaya diri, sedikit maskulin — bukan hard pushy tapi genuine
- **Hindari:** Klaim medis berlebihan, janji penyembuhan penyakit, bahasa klinis
- **Gunakan:** Testimonial nyata, benefit konkret ("terasa lebih bertenaga"), social proof
- **Harga display:** Rp130.000 (coret Rp150.000) + bonus kurma — jangan ubah pricing tanpa konfirmasi

**USP produk:** Herbal original, aman, ada bonus kurma, bisa order langsung via WA tanpa ribet.

---

## Creating a New Landing Page

Saat diminta membuat LP baru, ikuti checklist ini:

### Checklist LP Baru

- [ ] Copy struktur dari LP yang paling relevan sebagai base
- [ ] Update `<title>` dan `<meta name="description">` sesuai angle LP baru
- [ ] Ganti `WA_TEXT` dengan pesan yang relevan untuk angle tersebut
- [ ] Pastikan `WA_NUMBER` dan Facebook Pixel ID tetap sama
- [ ] Ada 3+ CTA button (atas, tengah, sticky bottom)
- [ ] Semua CTA button memiliki FB Pixel event tracking
- [ ] Ada elemen urgency (countdown, stok terbatas, dll)
- [ ] Ada social proof (testimoni, jumlah pembeli, bintang rating)
- [ ] Responsive di mobile (max-width: 700px breakpoint)
- [ ] Test mental: apakah halaman bisa dimengerti dalam 5 detik pertama?

### File Naming Convention

```
lp-[angle]-[sub-angle].html
```

Contoh: `lp-video-testimoni.html`, `lp-quiz-stamina.html`, `lp-hard-sell-murah.html`

### LP Structure Template

```html
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>IFFSOO Gold Herbal — [Angle]</title>
  <meta name="description" content="[Deskripsi singkat angle]">
  <!-- Facebook Pixel -->
  <script>
    !function(f,b,e,v,n,t,s){...}(window, document,'script',
    'https://connect.facebook.net/en_US/fbevents.js');
    fbq('init', '948013317787488');
    fbq('track', 'PageView');
  </script>
  <noscript><img height="1" width="1" style="display:none"
    src="https://www.facebook.com/tr?id=948013317787488&ev=PageView&noscript=1"/></noscript>
  <style>
    /* CSS Variables */
    :root {
      --green: #25D366;
      --gold: #ffd166;
      --red: #c1121f;
      --dark: #111;
      --bg: #f7f7f9; /* atau #0d0d0d untuk dark theme */
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    /* ... styles ... */
  </style>
</head>
<body>
  <!-- TOP CTA -->
  <!-- CONTENT SECTION -->
  <!-- MIDDLE CTA -->
  <!-- SOCIAL PROOF -->
  <!-- STICKY BOTTOM CTA -->
  <script>
    const WA_NUMBER = '6285182096568';
    const WA_TEXT = encodeURIComponent('[Pre-filled message]');
    const WA_LINK = `https://wa.me/${WA_NUMBER}?text=${WA_TEXT}`;

    document.querySelectorAll('.wa-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        fbq('track', 'InitiateCheckout');
        fbq('track', 'Lead');
        fbq('trackCustom', 'ClickWhatsApp', { label: btn.id || 'unknown' });
        window.open(WA_LINK, '_blank');
      });
    });
    fbq('track', 'ViewContent');
  </script>
</body>
</html>
```

---

## CSS Conventions

### Color Palette

| Variable | Hex | Penggunaan |
|----------|-----|------------|
| `--green` | `#25D366` | WA button utama |
| `--gold` | `#ffd166` | Aksen premium, harga, badge |
| `--red` | `#c1121f` | Urgency, stok terbatas, harga coret |
| `--dark` | `#111111` | Dark theme background / text |
| `--bg` | `#f7f7f9` | Light theme background |

### Standard Animations (reuse jika relevan)

```css
@keyframes softGlow { 0%,100%{box-shadow:0 0 10px #ffd16660} 50%{box-shadow:0 0 22px #ffd166cc} }
@keyframes pulseGold { 0%,100%{transform:scale(1)} 50%{transform:scale(1.03)} }
@keyframes floaty { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-6px)} }
@keyframes shine { 0%{background-position:-200%} 100%{background-position:200%} }
@keyframes popIn { from{transform:scale(.9);opacity:0} to{transform:scale(1);opacity:1} }
```

### Responsive Breakpoint

```css
@media (max-width: 700px) {
  /* Mobile adjustments */
}
```

---

## JavaScript Conventions

- Gunakan `const` untuk semua nilai yang tidak berubah
- Gunakan arrow functions untuk callbacks
- DOM selection: `querySelector` / `querySelectorAll` / `getElementById`
- Event handling: `addEventListener` (bukan inline `onclick`)
- WhatsApp link: selalu gunakan `window.open(WA_LINK, '_blank')`
- URL encoding: selalu gunakan `encodeURIComponent()` untuk WA_TEXT

---

## Git Conventions

Project mengikuti **Conventional Commits**:

```
type(scope): short description
```

### Types yang dipakai

| Type | Kapan dipakai |
|------|--------------|
| `feat` | Fitur baru atau LP baru |
| `fix` | Bugfix (broken link, tracking error, dll) |
| `copy` | Perubahan teks/copywriting tanpa mengubah logic |
| `refactor` | Restrukturisasi kode tanpa mengubah fungsi |
| `style` | Perubahan visual/CSS |
| `chore` | Update config, .gitignore, README |

### Scope yang sering dipakai

- `lp` — perubahan umum ke semua LP
- `lp-quiz` — spesifik ke `lp-quiz-quick.html`
- `lp-video` — spesifik ke `lp-video-first.html`
- `lp-hard` — spesifik ke `lp-hard-sell-direct.html`
- `lp-testi` — spesifik ke `lp-testimoni-grid.html`
- `assets` — perubahan di folder assets

### Contoh commit messages

```
feat(lp): add new quiz variant for cold audience
copy(lp-hard): update headline to focus on energy benefit
fix(lp-quiz): fix countdown timer not resetting on modal close
style(lp-testi): improve testimonial grid for mobile
```

---

## Assets Management

- Folder: `assets/` dan `assets/Photos-3-001/`
- Format yang direkomendasikan: **WEBP** (performa terbaik), fallback JPG/PNG
- Video files (MP4, MOV, AVI) di-exclude dari git via `.gitignore` — simpan di cloud storage
- Instagram Reels di-embed via `<blockquote class="instagram-media">` + Instagram embed script

---

## What NOT to Do

- Jangan hapus atau ubah Facebook Pixel ID (`948013317787488`)
- Jangan hapus WA button atau kurangi jumlahnya di bawah 3
- Jangan tambah link keluar selain ke WhatsApp
- Jangan tambah form/checkout page — semua via WA
- Jangan commit file video (MP4, MOV, dll) — ukurannya besar dan di-gitignore
- Jangan ubah harga (Rp130.000 / Rp150.000 coret) tanpa konfirmasi eksplisit
- Jangan push ke branch selain yang ditentukan untuk session tersebut
