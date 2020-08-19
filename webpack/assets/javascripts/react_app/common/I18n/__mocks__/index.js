export const jed = jest.fn();

export const translate = jest.fn(str => str);
export const ngettext = (singular, plural, number) =>
  number > 1 ? plural : singular;

export const { sprintf } = jest.requireActual('jed');

export const intl = {
  timezone: 'UTC',
  locale: 'en',
};

const i18n = {
  translate,
  ngettext,
  jed,
  sprintf,
  intl,
};

window.__ = translate;
window.n__ = ngettext;
window.Jed = jed;
window.i18n = jed;

export default i18n;
