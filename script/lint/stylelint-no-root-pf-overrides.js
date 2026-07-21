const stylelint = require('stylelint');

const ruleName = 'foreman/no-root-pf-overrides';
const messages = stylelint.utils.ruleMessages(ruleName, {
  rejected: selector =>
    `Unexpected top-level PatternFly selector "${selector}". Nest it under a component class or ID instead. If already scoped, reorder the selectors to place the scoped selector first.`,
});

const PF_PATTERN = /\.pf-/;
const htmlTags = require('html-tags');

const HTML_ELEMENTS = new Set(htmlTags.default || htmlTags);

function startsUnscoped(selector) {
  const trimmed = selector.trim();
  if (trimmed.startsWith('.pf-')) return true;

  const leadingIdent = trimmed.match(/^([a-zA-Z][a-zA-Z0-9]*)/);
  if (!leadingIdent) return false;
  const tag = leadingIdent[1];
  if (!HTML_ELEMENTS.has(tag)) return false;

  const afterTag = trimmed.slice(tag.length);
  if (!afterTag || /^[\s>#~+,{]/.test(afterTag) || afterTag.startsWith('[')) {
    return true;
  }
  if (afterTag.startsWith('.pf-')) return true;

  return false;
}

const ruleFunction = enabled => (root, result) => {
  if (!enabled) return;

  root.walkRules(ruleNode => {
    if (ruleNode.parent.type !== 'root') return;

    ruleNode.selectors.forEach(selector => {
      if (PF_PATTERN.test(selector) && startsUnscoped(selector)) {
        stylelint.utils.report({
          message: messages.rejected(selector),
          node: ruleNode,
          result,
          ruleName,
        });
      }
    });
  });
};

ruleFunction.ruleName = ruleName;
ruleFunction.messages = messages;

module.exports = stylelint.createPlugin(ruleName, ruleFunction);
