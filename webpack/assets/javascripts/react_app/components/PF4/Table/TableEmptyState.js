import React from 'react';
import { Bullseye } from '@patternfly/react-core';
import {
  CubesIcon,
  ExclamationCircleIcon,
  SearchIcon,
} from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import { global_danger_color_200 as dangerColor } from '@patternfly/react-tokens';
import EmptyStatePattern from '../../common/EmptyState/EmptyStatePattern';

const TableEmptyStateIcon = (error = false, search = false) => {
  if (error) return { icon: ExclamationCircleIcon, color: dangerColor.value };
  if (search) return { icon: SearchIcon };
  return { icon: CubesIcon };
};

const TableEmptyState = ({ title, body, error, search }) => {
  const { icon, color } = TableEmptyStateIcon(!!error, search);

  return (
    <Bullseye>
      <EmptyStatePattern
        icon={icon}
        iconColor={color}
        header={title}
        description={body}
        documentation={null}
      />
    </Bullseye>
  );
};

TableEmptyStateIcon.propTypes = {
  error: PropTypes.bool,
  search: PropTypes.bool,
};

TableEmptyStateIcon.defaultProps = {
  error: false,
  search: false,
};

TableEmptyState.propTypes = {
  title: PropTypes.string,
  body: PropTypes.string,
  error: PropTypes.oneOfType([PropTypes.shape({}), PropTypes.string]),
  search: PropTypes.bool,
};

TableEmptyState.defaultProps = {
  title: 'Unable to connect',
  body:
    'There was an error retrieving data from the server. Check your connection and try again.',
  error: undefined,
  search: false,
};

export default TableEmptyState;
