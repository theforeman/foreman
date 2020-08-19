import intl from './intl';

export const getLocaleData = () => {
  const localeKey = intl.locale.replace(/-/g, '_');

  if (intl.locales[localeKey] === undefined) {
    // eslint-disable-next-line no-console
    console.log(
      `could not load translations for ${localeKey} locale, falling back to default locale.`
    );
    return { domain: 'app', locale_data: { app: { '': {} } } };
  }

  return intl.locales[localeKey];
};
