import Jed from 'jed';
import forceSingleton from '../forceSingleton';

import { getLocaleData } from './I18nHelpers';

const cheveronPrefix = () => (window.I18N_MARK ? '\u00BB' : '');
const cheveronSuffix = () => (window.I18N_MARK ? '\u00AB' : '');

export const jed = forceSingleton('Jed', () => new Jed(getLocaleData()));

export const translate = (...args) =>
  `${cheveronPrefix()}${jed.gettext(...args)}${cheveronSuffix()}`;
export const ngettext = (...args) =>
  `${cheveronPrefix()}${jed.ngettext(...args)}${cheveronSuffix()}`;

export const { sprintf } = jed;
