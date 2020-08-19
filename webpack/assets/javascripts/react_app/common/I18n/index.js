import intl from './intl';
import { jed, translate, ngettext, sprintf } from './jed';

export const documentLocale = () => intl.locale;

export { translate, ngettext, jed, sprintf, intl };

export default { translate, ngettext, jed, sprintf, intl };

window.__ = translate;
window.n__ = ngettext;
