# 🚀 NextCodeUz sayt-test: k6 + Grafana qo‘llanmasi

**NextCodeUz sayt-test** — bu o‘zingizga tegishli yoki ruxsat berilgan saytni yuklama ostida tekshirish uchun ishlatiladigan loyiha.  
Bu loyiha orqali siz sayt tezligi, javob vaqti, xatoliklar soni va umumiy barqarorlikni kuzatishingiz mumkin. k6 skriptlari JavaScript’da yoziladi, natijalar esa Grafana orqali chiroyli monitoring ko‘rinishida tahlil qilinadi.

## 📦 Repo tarkibi

Bu repoda quyidagi asosiy fayllar bor:

- `nextcodeuz.js` — asosiy k6 test skripti  
- `windows.sh` — Windows uchun o‘rnatish/ishga tushirish skripti  
- `linux_mac.sh` — Linux va macOS uchun skript  
- `termux.sh` — Termux uchun skript  
- `README.md` — loyiha tavsifi

## 🛠 O‘rnatish

Repo’ni yuklab oling:

```bash
git clone https://github.com/nextcodeuz/sayt-test.git
cd sayt-test
