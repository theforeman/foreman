import React from 'react';
import PropTypes from 'prop-types';
import { Button, Grid } from 'patternfly-react';
import { translate as __ } from '../../common/I18n';
import './externalLogout.scss';

const ExternalLogout = ({
  logoSrc,
  version,
  caption,
  submitLink,
  backgroundUrl,
}) => {
  const style = backgroundUrl
    ? { backgroundImage: `url(${backgroundUrl})` }
    : {};
  return (
    <div className="external-logout" style={style}>
      <Grid>
        <Grid.Row>
          <Grid.Col sm={8} smOffset={2} md={6} mdOffset={3}>
            <header className="login-pf-page-header">
              <img className="brand" src={logoSrc} alt="logo" />
              <div className="login-pf-caption">
                <h1 id="title">{__('Welcome')}</h1>
                {caption && <p id="login_text">{caption}</p>}
              </div>
            </header>
            <Button
              type="submit"
              bsStyle="primary"
              bsSize="large"
              block
              className="login-pf-submit-button"
              href={submitLink}
            >
              {__('Click to log in again')}
            </Button>
          </Grid.Col>
        </Grid.Row>
      </Grid>
    </div>
  );
};

ExternalLogout.propTypes = {
  backgroundUrl: PropTypes.string,
  caption: PropTypes.string,
  logoSrc: PropTypes.string,
  version: PropTypes.string,
  submitLink: PropTypes.string.isRequired,
};

ExternalLogout.defaultProps = {
  backgroundUrl: null,
  caption: null,
  logoSrc: null,
  version: null,
};

export default ExternalLogout;
