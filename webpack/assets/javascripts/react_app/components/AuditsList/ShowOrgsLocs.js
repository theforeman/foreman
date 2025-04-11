import React from 'react';
import PropTypes from 'prop-types';
import { GridItem } from '@patternfly/react-core';
import ShowTaxonomyInline from './ShowTaxonomyInline';
import { translate as __ } from '../../common/I18n';

const ShowOrgsLocs = ({ orgs, locs }) => (
  <GridItem span={12} className="taxonomy-section">
    <ShowTaxonomyInline
      displayLabel={__('Affected Organizations')}
      items={orgs}
    />
    <ShowTaxonomyInline displayLabel={__('Affected Locations')} items={locs} />
  </GridItem>
);

ShowOrgsLocs.propTypes = {
  orgs: PropTypes.array,
  locs: PropTypes.array,
};

ShowOrgsLocs.defaultProps = {
  orgs: [],
  locs: [],
};

export default ShowOrgsLocs;
