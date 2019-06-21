import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { sprintf, translate as __ } from '../../common/I18n';
import { noop } from '../../common/helpers';
import './BrowserSupport.scss';

const BrowserSupport = ({ show, browserName, initializeBanner }) => {
  useEffect(() => {
    initializeBanner();
  });

  if (!show) return null;

  return (
    <div className="buorg">
      <b className="buorg-mainmsg">
        {sprintf(
          __('We will drop support for your browser (%s) soon.'),
          browserName
        )}
      </b><br />
      <div className="buorg-moremsg">
        {__(
          'Please update to modern browser. In case it is not possible for you, let us know you need us to continue supporting your browser.'
        )}
      </div>
      <div>
        <a href="https://forms.gle/VL8H5Cby2LWZMhn69">{__('Let us know')}</a>,
        {__('or')}
        <a href="https://community.theforeman.org/t/drop-browser-support-deprecate-phantomjs/13887">
          {__('join the discussion')}
        </a>.
      </div>
      <div className="buorg-buttons">
        <Button bsStyle="primary">{__('Update')}</Button>
        <span>{__('or')}</span>
        <Button bsStyle="info">{__('ignore')}</Button>
      </div>
    </div>
  );
};

BrowserSupport.propTypes = {
  show: PropTypes.bool.isRequired,
  browserName: PropTypes.string,
  initializeBanner: PropTypes.func,
};

BrowserSupport.defaultProps = {
  browserName: '',
  initializeBanner: noop,
};

export default BrowserSupport;
