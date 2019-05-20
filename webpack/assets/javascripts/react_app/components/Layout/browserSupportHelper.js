import browserUpdate from 'browser-update';
import { runningInPhantomJS } from '../../common/helpers';

export const checkBrowserSupport = () => {
  if (runningInPhantomJS()) return;
  browserUpdate({
    required: {
      i: 12, // obsolete IE completely
      e: -2,
      f: -5,
      o: -5,
      s: -4,
      c: -5,
    },
    text: `
      <b class="buorg-mainmsg">
        ${__('We will drop support for your browser ({brow_name}) soon.')}
      </b><br />
      <span class="buorg-moremsg">
        ${__(
          'Please update to modern browser. In case it is not possible for you, let us know you need us to continue supporting your browser.'
        )}
      </span>
      <span>
        <a href="https://forms.gle/VL8H5Cby2LWZMhn69">${__('Let us know')}</a>,
        ${__('or')}
        <a href="https://community.theforeman.org/t/drop-browser-support-deprecate-phantomjs/13887">
          ${__('join the discussion')}
        </a>.
      </span>
      <span class="buorg-buttons">
        <a{up_but}>${__('Update')}</a>
        ${__('or')}
        <a{ignore_but}>${__('ignore')}</a>
      </span>
    `,
    insecure: true,
    unsupported: true,
    api: 2019.05,
  });
};
