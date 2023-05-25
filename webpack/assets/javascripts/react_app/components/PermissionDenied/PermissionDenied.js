import React from 'react';
import { Button, Icon } from 'patternfly-react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../common/I18n';

/**
 * A component that explains to the user about the permissions needed to perform an operation.
 * @param {Object} props - The props object.
 * @param {string[]} [props.missingPermissions=['unknown']] - An array of strings representing the missing permissions.
 * @param {Object} [props.texts={}] - An object containing text strings for the component.
 * @param {string} [props.texts.notAuthorizedMsg='You are not authorized to perform this action.'] - The message to display when the user is not authorized to perform the action.
 * @param {string} [props.texts.permissionDeniedMsg='Permission denied'] - The message to display when the user does not have the required permissions.
 * @param {string} [props.texts.pleaseRequestMsg='Please request one of the required permissions listed below from a Foreman administrator:'] - The message to display instructing the user to request the required permissions.
 * @param {string} [props.backHref='/'] - The URL to navigate to when the user clicks the back button.
 * @returns {ReactNode} The rendered `PermissionDenied` component.
 */

const PermissionDenied = ({ missingPermissions, texts, backHref }) => {
  const { notAuthorizedMsg, permissionDeniedMsg, pleaseRequestMsg } = texts;
  return (
    <div className="blank-slate-pf">
      <div className="blank-slate-pf-icon">
        <Icon name="lock" color="#9c9c9c" size="2x" title="lock" />
      </div>
      {notAuthorizedMsg}

      <h1>{permissionDeniedMsg}</h1>
      <p>
        {notAuthorizedMsg}
        <br />
        {pleaseRequestMsg}
        <br />
      </p>
      <ul className="list-unstyled">
        {missingPermissions.map(permission => (
          <li key={permission}>
            <strong>{permission}</strong>
          </li>
        ))}
      </ul>
      <p>
        <a href={backHref}>
          <Button ouiaId="back-button">{__('Back')}</Button>
        </a>
      </p>
    </div>
  );
};

PermissionDenied.propTypes = {
  missingPermissions: PropTypes.node,
  texts: PropTypes.shape({
    notAuthorizedMsg: PropTypes.string,
    permissionDeniedMsg: PropTypes.string,
    pleaseRequestMsg: PropTypes.string,
  }),
  backHref: PropTypes.string,
};

PermissionDenied.defaultProps = {
  missingPermissions: ['unknown'],
  texts: {
    notAuthorizedMsg: __('You are not authorized to perform this action.'),
    permissionDeniedMsg: __('Permission denied'),
    pleaseRequestMsg: __(
      'Please request one of the required permissions listed below from a Foreman administrator:'
    ),
  },
  backHref: '/',
};

export default PermissionDenied;
