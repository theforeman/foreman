function getStringValue(node) {
  if (node.type === 'Literal' && typeof node.value === 'string') {
    return node.value;
  }
  if (node.type === 'TemplateLiteral') {
    return node.quasis.map(quasi => quasi.value.raw).join('');
  }
  return null;
}

function createClassNameVisitor(checkFn) {
  return {
    JSXAttribute(node) {
      if (node.name.name !== 'className') return;
      if (!node.value) return;

      if (node.value.type === 'Literal') {
        checkFn(node, node.value);
      }

      if (
        node.value.type === 'JSXExpressionContainer' &&
        node.value.expression
      ) {
        const expr = node.value.expression;
        if (expr.type === 'Literal' || expr.type === 'TemplateLiteral') {
          checkFn(node, expr);
        }
        if (
          expr.type === 'CallExpression' &&
          expr.callee.type === 'Identifier' &&
          expr.callee.name === 'classNames'
        ) {
          expr.arguments.forEach(arg => {
            if (arg.type === 'Literal' || arg.type === 'TemplateLiteral') {
              checkFn(node, arg);
            }
          });
        }
      }
    },
  };
}

module.exports = { getStringValue, createClassNameVisitor };
