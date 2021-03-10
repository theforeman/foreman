import React from 'react';
import PropTypes from 'prop-types';
import { ToolbarItem, Spinner } from '@patternfly/react-core';
import {
  useForemanOrganization,
  useForemanLocation,
} from '../../../../Root/Context/ForemanContext';

import { locationPropType, organizationPropType } from '../../LayoutHelper';
import TaxonomyDropdown from './TaxonomyDropdown';

const TaxonomySwitcher = ({ organizations, locations, isLoading }) => {
  const currentLocation = useForemanLocation()?.title;
  const currentOrganization = useForemanOrganization()?.title;
  return (
    <React.Fragment>
      <ToolbarItem>
        <TaxonomyDropdown
          taxonomyType="organization"
          currentTaxonomy={currentOrganization}
          taxonomies={organizations}
        />
      </ToolbarItem>
      <ToolbarItem>
        <TaxonomyDropdown
          taxonomyType="location"
          currentTaxonomy={currentLocation}
          taxonomies={locations}
        />
      </ToolbarItem>
      {isLoading && <Spinner size="md" />}
    </React.Fragment>
  );
};
TaxonomySwitcher.propTypes = {
  isLoading: PropTypes.bool,
  organizations: PropTypes.arrayOf(organizationPropType).isRequired,
  locations: PropTypes.arrayOf(locationPropType).isRequired,
};

TaxonomySwitcher.defaultProps = {
  isLoading: false,
};

export default TaxonomySwitcher;
