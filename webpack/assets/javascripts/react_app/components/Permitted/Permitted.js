import React from 'react';
import PropTypes from 'prop-types';

import { useForemanPermissions } from '../../Root/Context/ForemanContext';
import PermissionDenied from '../PermissionDenied';

/**
 * Component to conditionally render a node if the current user has the requested permissions.
 * Multiple permissions may be required by passing an array via **requiredPermissions**.
 *
 * @param {array<string>} requiredPermissions: An array of permission string.
 * @param {node} children: The node to be conditionally rendered
 * @param {node} unpermittedComponent: Component to be rendered if the desired permission is not met. Defaults to null.
 */
const Permitted = ({ requiredPermissions, children, unpermittedComponent }) => {
  const userPermissions = useForemanPermissions();

  const isPermitted =
    requiredPermissions &&
    requiredPermissions.every(permission => userPermissions.has(permission));
  return (
    <>
      {' '}
      {isPermitted
        ? children
        : unpermittedComponent || (
            <PermissionDenied
              missingPermissions={
                typeof requiredPermissions === 'object'
                  ? requiredPermissions.filter(
                      rPerm => !userPermissions.has(rPerm)
                    )
                  : []
              }
            />
          )}{' '}
    </>
  );
};

const propsCheck = (props, propName, componentName) => {
  if (props.requiredPermissions === undefined) {
    return new Error(
      `The prop "requiredPermissions" must be set in ${componentName}.`
    );
  }

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

  return null;
};

/* eslint-disable react/require-default-props */
Permitted.propTypes = {
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
