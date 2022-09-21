import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { FormGroup } from '@patternfly/react-core';
import { DualListWithIds } from '../../components/common/Pf4DualList/DualListWithIds';
import { translate as __ } from '../../common/I18n';
import { EMPTY_RESOURCE_TYPE } from './FiltersFormConstants';

export const SelectPermissions = ({
  resourceType,
  defaultPermissions,
  setChosenPermissions,
}) => {
  const url = useMemo(() => {
    if (resourceType.name === EMPTY_RESOURCE_TYPE.name) {
      return '/api/v2/permissions?per_page=all&search=null?%20resource_type';
    }
    return `/api/v2/permissions?per_page=all&search=resource_type=${resourceType.name}`;
  }, [resourceType.name]);
  return (
    <FormGroup label={__('Permission')} isRequired>
      <DualListWithIds
        url={url}
        defaultValue={defaultPermissions}
        setChosenIds={setChosenPermissions}
        id="permission-duel-select"
      />
    </FormGroup>
  );
};

SelectPermissions.propTypes = {
  setChosenPermissions: PropTypes.func.isRequired,
  defaultPermissions: PropTypes.array,
  resourceType: PropTypes.shape({
    name: PropTypes.string,
    translation: PropTypes.string,
    granular: PropTypes.bool,
    search_path: PropTypes.string,
  }).isRequired,
};

SelectPermissions.defaultProps = {
  defaultPermissions: [],
};
