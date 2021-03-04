import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  FormSelect,
  FormSelectOption,
} from '@patternfly/react-core';

import { translate as __ } from '../../../../../common/I18n';
import { emptyOption } from '../../RegistrationCommandsPageHelpers';

const HostGroup = ({ hostGroupId, hostGroups, handleHostGroup, isLoading }) => (
  <FormGroup label={__('Host Group')} fieldId="reg_host_group">
    <FormSelect
      value={hostGroupId}
      onChange={v => handleHostGroup(v)}
      className="without_select2"
      id="reg_host_group_select"
      isDisabled={isLoading || hostGroups.length === 0}
    >
      {emptyOption(hostGroups.length)}
      {hostGroups.map((hg, i) => (
        <FormSelectOption key={i} value={hg.id} label={hg.name} />
      ))}
    </FormSelect>
  </FormGroup>
);

HostGroup.propTypes = {
  hostGroupId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  handleHostGroup: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  hostGroups: PropTypes.array,
};

HostGroup.defaultProps = {
  hostGroupId: '',
  hostGroups: [],
};

export default HostGroup;
