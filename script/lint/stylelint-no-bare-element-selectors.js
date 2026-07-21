const stylelint = require('stylelint');
const htmlTags = require('html-tags');
const selectorParser = require('postcss-selector-parser');

const ruleName = 'foreman/no-bare-element-selectors';
const messages = stylelint.utils.ruleMessages(ruleName, {
  rejected: selector =>
    `Unexpected bare element selector "${selector}". Scope it under a custom class or ID instead.`,
});

const HTML_ELEMENTS = new Set(htmlTags.default || htmlTags);

function isBareElementSelector(selector) {
  let bare = false;

  selectorParser(selectors => {
    selectors.walk(node => {
      if (node.type === 'selector') {
        const nodes = node.nodes.filter(
          child => child.type !== 'combinator' && child.type !== 'comment'
        );
        if (nodes.length === 0) return;

        const allBareElements = nodes.every(
          child =>
            (child.type === 'tag' && HTML_ELEMENTS.has(child.value)) ||
            child.type === 'attribute' ||
            child.type === 'pseudo'
        );
        const hasTags = nodes.some(child => child.type === 'tag');
        if (allBareElements && hasTags) {
          bare = true;
        }
      }
    });
  }).astSync(selector);

  return bare;
}

const ruleFunction = enabled => (root, result) => {
  if (!enabled) return;

  root.walkRules(ruleNode => {
    if (ruleNode.parent.type !== 'root') return;

    ruleNode.selectors.forEach(selector => {
      if (isBareElementSelector(selector)) {
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
