import React from 'react';
import PropTypes from 'prop-types';
import { LoginPage as PFLoginPage } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import LoginPageCaption from './components/LoginPageCaption';
import { adjustAlerts, defaultFormProps } from './helpers';
import './LoginPage.scss';

const LoginPage = ({
  alerts,
  backgroundUrl,
  caption,
  logoSrc,
  token,
  version,
}) => {
  const { modifiedAlerts, submitErrors } = adjustAlerts(alerts);
  return (
    <div id="login-page">
      <PFLoginPage
        container={{
          backgroundUrl,
          alert: modifiedAlerts,
        }}
        header={{
          logoSrc,
          caption: <LoginPageCaption version={version} caption={caption} />,
        }}
        card={{
          title: __('Log in to your account'),
          form: {
            ...defaultFormProps,
            submitError: submitErrors,
            additionalFields: (
              <input name="authenticity_token" type="hidden" value={token} />
            ),
          },
        }}
      />
    </div>
  );
};

LoginPage.propTypes = {
  alerts: PropTypes.shape({
    success: PropTypes.string,
    warning: PropTypes.string,
    error: PropTypes.string,
  }),
  backgroundUrl: PropTypes.string,
  caption: PropTypes.string,
  logoSrc: PropTypes.string,
  token: PropTypes.string.isRequired,
  version: PropTypes.string,
};

LoginPage.defaultProps = {
  alerts: null,
  backgroundUrl: null,
  caption: null,
  logoSrc: null,
  version: null,
};

export default LoginPage;
