const { RuleTester } = require('eslint');
const rule = require('./prefer-pf-components');

const ruleTester = new RuleTester({
  parserOptions: {
    ecmaVersion: 2020,
    ecmaFeatures: { jsx: true },
  },
});

ruleTester.run('prefer-pf-components', rule, {
  valid: [
    {
      code: '<div className="my-custom-class" />',
    },
    {
      code: '<div className="pf-m-danger" />',
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
      code: '<div className="pf-v5-c-alert" />',
      errors: [
        {
          message:
            "Prefer using the <Alert> component instead of the 'pf-v5-c-alert' CSS class.",
        },
      ],
    },
    {
      code: '<div className="pf-v5-c-button" />',
      errors: [
        {
          message:
            "Prefer using the <Button> component instead of the 'pf-v5-c-button' CSS class.",
        },
      ],
    },
    {
      code: '<div className="pf-v5-c-alert__title pf-v5-c-badge" />',
      errors: [
        {
          message:
            "Prefer using the <Alert> component instead of the 'pf-v5-c-alert' CSS class.",
        },
        {
          message:
            "Prefer using the <Badge> component instead of the 'pf-v5-c-badge' CSS class.",
        },
      ],
    },
    {
      code: '<div className={`pf-v5-c-form`} />',
      errors: [
        {
          message:
            "Prefer using the <Form> component instead of the 'pf-v5-c-form' CSS class.",
        },
      ],
    },
    {
      code: '<div className="pf-v5-l-flex" />',
      errors: [
        {
          message:
            "Prefer using the <Flex> component instead of the 'pf-v5-l-flex' CSS class.",
        },
      ],
    },
    {
      code: '<div className="pf-v5-c-form-control" />',
      errors: [
        {
          message:
            "Prefer using the <TextInput / TextArea / FormSelect> component instead of the 'pf-v5-c-form-control' CSS class.",
        },
      ],
    },
    {
      code: '<div className="pf-v5-c-helper-text" />',
      errors: [
        {
          message:
            "Avoid using the 'pf-v5-c-helper-text' CSS class directly; use the equivalent PatternFly React component instead.",
        },
      ],
    },
    {
      code: '<div className={classNames("pf-v5-c-button", "my-class")} />',
      errors: [
        {
          message:
            "Prefer using the <Button> component instead of the 'pf-v5-c-button' CSS class.",
        },
      ],
    },
    {
      code: '<div className={classNames(`pf-v5-l-flex`, "pf-v5-c-badge")} />',
      errors: [
        {
          message:
            "Prefer using the <Flex> component instead of the 'pf-v5-l-flex' CSS class.",
        },
        {
          message:
            "Prefer using the <Badge> component instead of the 'pf-v5-c-badge' CSS class.",
        },
      ],
    },
  ],
});
