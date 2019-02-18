// @theforeman/vendor/intl
import intl from 'intl';

intl.asyncLoadLocalData = locale =>
  import(/* webpackChunkName: 'intl/locale/[request]' */ `intl/locale-data/jsonp/${locale}`);

export default intl;
