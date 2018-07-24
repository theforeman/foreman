import React from 'react';
import { Col } from 'patternfly-react';
import ShowTaxonomyInline from './ShowTaxonomyInline';

const ShowOrgsLocs = ({
  isOrgEnabled = false,
  isLocEnabled = false,
  orgs = [],
  locs = [],
}) => (
  <Col sm={10} className='taxonomy-section'>
    { isOrgEnabled &&
        <ShowTaxonomyInline displayLabel={__('Affected Organizations')} items={orgs}></ShowTaxonomyInline>
    }
    { isLocEnabled &&
        <ShowTaxonomyInline displayLabel={__('Affected Locations')} items={locs}></ShowTaxonomyInline>
    }
  </Col>
);

ShowOrgsLocs.defaultProps = {
  isOrgEnabled: false,
  isLocEnabled: false,
};

export default ShowOrgsLocs;
