# 🚀 k6 + Grafana bilan saytni kuchli test qilish

Agar siz **o‘zingizga tegishli sayt** yoki ruxsat berilgan loyiha ustida ishlayotgan bo‘lsangiz, **k6** va **Grafana** — saytning chidamliligini tekshirish uchun juda qulay kombinatsiya.  
Bu usul orqali siz server nechta so‘rovni ko‘tara olishini, qaysi joyda sekinlashishini va qayerda bottleneck borligini ko‘rishingiz mumkin. ⚙️

---

## 🔥 k6 nima?

**k6** — bu modern load testing tool.  
U orqali siz:

- bir vaqtning o‘zida ko‘p foydalanuvchi yuborasiz 👥
- response time ni o‘lchaysiz ⏱️
- xatolarni kuzatasiz ❌
- server yuk ostida qanday ishlashini bilasiz 📊

k6 skriptlari **PHP emas**, balki **JavaScript** ko‘rinishida yoziladi.

---

## 📈 Grafana nima?

**Grafana** — bu monitoring va dashboard platformasi.  
k6 dan kelgan natijalarni Grafana’da chiroyli grafiklar ko‘rinishida ko‘rish mumkin.

Siz quyidagilarni kuzatasiz:

- request soni
- response time
- error rate
- virtual user soni
- server yuklanishi

---

## 🛠 Nima uchun kerak?

Bu test sizga yordam beradi:

- sayt qachon sekinlashishini bilish uchun
- server kuchini baholash uchun
- cache kerakmi yo‘qmi aniqlash uchun
- API endpointlarni tekshirish uchun
- real foydalanuvchi bosimini simulyatsiya qilish uchun

---

## ✅ Oddiy k6 test skript

Quyidagi skript xavfsiz va oddiy test uchun:

```javascript
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 5,
  duration: '30s',
};

export default function () {
  http.get('http://localhost/');
  sleep(1);
}
