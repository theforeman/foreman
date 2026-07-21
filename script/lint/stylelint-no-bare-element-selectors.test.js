const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');

const pluginPath = path.resolve(
  __dirname,
  './stylelint-no-bare-element-selectors.js'
);
const ruleName = 'foreman/no-bare-element-selectors';

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

  describe('rejects bare element selectors at root', () => {
    it('single element', () => expectWarning('div { color: red; }', 'div'));

    it('span', () => expectWarning('span { margin: 0; }', 'span'));
    it('p', () => expectWarning('p { font-size: 14px; }', 'p'));
    it('h1', () => expectWarning('h1 { font-weight: bold; }', 'h1'));
    it('table', () => expectWarning('table { width: 100%; }', 'table'));
    it('a', () => expectWarning('a { text-decoration: none; }', 'a'));
    it('ul', () => expectWarning('ul { list-style: none; }', 'ul'));
    it('input', () => expectWarning('input { border: none; }', 'input'));

    it('descendant combinator', () =>
      expectWarning('div span { color: red; }', 'div span'));

    it('child combinator', () =>
      expectWarning('div > span { color: red; }', 'div > span'));

    it('adjacent sibling combinator', () =>
      expectWarning('div + span { color: red; }', 'div + span'));

    it('general sibling combinator', () =>
      expectWarning('div ~ span { color: red; }', 'div ~ span'));

    it('element with attribute selector', () =>
      expectWarning('div[role="main"] { color: red; }', 'div[role="main"]'));

    it('flags only bare selector in comma list', async () => {
      const warnings = await getWarnings('.btn, div { color: red; }');
      assert.equal(warnings.length, 1);
      assert.ok(warnings[0].text.includes('div'));
    });

    it('flags multiple bare selectors in comma list', async () => {
      const warnings = await getWarnings('div, span { color: red; }');
      assert.equal(warnings.length, 2);
    });

    it('element with pseudo-class', () =>
      expectWarning('div:hover { color: red; }', 'div:hover'));

    it('element with pseudo-element', () =>
      expectWarning('div::before { content: ""; }', 'div::before'));
  });

  describe('accepts selectors scoped by class or id', () => {
    it('class selector', () =>
      expectNoWarning('.my-class { color: red; }'));

    it('id selector', () =>
      expectNoWarning('#my-id { color: red; }'));

    it('element scoped under a class', () =>
      expectNoWarning('.wrapper div { color: red; }'));

    it('element with class', () =>
      expectNoWarning('div.my-class { color: red; }'));

    it('element with id', () =>
      expectNoWarning('div#my-id { color: red; }'));

    it('nested inside a class (SCSS nesting)', () =>
      expectNoWarning('.parent { div { color: red; } }'));

    it('PF class selector', () =>
      expectNoWarning('.pf-v5-c-button { color: red; }'));

    it('universal selector', () =>
      expectNoWarning('* { box-sizing: border-box; }'));
  });

  describe('disabled rule', () => {
    it('returns no warnings when disabled', async () => {
      const result = await stylelint.lint({
        code: 'div { color: red; }',
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
