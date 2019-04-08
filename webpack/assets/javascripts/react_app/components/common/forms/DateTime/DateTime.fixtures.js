export const DateTimeProps = {
  id: 4,
  label: 'some-label',
  locale: 'EN',
  inputProps: {
    name: 'report_template_report[input_values][4][value]',
  },
  value: '2019-01-04',
};

export const DateTimeWithRequireAndInfo = {
  ...DateTimeProps,
  isRequired: true,
  info: 'some description',
};
