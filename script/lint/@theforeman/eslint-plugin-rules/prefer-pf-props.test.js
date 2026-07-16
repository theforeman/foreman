const { RuleTester } = require('eslint');
const rule = require('./prefer-pf-props');

const ruleTester = new RuleTester({
  parserOptions: {
    ecmaVersion: 2020,
    ecmaFeatures: { jsx: true },
  },
});

ruleTester.run('prefer-pf-props', rule, {
  valid: [
    {
      code: '<Button variant="danger" />',
    },
    {
      code: '<div className="my-custom-class" />',
    },
    {
      code: '<div className="pf-v5-c-alert" />',
    },
    {
      code: '<div className={someVariable} />',
    },
    {
      code: '<div className={classNames("my-custom-class", "another")} />',
    },
    {
      code: '<div />',
    },
  ],
  invalid: [
    {
      code: '<div className="pf-m-danger" />',
      errors: [
        {
          message:
            "Prefer using the 'variant=\"danger\"' prop instead of the 'pf-m-danger' CSS class.",
        },
      ],
    },
    {
      code: '<div className="pf-m-primary pf-m-sm" />',
      errors: [
        {
          message:
            "Prefer using the 'variant=\"primary\"' prop instead of the 'pf-m-primary' CSS class.",
        },
        {
          message:
            "Prefer using the 'size=\"sm\"' prop instead of the 'pf-m-sm' CSS class.",
        },
      ],
    },
    {
      code: '<div className="pf-m-expanded" />',
      errors: [
        {
          message:
            "Prefer using the 'isExpanded' prop instead of the 'pf-m-expanded' CSS class.",
        },
      ],
    },
    {
      code: '<div className={`pf-m-inline`} />',
      errors: [
        {
          message:
            "Prefer using the 'isInline' prop instead of the 'pf-m-inline' CSS class.",
        },
      ],
    },
    {
      code: '<div className="pf-m-fill" />',
      errors: [
        {
          message:
            "Avoid using the 'pf-m-fill' CSS class directly; use the equivalent PatternFly component prop instead.",
        },
      ],
    },
    {
      code: '<div className="pf-m-2xl" />',
      errors: [
        {
          message:
            "Prefer using the 'size=\"2xl\"' prop instead of the 'pf-m-2xl' CSS class.",
        },
      ],
    },
    {
      code: '<div className={classNames("pf-m-danger", "my-class")} />',
      errors: [
        {
          message:
            "Prefer using the 'variant=\"danger\"' prop instead of the 'pf-m-danger' CSS class.",
        },
      ],
    },
    {
      code: '<div className={classNames(`pf-m-compact`, "pf-m-plain")} />',
      errors: [
        {
          message:
            "Prefer using the 'isCompact' prop instead of the 'pf-m-compact' CSS class.",
        },
        {
          message:
            "Prefer using the 'variant=\"plain\"' prop instead of the 'pf-m-plain' CSS class.",
        },
      ],
    },
  ],
});
