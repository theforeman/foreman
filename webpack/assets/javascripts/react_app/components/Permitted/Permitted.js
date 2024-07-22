import React from 'react';
import PropTypes from 'prop-types';

import { useForemanPermissions } from '../../Root/Context/ForemanContext';

/**
 * Component to conditionally render a node if the current user has the requested permissions.
 * Multiple permissions may be required by passing an array via **requiredPermissions**.
 *
 * Supply **requiredPermission** XOR **requiredPermissions**
 * @param {string} requiredPermission: A single string representing a required permission
 * @param {array<string>} requiredPermissions: An array of permission string.
 * @param {node} children: The node to be conditionally rendered
 * @param {node} unpermittedComponent: Component to be rendered if the desired permission is not met. Defaults to null.
 */
const Permitted = ({
  requiredPermission,
  requiredPermissions,
  children,
  unpermittedComponent,
}) => {
  const userPermissions = useForemanPermissions();

  const isPermitted =
    (requiredPermissions &&
      requiredPermissions.every(permission =>
        userPermissions.has(permission)
      )) ||
    (userPermissions && userPermissions.has(requiredPermission));
  return <> {isPermitted ? children : unpermittedComponent} </>;
};

const propsCheck = (props, propName, componentName) => {
  if (
    props.requiredPermission === undefined &&
    props.requiredPermissions === undefined
  ) {
    return new Error(
      `One of the props [requiredPermission, requiredPermissions] must be set in ${componentName}.`
    );
  }

  if (propName === 'requiredPermission') {
    if (props.requiredPermission !== undefined) {
      PropTypes.checkPropTypes(
        {
          requiredPermission: PropTypes.string,
        },
        { requiredPermission: props.requiredPermission },
        'prop',
        'Permitted'
      );
      if (
        typeof props.requiredPermission === 'string' &&
        props.requiredPermission === ''
      ) {
        return new Error('requiredPermission can not be an empty string.');
      }
    }
  } else if (propName === 'requiredPermissions') {
    if (props.requiredPermissions !== undefined) {
      PropTypes.checkPropTypes(
        {
          requiredPermissions: PropTypes.array,
        },
        { requiredPermissions: props.requiredPermissions },
        'prop',
        'Permitted'
      );
      if (
        typeof props.requiredPermissions === 'object' &&
        props.requiredPermissions.length === 0
      ) {
        return new Error('requiredPermissions can not be an empty array.');
      }
    }
  }
  return null;
};

/* eslint-disable react/require-default-props */
Permitted.propTypes = {
  requiredPermission: propsCheck,
  requiredPermissions: propsCheck,
  children: PropTypes.node,
  unpermittedComponent: PropTypes.node,
};
/* eslint-enable react/require-default-props */
Permitted.defaultProps = {
  children: null,
  unpermittedComponent: null,
};

export default Permitted;
