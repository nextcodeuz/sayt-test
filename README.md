# Sayt-test — k6 bilan yuklama sinovi

Bu loyiha o'zingiz boshqaradigan yoki sinash uchun aniq ruxsat olgan veb-saytning javob vaqti va barqarorligini tekshirish uchun tayyorlangan sodda k6 namunalarini jamlaydi.

Sinovlar ehtiyotkor sozlamalardan boshlanadi: asosiy skript uchta virtual foydalanuvchi bilan 30 soniya davomida faqat GET so'rov yuboradi. Yuklamani oshirishdan oldin server egasi bilan kelishib oling va monitoringni kuzatib boring.

## Repoda nimalar bor?

- `nextcodeuz.js` — asosiy, past yuklamali k6 smoke-test.
- `windows.sh` — Windows muhitida k6 o'rnatish yordamchisi.
- `linux_mac.sh` — Linux va macOS uchun o'rnatish yordamchisi.
- `termux.sh` — Termux ichida Ubuntu orqali k6 o'rnatish.
- `LICENSE` — MIT litsenziyasi.

## O'rnatish

k6 rasmiy o'rnatish qo'llanmasidan ham foydalanishingiz mumkin: https://grafana.com/docs/k6/latest/set-up/install-k6/

Windows'da Git Bash orqali:

```bash
bash windows.sh
```

Linux yoki macOS'da:

```bash
chmod +x linux_mac.sh
./linux_mac.sh
```

Termux'da:

```bash
chmod +x termux.sh
./termux.sh
```

O'rnatilgandan keyin tekshiring:

```bash
k6 version
```

## Sinovni ishga tushirish

PowerShell:

```powershell
$env:TARGET_URL = "https://your-domain.example/health"
$env:AUTHORIZED_TARGET = "yes"
k6 run nextcodeuz.js
```

Linux, macOS yoki Git Bash:

```bash
export TARGET_URL="https://your-domain.example/health"
export AUTHORIZED_TARGET="yes"
k6 run nextcodeuz.js
```

`TARGET_URL` ni sinovdan o'tkazishga ruxsatingiz bo'lgan endpoint bilan almashtiring. Skript URL noto'g'ri bo'lsa yoki ruxsat tasdig'i berilmasa, ishga tushmaydi.

## Natijalarni qanday o'qish kerak?

k6 so'rovlar soni, xatolar ulushi va javob vaqtlarini ko'rsatadi. Skriptda quyidagi boshlang'ich mezonlar bor:

- muvaffaqiyatsiz so'rovlar ulushi 5% dan kam;
- javob vaqtining 95-persentili 1,5 soniyadan past.

Bular universal SLA emas. O'zingizning servis talablaringizga moslang.

## Xavfsiz foydalanish

Bu vositani begona saytlar, uchinchi tomon xizmatlari yoki ruxsatsiz infratuzilmaga qarshi ishlatmang. Skript ataylab Tor proksi, soxta `X-Forwarded-For` sarlavhasi, User-Agent aylantirish va yuqori tezlikdagi agressiv so'rovlarni ishlatmaydi. O'z serveringizdagi yuklamani asta-sekin oshiring, limit va monitoringni oldindan belgilang.

