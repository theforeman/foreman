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
  <FormGroup label={__('Host group')} fieldId="reg_host_group">
    <FormSelect
      ouiaId="reg_host_group"
      value={hostGroupId}
      onChange={(_event, v) => handleHostGroup(v)}
      className="without_select2"
      id="reg_host_group"
      isDisabled={isLoading || hostGroups.length === 0}
    >
      {emptyOption(hostGroups.length)}
      {hostGroups.map((hg, i) => (
        <FormSelectOption key={i} value={hg.id} label={hg.title} />
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
