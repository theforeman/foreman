import React from 'react';
import { Grid, Alert, LoadingState } from 'patternfly-react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../common/I18n';
import { STATUS } from '../../../constants';
import CopyToClipboard from '../../common/CopyToClipboard/CopyToClipboard';

const UserJwtField = ({ apiStatus, token }) => {
  if (apiStatus === STATUS.ERROR) {
    return (
      <Grid.Row>
        <Grid.Col md={12}>
          <Alert>
            {__(
              'There was an error while creating the JWT token, try refreshing the page.'
            )}
          </Alert>
        </Grid.Col>
      </Grid.Row>
    );
  }

  return (
    <LoadingState loading={apiStatus === STATUS.PENDING}>
      {token && (
        <React.Fragment>
          <Grid.Row>
            <Grid.Col md={12}>
              <div className="user-jwt-field">
                <p>
                  {__(
                    'Following JWT can be used for the API authorization, like this:'
                  )}
                  <br />
                  <code>
                    curl -X GET &apos;
                    {`${window.location.hostname}/api/v2/hosts`}
                    &apos;
                    -H&nbsp;&apos;Authorization:&nbsp;Bearer&nbsp;your-token&apos;
                  </code>
                </p>
              </div>
            </Grid.Col>
          </Grid.Row>
          <Grid.Row>
            <Grid.Col md={4}>
              <strong>{__('Generated token:')}</strong>
              <CopyToClipboard valueToCopy={token} />
            </Grid.Col>
          </Grid.Row>
        </React.Fragment>
      )}
    </LoadingState>
  );
};

UserJwtField.propTypes = {
  apiStatus: PropTypes.string,
  token: PropTypes.string,
};

UserJwtField.defaultProps = {
  apiStatus: null,
  token: null,
};

export default UserJwtField;
