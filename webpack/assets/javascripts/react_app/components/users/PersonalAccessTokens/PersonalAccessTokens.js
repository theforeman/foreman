import React, { Fragment, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Icon } from 'patternfly-react';
import PropTypes from 'prop-types';
import {
  clearNewPersonalAccessToken,
  getPersonalAccessTokens,
  revokePersonalAccessToken as revokePersonalAccessTokenAction,
} from './PersonalAccessTokensActions';
import {
  selectNewPersonalAccessToken,
  selectTokens,
} from './PersonalAccessTokensSelectors';
import NewPersonalAccessToken from './NewPersonalAccessToken';
import PersonalAccessTokenForm from './PersonalAccessTokenForm';
import PersonalAccessTokensList from './PersonalAccessTokensList';
import { translate as __ } from '../../../common/I18n';
import { foremanUrl } from '../../../common/helpers';

const PersonalAccessTokens = ({ url, canCreate }) => {
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(getPersonalAccessTokens({ url }));
  }, [url, dispatch]);

  const newPersonalAccessToken = useSelector(state =>
    selectNewPersonalAccessToken(state)
  );
  const tokens = useSelector(state => selectTokens(state));

  const boundClearNewPersonalAccessToken = () =>
    dispatch(clearNewPersonalAccessToken());

  const boundRevokePersonalAccessToken = id =>
    dispatch(revokePersonalAccessTokenAction({ url, id }));

  return (
    <Fragment>
      <NewPersonalAccessToken
        newPersonalAccessToken={newPersonalAccessToken}
        onDismiss={boundClearNewPersonalAccessToken}
      />
      {tokens.length > 0 ? (
        <Fragment>
          {canCreate && <PersonalAccessTokenForm url={url} />}
          <PersonalAccessTokensList
            title={__('Active Personal Access Tokens')}
            tokens={tokens.filter(token => token['active?'])}
            revokePersonalAccessToken={boundRevokePersonalAccessToken}
            revocable
          />
          <PersonalAccessTokensList
            title={__('Inactive Personal Access Tokens')}
            tokens={tokens.filter(token => !token['active?'])}
          />
        </Fragment>
      ) : (
        <table className="table table-bordered table-striped table-hover table-fixed">
          <tbody>
            <tr>
              <td className="blank-slate-pf">
                <div className="blank-slate-pf-icon">
                  <Icon type="fa" name="key" color="#9c9c9c" />
                </div>
                <h1>{__('Personal Access Tokens')}</h1>
                {__(
                  'Personal Access Tokens allow you to authenticate API requests without using your password, e.g. '
                )}
                <p>
                  <code>{`curl -u admin:token ${foremanUrl(
                    '/api/v2/hosts'
                  )}`}</code>
                </p>
                {canCreate && <PersonalAccessTokenForm url={url} />}
              </td>
            </tr>
          </tbody>
        </table>
      )}
    </Fragment>
  );
};

PersonalAccessTokens.propTypes = {
  url: PropTypes.string.isRequired,
  canCreate: PropTypes.bool.isRequired,
};

export default PersonalAccessTokens;
