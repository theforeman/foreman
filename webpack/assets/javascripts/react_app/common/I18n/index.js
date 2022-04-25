import intl from './intl.js';
import { jed, translate, ngettext, sprintf } from './jed.js';

export const documentLocale = async () => {
  await new Promise(resolve => setImmediate(resolve));
  return intl.locale;
};

export { translate, ngettext, jed, sprintf, intl };

export default { translate, ngettext, jed, sprintf, intl };

window.__ = translate;
window.n__ = ngettext;
