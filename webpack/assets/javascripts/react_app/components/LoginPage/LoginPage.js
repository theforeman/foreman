import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  LoginPage as PF5LoginPage,
  Form,
  FormGroup,
  TextInput,
  ActionGroup,
  Button,
  Alert,
  AlertActionCloseButton,
  FormAlert,
} from '@patternfly/react-core';

import { sprintf, translate as __ } from '../../common/I18n';
import { adjustAlerts, defaultFormProps } from './helpers';
import './LoginPage.scss';

const LoginPage = ({ alerts, caption, logoSrc, oidcProviders, token }) => {
  const { modifiedAlerts, submitErrors } = adjustAlerts(alerts);

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLoginDisabled, setIsLoginDisabled] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [alertArr, setAlertArr] = useState(modifiedAlerts);
  const closeAlert = index => {
    const other = alertArr.filter((_, i) => i !== index);
    setAlertArr(other);
  };

  const handleUsernameChange = (_event, value) => {
    setUsername(value);
    if (value !== '' && password !== '') setIsLoginDisabled(false);
  };

  const handlePasswordChange = (_event, value) => {
    setPassword(value);
    if (value !== '' && username !== '') setIsLoginDisabled(false);
  };

  const handleSubmit = () => {
    setIsLoading(true);
    setTimeout(() => {
      setIsLoginDisabled(true);
    }, 10);
  };

  const loginForm = (
    <Form {...defaultFormProps.attributes}>
      {submitErrors.length > 0 && (
        <FormAlert>
          <Alert
            key="login-failed"
            ouiaId="login-alert"
            variant="danger"
            title={submitErrors}
            aria-live="polite"
            isInline
          />
        </FormAlert>
      )}
      {alertArr.length !== 0 &&
        alertArr.map((alert, index) => (
          <Alert
            key={index}
            variant={alert.type}
            title={alert.message}
            ouiaId="login-alert"
            actionClose={
              <AlertActionCloseButton
                ouiaId="login-alert-close-button"
                onClose={() => closeAlert(index)}
              />
            }
          />
        ))}
      <FormGroup isRequired fieldId="username">
        <TextInput
          ouiaId="login-username"
          isRequired
          type="text"
          value={username}
          autoComplete="username"
          onChange={handleUsernameChange}
          {...defaultFormProps.usernameField}
        />
      </FormGroup>
      <FormGroup isRequired fieldId="password">
        <TextInput
          ouiaId="login-password"
          isRequired
          type="password"
          value={password}
          autoComplete="current-password"
          onChange={handlePasswordChange}
          {...defaultFormProps.passwordField}
        />
      </FormGroup>
      <input name="authenticity_token" type="hidden" value={token} />
      <ActionGroup>
        <Button
          ouiaId="login-submit"
          type="submit"
          isBlock
          variant="primary"
          isDisabled={isLoginDisabled}
          isLoading={isLoading}
          onClick={handleSubmit}
        >
          {defaultFormProps.submitText}
        </Button>
      </ActionGroup>
    </Form>
  );

  const oidcLogin = oidcProviders.length > 0 && (
    <>
      <hr />
      {oidcProviders.map(provider => (
        <form
          className="external-login-form"
          key={provider.url}
          action={provider.url}
          method="post"
        >
          <input name="authenticity_token" type="hidden" value={token} />
          <Button
            ouiaId={`external-login-${provider.name}`}
            type="submit"
            isBlock
            variant="secondary"
          >
            {sprintf(__('Log in with %s'), provider.name)}
          </Button>
        </form>
      ))}
    </>
  );

  return (
    <div id="login-page">
      <PF5LoginPage
        className="login-pf"
        brandImgSrc={logoSrc}
        loginTitle={__('Welcome')}
        loginSubtitle={__('Log in to your account')}
        textContent={caption}
      >
        {loginForm}
        {oidcLogin}
      </PF5LoginPage>
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
  oidcProviders: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string.isRequired,
      url: PropTypes.string.isRequired,
    })
  ),
  token: PropTypes.string.isRequired,
};

LoginPage.defaultProps = {
  alerts: null,
  backgroundUrl: null,
  caption: null,
  logoSrc: null,
  oidcProviders: [],
};

export default LoginPage;
