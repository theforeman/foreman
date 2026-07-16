const MODIFIER_TO_PROP = {
  'pf-m-primary': 'variant="primary"',
  'pf-m-secondary': 'variant="secondary"',
  'pf-m-tertiary': 'variant="tertiary"',
  'pf-m-danger': 'variant="danger"',
  'pf-m-warning': 'variant="warning"',
  'pf-m-success': 'variant="success"',
  'pf-m-info': 'variant="info"',
  'pf-m-link': 'variant="link"',
  'pf-m-plain': 'variant="plain"',
  'pf-m-inline': 'isInline',
  'pf-m-block': 'isBlock',
  'pf-m-disabled': 'isDisabled',
  'pf-m-expanded': 'isExpanded',
  'pf-m-compact': 'isCompact',
  'pf-m-sm': 'size="sm"',
  'pf-m-md': 'size="md"',
  'pf-m-lg': 'size="lg"',
  'pf-m-xl': 'size="xl"',
  'pf-m-2xl': 'size="2xl"',
  'pf-m-3xl': 'size="3xl"',
  'pf-m-4xl': 'size="4xl"',
};

const { getStringValue, createClassNameVisitor } = require('./utils');

const PF_MODIFIER_REGEX = /pf-m-[a-z0-9][a-z0-9-]*/g;

module.exports = {
  meta: {
    type: 'suggestion',
    docs: {
      description:
        'Prefer PatternFly component props over PF modifier CSS classes (pf-m-*)',
    },
    schema: [],
  },
  create(context) {
    function checkForModifiers(node, valueNode) {
      const stringValue = getStringValue(valueNode);
      if (!stringValue) return;

      const modifiers = stringValue.match(PF_MODIFIER_REGEX);
      if (!modifiers) return;

      const reported = new Set();

      modifiers.forEach(modifier => {
        if (reported.has(modifier)) return;
        reported.add(modifier);

        const prop = MODIFIER_TO_PROP[modifier];
        const message = prop
          ? `Prefer using the '${prop}' prop instead of the '${modifier}' CSS class.`
          : `Avoid using the '${modifier}' CSS class directly; use the equivalent PatternFly component prop instead.`;

        context.report({ node, message });
      });
    }

    return createClassNameVisitor(checkForModifiers);
  },
};
