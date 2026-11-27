/* eslint-disable */
// CJS shim for uuid v13 (pure ESM) - required for Jest 26 compatibility
const crypto = require('crypto');

function rng() {
  return crypto.randomBytes(16);
}

function v1() {
  const rnds = rng();
  // Set version (4 bits) and variant (2 bits)
  rnds[6] = (rnds[6] & 0x0f) | 0x10;
  rnds[8] = (rnds[8] & 0x3f) | 0x80;
  const hex = Buffer.from(rnds).toString('hex');
  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    hex.slice(12, 16),
    hex.slice(16, 20),
    hex.slice(20, 32),
  ].join('-');
}

function v4() {
  const rnds = rng();
  rnds[6] = (rnds[6] & 0x0f) | 0x40;
  rnds[8] = (rnds[8] & 0x3f) | 0x80;
  const hex = Buffer.from(rnds).toString('hex');
  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    hex.slice(12, 16),
    hex.slice(16, 20),
    hex.slice(20, 32),
  ].join('-');
}

function v7() {
  const rnds = rng();
  const now = Date.now();
  // Encode timestamp in first 48 bits
  rnds[0] = (now / 2 ** 40) & 0xff;
  rnds[1] = (now / 2 ** 32) & 0xff;
  rnds[2] = (now / 2 ** 24) & 0xff;
  rnds[3] = (now / 2 ** 16) & 0xff;
  rnds[4] = (now / 2 ** 8) & 0xff;
  rnds[5] = now & 0xff;
  // Set version 7 and variant
  rnds[6] = (rnds[6] & 0x0f) | 0x70;
  rnds[8] = (rnds[8] & 0x3f) | 0x80;
  const hex = Buffer.from(rnds).toString('hex');
  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    hex.slice(12, 16),
    hex.slice(16, 20),
    hex.slice(20, 32),
  ].join('-');
}

module.exports = { v1, v4, v7 };
