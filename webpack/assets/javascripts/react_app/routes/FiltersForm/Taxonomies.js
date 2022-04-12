import React from 'react';
import PropTypes from 'prop-types';
import { FormGroup } from '@patternfly/react-core';
import { DualListWithIds } from '../../components/common/Pf4DualList/DualListWithIds';
import { translate as __ } from '../../common/I18n';

export const Taxonomies = ({
  showOrgs,
  showLocations,
  setChosenOrgs,
  setChosenLocations,
  defaultOrgs,
  defaultLocations,
}) => (
  <>
    {showOrgs && (
      <FormGroup label={__('Organizations')}>
        <DualListWithIds
          url="/api/v2/organizations?per_page=all"
          defaultValue={defaultOrgs}
          setChosenIds={setChosenOrgs}
          id="organizations-duel-select"
        />
      </FormGroup>
    )}
    {showLocations && (
      <FormGroup label={__('Locations')}>
        <DualListWithIds
          url="/api/v2/locations?per_page=all"
          defaultValue={defaultLocations}
          setChosenIds={setChosenLocations}
          id="locations-duel-select"
        />
      </FormGroup>
    )}
  </>
);
Taxonomies.propTypes = {
  showOrgs: PropTypes.bool.isRequired,
  showLocations: PropTypes.bool.isRequired,
  setChosenOrgs: PropTypes.func.isRequired,
  setChosenLocations: PropTypes.func.isRequired,
  defaultOrgs: PropTypes.array,
  defaultLocations: PropTypes.array,
};
Taxonomies.defaultProps = {
  defaultOrgs: [],
  defaultLocations: [],
};
