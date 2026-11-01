import http from 'k6/http';
import { check, sleep } from 'k6';

// This test is intentionally conservative: three virtual users, GET requests
// only, and a short run. Use it only against a system you own or are authorised
// to test. The acknowledgement below is required so the target is never implicit.
const target = (__ENV.TARGET_URL || '').trim();
const authorised = (__ENV.AUTHORIZED_TARGET || '').trim().toLowerCase();

if (!target) {
  throw new Error('Set TARGET_URL to an endpoint you own or have permission to test.');
}
if (authorised !== 'yes') {
  throw new Error('Confirm authorisation with AUTHORIZED_TARGET=yes before running.');
}

let parsedTarget;
try {
  parsedTarget = new URL(target);
} catch (_) {
  throw new Error('TARGET_URL must be a valid absolute URL.');
}
if (!['http:', 'https:'].includes(parsedTarget.protocol) ||
    parsedTarget.username || parsedTarget.password) {
  throw new Error('TARGET_URL must use HTTP(S) and must not contain credentials.');
}

export const options = {
  scenarios: {
    authorised_smoke_test: {
      executor: 'constant-vus',
      vus: 3,
      duration: '30s',
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.05'],
    http_req_duration: ['p(95)<1500'],
  },
  discardResponseBodies: true,
};

export default function () {
  const response = http.get(target, {
    timeout: '10s',
    tags: { test_type: 'authorised_smoke' },
  });

  check(response, {
    'server returned a response': (r) => r.status > 0,
    'server did not return 5xx': (r) => r.status < 500,
  });

  sleep(1);
}
