import { documentLocale } from '../../common/I18n';

export const formatDateTime = datetime => {
  const locale = documentLocale();
  const options = {
    month: 'numeric',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
    hour12: true,
  };
  try {
    return new Date(datetime).toLocaleDateString(locale, options);
  } catch {
    return new Date(datetime).toLocaleDateString('en', options);
  }
};
