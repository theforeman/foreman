import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';
import ReactMarkdown from 'react-markdown'

const LoginPageCaption = ({ version, caption }) => (
  <Fragment>
    <h1 id="title">{__('Welcome')}</h1>
    {version && <p id="version">{`${__('Version')} ${version}`}</p>}
    {caption && <p id="login_text"><ReactMarkdown source={caption} /></p>}
  </Fragment>
);

LoginPageCaption.propTypes = {
  caption: PropTypes.string,
  version: PropTypes.string,
};

LoginPageCaption.defaultProps = {
  caption: null,
  version: null,
};

export default LoginPageCaption;
