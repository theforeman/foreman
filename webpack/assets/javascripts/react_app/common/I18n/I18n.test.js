import Jed from 'jed';
import { translate, ngettext } from './index';

jest.unmock('./index');
jest.unmock('jed');

describe('gettext', () => {
  Jed.gettext = jest.fn(s => s);
  it('chevrons should not be presented', () => {
    expect(translate('should not be with chevrons')).toMatchSnapshot();
  });
  it('chevrons should be presented', () => {
    global.I18N_MARK = true;
    expect(translate('should be with chevrons')).toMatchSnapshot();
  });
});

describe('ngettext', () => {
  Jed.ngettext = jest.fn(s => s);
  it('chevrons should not be presented', () => {
    expect(ngettext('should not be with chevrons')).toMatchSnapshot();
  });
  it('chevrons should be presented', () => {
    global.I18N_MARK = true;
    expect(ngettext('should be with chevrons')).toMatchSnapshot();
  });
});
