const cheveronPrefix = () => (window.I18N_MARK ? '\u00BB' : '');
const cheveronSuffix = () => (window.I18N_MARK ? '\u00AB' : '');

const createTranslateMock = () =>
  jest.fn(str => `${cheveronPrefix()}${str}${cheveronSuffix()}`);

export const jed = jest.fn();

export const translate = createTranslateMock();
export const ngettext = createTranslateMock();

export const sprintf = createTranslateMock();

const i18n = {
  translate,
  ngettext,
  jed,
  sprintf,
};

window.__ = translate;
window.n__ = ngettext;
window.Jed = jed;
window.i18n = jed;

export default i18n;
