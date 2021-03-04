/* eslint-disable camelcase */

import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';

import {
  FormGroup,
  FormSelect,
  FormSelectOption,
} from '@patternfly/react-core';

import LabelIcon from '../../../../../components/common/LabelIcon';

import { translate as __ } from '../../../../../common/I18n';

import { operatingSystemTemplateAction } from '../../RegistrationCommandsPageActions';
import {
  osHelperText,
  validatedOS,
  emptyOption,
  formatOSname,
} from '../../RegistrationCommandsPageHelpers';

const OperatingSystem = ({
  operatingSystemId,
  operatingSystems,
  operatingSystemTemplate,
  handleOperatingSystem,
  handleInvalidField,
  hostGroupId,
  hostGroups,
  isLoading,
}) => {
  const dispatch = useDispatch();

  // Get info about host-init-config template
  useEffect(() => {
    if (operatingSystemId) {
      dispatch(operatingSystemTemplateAction(operatingSystemId));
    }
  }, [dispatch, operatingSystemId]);

  // Handle hostGroupId change: reset selected OS & get info about host-init-config-template
  useEffect(() => {
    if (hostGroupId !== undefined) {
      const hostGroupOsId = hostGroups.find(
        hg => `${hg.id}` === `${hostGroupId}`
      )?.operatingsystem_id;

      handleOperatingSystem('');
      dispatch(operatingSystemTemplateAction(hostGroupOsId));
    }
  }, [dispatch, hostGroupId, hostGroups, handleOperatingSystem]);

  // Validate field
  useEffect(() => {
    if (operatingSystemId === '') {
      handleInvalidField('Operating System', true);
      return;
    }
    if (Object.entries(operatingSystemTemplate).length !== 0) {
      handleInvalidField('Operating System', !!operatingSystemTemplate?.name);
    }
  }, [operatingSystemId, operatingSystemTemplate]);

  return (
    <FormGroup
      label={__('Operating System')}
      helperText={osHelperText(
        operatingSystemId,
        operatingSystems,
        hostGroupId,
        hostGroups,
        operatingSystemTemplate
      )}
      labelIcon={
        <LabelIcon
          text={__(
            'Required for registration without subscription manager. Can be specified by Host Group.'
          )}
        />
      }
      fieldId="reg_os"
    >
      <FormSelect
        value={operatingSystemId}
        onChange={v => handleOperatingSystem(v)}
        className="without_select2"
        id="reg_os_select"
        validated={validatedOS(operatingSystemId, operatingSystemTemplate)}
        isDisabled={isLoading || operatingSystems.length === 0}
      >
        {emptyOption(operatingSystems.length)}
        {operatingSystems.map((os, i) => (
          <FormSelectOption key={i} value={os.id} label={formatOSname(os)} />
        ))}
      </FormSelect>
    </FormGroup>
  );
};

OperatingSystem.propTypes = {
  operatingSystemId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  hostGroupId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  handleOperatingSystem: PropTypes.func.isRequired,
  handleInvalidField: PropTypes.func.isRequired,
  isLoading: PropTypes.bool.isRequired,
  operatingSystems: PropTypes.array,
  hostGroups: PropTypes.array,
  operatingSystemTemplate: PropTypes.oneOfType([
    PropTypes.object,
    PropTypes.string,
  ]),
};

OperatingSystem.defaultProps = {
  operatingSystemId: undefined,
  hostGroupId: undefined,
  operatingSystems: [],
  hostGroups: [],
  operatingSystemTemplate: {},
};

export default OperatingSystem;
