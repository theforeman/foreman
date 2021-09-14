import React from 'react';
import PropTypes from 'prop-types';
import { Redirect } from 'react-router-dom';
import { useForemanSettings } from '../../Root/Context/ForemanContext';
import {
  EXPERIMENTAL_HOST_DETAILS,
  LEGACY_DETAILS_PATH,
  TAB_PREFIX,
} from './consts';
import { visit } from '../../../foreman_navigation';
import { foremanUrl } from '../../common/helpers';

const HostUISwitcher = props => {
  const { hostDetailsUI } = useForemanSettings();
  const {
    match: {
      params: { id },
    },
    location: { hash },
  } = props;

  if (hash.startsWith(TAB_PREFIX))
    return <Redirect to={`${EXPERIMENTAL_HOST_DETAILS}/${id}`} />;
  if (hostDetailsUI)
    return <Redirect to={`${EXPERIMENTAL_HOST_DETAILS}/${id}`} />;

  visit(foremanUrl(`${LEGACY_DETAILS_PATH}/${id}${hash}`));
  return null;
};

HostUISwitcher.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string,
    }),
  }).isRequired,
  location: PropTypes.object.isRequired,
};

export default HostUISwitcher;
