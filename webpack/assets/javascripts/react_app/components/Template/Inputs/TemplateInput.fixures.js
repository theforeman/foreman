const WithRequireAndInfo = {
  isRequired: true,
  info: 'some description',
};

const supportedTypes = ['plain', 'search', 'date'];

export const ReportAutocompleteProps = {
  url: 'some-url',
  resourceType: 'some-controller',
  searchQuery: 'a query',
  label: 'some label',
  id: 3,
  template: 'report_template_report',
};

export const ReportAutocompleteWithRequireAndInfo = {
  ...ReportAutocompleteProps,
  ...WithRequireAndInfo,
};

export const ReportDateTimePrpos = {
  id: 4,
  label: 'some-label',
  locale: 'EN',
  template: 'report_template_report',
  value: '2019-01-04',
};

export const ReportDateTimeWithRequireAndInfo = {
  ...ReportDateTimePrpos,
  ...WithRequireAndInfo,
};

export const ReportTemplateGenerateSearch = {
  data: {
    ...ReportAutocompleteProps,
    ...WithRequireAndInfo,
    supportedTypes,
    type: 'search',
  },
};

export const ReportTemplateGenerateDate = {
  data: {
    ...ReportDateTimePrpos,
    ...WithRequireAndInfo,
    supportedTypes,
    type: 'date',
  },
};
