import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import PersonalAccessToken from './PersonalAccessToken';
import { translate as __ } from '../../../../common/I18n';
import { noop } from '../../../../common/helpers';

const PersonalAccessTokensList = ({
  title,
  tokens,
  deletable,
  deletePersonalAccessToken,
  revocable,
  revokePersonalAccessToken,
}) => (
  <Fragment>
    <h3>{`${title} (${tokens.length})`}</h3>
    {tokens.length > 0 && (
      <table className="table table-bordered table-striped table-hover table-fixed">
        <thead>
          <tr>
            <th>{__('Name')}</th>
            <th>{__('Created')}</th>
            <th>{revocable ? __('Expires') : __('Expired')}</th>
            <th>{__('Last Used')}</th>
            <th>{__('Actions')}</th>
          </tr>
        </thead>
        <tbody>
          {tokens.map(token => (
            <PersonalAccessToken
              key={token.id}
              {...token}
              deletable={deletable}
              deletePersonalAccessToken={deletePersonalAccessToken}
              revokePersonalAccessToken={revokePersonalAccessToken}
            />
          ))}
        </tbody>
      </table>
    )}
  </Fragment>
);

PersonalAccessTokensList.propTypes = {
  tokens: PropTypes.array.isRequired,
  title: PropTypes.string,
  deletePersonalAccessToken: PropTypes.func,
  revokePersonalAccessToken: PropTypes.func,
  deletable: PropTypes.bool,
  revocable: PropTypes.bool,
};

PersonalAccessTokensList.defaultProps = {
  deletePersonalAccessToken: noop,
  revokePersonalAccessToken: noop,
  title: __('Personal Access Tokens'),
  deletable: false,
  revocable: false,
};

export default PersonalAccessTokensList;
