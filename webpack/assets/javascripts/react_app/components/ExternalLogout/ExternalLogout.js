import React from 'react';
import PropTypes from 'prop-types';
import { Button, Grid, GridItem } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import './externalLogout.scss';

const ExternalLogout = ({ logoSrc, caption, submitLink, backgroundUrl }) => {
  const style = backgroundUrl
    ? { backgroundImage: `url(${backgroundUrl})` }
    : {};
  return (
    <div className="external-logout" style={style}>
      <Grid>
        <GridItem span={12} sm={8} smOffset={2} md={6} mdOffset={3}>
          <header className="login-pf-page-header">
            <img className="brand" src={logoSrc} alt="logo" />
            <div className="login-pf-caption">
              <h1 id="title">{__('Welcome')}</h1>
              {caption && <p id="login_text">{caption}</p>}
            </div>
          </header>
          <Button
            ouiaId="login-pf-submit-button"
            type="submit"
            variant="primary"
            size="lg"
            isBlock
            className="login-pf-submit-button"
            href={submitLink}
            component="a"
          >
            {__('Click to log in again')}
          </Button>
        </GridItem>
      </Grid>
    </div>
  );
};

ExternalLogout.propTypes = {
  backgroundUrl: PropTypes.string,
  caption: PropTypes.string,
  logoSrc: PropTypes.string,
  submitLink: PropTypes.string.isRequired,
};

ExternalLogout.defaultProps = {
  backgroundUrl: null,
  caption: null,
  logoSrc: null,
};

export default ExternalLogout;
