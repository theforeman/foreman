import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { LoginPage as PFLoginPage } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import LoginPageCaption from './components/LoginPageCaption';
import Clouds from './components/Clouds';
import { adjustAlerts, defaultFormProps } from './helpers';
import './LoginPage.scss';

const LoginPage = ({
  alertMessage,
  alertType,
  backgroundUrl,
  caption,
  logoSrc,
  token,
  version,
}) => {
  const { alert, submitError } = adjustAlerts(alertType, alertMessage);
  return (
    <Fragment>
      <Clouds />
      <PFLoginPage
        container={{
          backgroundUrl,
          alert,
        }}
        header={{
          logoSrc,
          caption: <LoginPageCaption version={version} caption={caption} />,
        }}
        card={{
          title: __('Log Into Your Account'),
          form: {
            ...defaultFormProps,
            submitError,
            additionalFields: (
              <input name="authenticity_token" type="hidden" value={token} />
            ),
          },
        }}
      />
    </Fragment>
  );
};

LoginPage.propTypes = {
  alertMessage: PropTypes.string,
  alertType: PropTypes.string,
  backgroundUrl: PropTypes.string,
  caption: PropTypes.string,
  logoSrc: PropTypes.string,
  token: PropTypes.string.isRequired,
  version: PropTypes.string,
};

LoginPage.defaultProps = {
  alertMessage: null,
  alertType: null,
  backgroundUrl: '/assets/login_background.png',
  caption: null,
  logoSrc: '/assets/login_logo.png',
  version: null,
};

export default LoginPage;
