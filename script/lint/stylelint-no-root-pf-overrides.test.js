const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');

const pluginPath = path.resolve(
  __dirname,
  './stylelint-no-root-pf-overrides.js'
);
const ruleName = 'foreman/no-root-pf-overrides';

let stylelint;

const lint = code =>
  stylelint.lint({
    code,
    config: {
      plugins: [pluginPath],
      rules: { [ruleName]: true },
    },
  });

const getWarnings = async code => {
  const result = await lint(code);
  return result.results[0].warnings.filter(warn => warn.rule === ruleName);
};

const expectWarning = async (code, expectedSelector) => {
  const warnings = await getWarnings(code);
  assert.equal(warnings.length, 1, `Expected 1 warning for: ${code}`);
  assert.ok(
    warnings[0].text.includes(expectedSelector),
    `Expected warning to contain "${expectedSelector}", got "${warnings[0].text}"`
  );
};

const expectNoWarning = async code => {
  const warnings = await getWarnings(code);
  assert.equal(warnings.length, 0, `Expected no warnings for: ${code}`);
};

describe(ruleName, async () => {
  stylelint = (await import('stylelint')).default;

  describe('rejects unscoped PF selectors at root', () => {
    it('bare PF class', () =>
      expectWarning('.pf-v5-c-button { color: red; }', '.pf-v5-c-button'));

    it('PF modifier class', () =>
      expectWarning(
        '.pf-m-primary { background: blue; }',
        '.pf-m-primary'
      ));

    it('PF component with modifier', () =>
      expectWarning(
        '.pf-v5-c-button.pf-m-primary { color: red; }',
        '.pf-v5-c-button.pf-m-primary'
      ));

    it('element followed by PF class', () =>
      expectWarning(
        'div.pf-v5-c-page { margin: 0; }',
        'div.pf-v5-c-page'
      ));

    it('element with PF descendant', () =>
      expectWarning(
        'div .pf-v5-c-button { color: red; }',
        'div .pf-v5-c-button'
      ));

    it('PF class with child combinator', () =>
      expectWarning(
        '.pf-v5-c-page > .pf-v5-c-page__main { padding: 0; }',
        '.pf-v5-c-page > .pf-v5-c-page__main'
      ));
  });

  describe('accepts PF selectors scoped under a custom class or id', () => {
    it('scoped under custom class', () =>
      expectNoWarning('.my-component .pf-v5-c-button { color: red; }'));

    it('scoped under custom id', () =>
      expectNoWarning('#my-app .pf-v5-c-button { color: red; }'));

    it('nested inside custom class (SCSS)', () =>
      expectNoWarning('.my-component { .pf-v5-c-button { color: red; } }'));

    it('custom class without PF', () =>
      expectNoWarning('.my-class { color: red; }'));
  });

  describe('accepts selectors without PF classes', () => {
    it('plain element', () =>
      expectNoWarning('div { color: red; }'));

    it('custom class', () =>
      expectNoWarning('.custom-btn { color: red; }'));

    it('id selector', () =>
      expectNoWarning('#main { padding: 0; }'));
  });

  describe('disabled rule', () => {
    it('returns no warnings when disabled', async () => {
      const result = await stylelint.lint({
        code: '.pf-v5-c-button { color: red; }',
        config: {
          plugins: [pluginPath],
          rules: { [ruleName]: false },
        },
      });
      const warnings = result.results[0].warnings.filter(
        warn => warn.rule === ruleName
      );
      assert.equal(warnings.length, 0);
    });
  });
});
