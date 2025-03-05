import React from 'react';
import { Select, SelectVariant } from '@patternfly/react-core/deprecated';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';

const HostGroupSelect = ({
  headerText,
  children,
  onClear,
  ...pfSelectProps
}) => (
  <div style={{ marginTop: '1em' }}>
    <h3>{headerText}</h3>
    <Select
      variant={SelectVariant.typeahead}
      onClear={onClear}
      maxHeight="20rem"
      menuAppendTo="parent"
      ouiaId="select-host-group"
      id="selectHostGroup"
      name="selectHostGroup"
      aria-label="selectHostGroup"
      {...pfSelectProps}
    >
      {children}
    </Select>
  </div>
);

HostGroupSelect.propTypes = {
  headerText: PropTypes.string,
  onClear: PropTypes.func.isRequired,
  children: PropTypes.node,
};

HostGroupSelect.defaultProps = {
  headerText: __('Select host group'),
  children: [],
};

export default HostGroupSelect;
