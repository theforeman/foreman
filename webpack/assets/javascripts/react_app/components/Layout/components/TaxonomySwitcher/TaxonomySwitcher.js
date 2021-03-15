import React from 'react';
import PropTypes from 'prop-types';
import { ToolbarItem, Spinner } from '@patternfly/react-core';
import { noop } from '../../../../common/helpers';
import {
  useForemanOrganization,
  useForemanLocation,
} from '../../../../Root/Context/ForemanContext';

import { locationPropType, organizationPropType } from '../../LayoutHelper';
import TaxonomyDropdown from './TaxonomyDropdown';

const TaxonomySwitcher = ({
  organizations,
  locations,
  isLoading,
  onLocationClick,
  onOrgClick,
}) => {
  const currentLocation = useForemanLocation()?.title;
  const currentOrganization = useForemanOrganization()?.title;
  return (
    <React.Fragment>
      <ToolbarItem>
        <TaxonomyDropdown
          taxonomyType="organization"
          currentTaxonomy={currentOrganization}
          taxonomies={organizations}
          changeTaxonomy={onOrgClick}
        />
      </ToolbarItem>
      <ToolbarItem>
        <TaxonomyDropdown
          taxonomyType="location"
          currentTaxonomy={currentLocation}
          taxonomies={locations}
          changeTaxonomy={onLocationClick}
        />
      </ToolbarItem>
      {isLoading && <Spinner size="md" />}
    </React.Fragment>
  );
};
TaxonomySwitcher.propTypes = {
  onLocationClick: PropTypes.func,
  onOrgClick: PropTypes.func,
  isLoading: PropTypes.bool,
  organizations: PropTypes.arrayOf(organizationPropType).isRequired,
  locations: PropTypes.arrayOf(locationPropType).isRequired,
};

TaxonomySwitcher.defaultProps = {
  isLoading: false,
  onLocationClick: noop,
  onOrgClick: noop,
};

export default TaxonomySwitcher;
