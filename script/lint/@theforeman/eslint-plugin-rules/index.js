const requireOuiaidRule = require('./require-ouiaid');
const preferPfComponentsRule = require('./prefer-pf-components');
const preferPfPropsRule = require('./prefer-pf-props');

module.exports = {
  rules: {
    'require-ouiaid': requireOuiaidRule,
    'prefer-pf-components': preferPfComponentsRule,
    'prefer-pf-props': preferPfPropsRule,
  },
};
