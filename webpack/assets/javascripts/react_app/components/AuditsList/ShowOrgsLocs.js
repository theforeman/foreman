import React from 'react';
import PropTypes from 'prop-types';
import { Col } from 'patternfly-react';
import ShowTaxonomyInline from './ShowTaxonomyInline';
import { translate as __ } from '../../common/I18n';

const ShowOrgsLocs = ({
  isOrgEnabled, isLocEnabled, orgs, locs,
}) => (
  <Col sm={10} className="taxonomy-section">
    {isOrgEnabled && (
      <ShowTaxonomyInline
        displayLabel={__('Affected Organizations')}
        items={orgs}
      />
    )}
    {isLocEnabled && (
      <ShowTaxonomyInline
        displayLabel={__('Affected Locations')}
        items={locs}
      />
    )}
  </Col>
);

ShowOrgsLocs.propTypes = {
  isOrgEnabled: PropTypes.bool,
  isLocEnabled: PropTypes.bool,
  orgs: PropTypes.array,
  locs: PropTypes.array,
};

ShowOrgsLocs.defaultProps = {
  isOrgEnabled: false,
  isLocEnabled: false,
  orgs: [],
  locs: [],
};

export default ShowOrgsLocs;
