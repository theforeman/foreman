// @theforeman/vendor/react-intl
export default from 'react-intl';
export * from 'react-intl';

export const asyncLoadLocalData = locale =>
  import(/* webpackChunkName: 'react-intl/locale/[request]' */ `react-intl/locale-data/${locale}`);
