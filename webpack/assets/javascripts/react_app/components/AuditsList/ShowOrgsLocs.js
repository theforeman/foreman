import React from 'react';
import PropTypes from 'prop-types';
import { Col } from 'patternfly-react';
import ShowTaxonomyInline from './ShowTaxonomyInline';
import { translate as __ } from '../../common/I18n';

const ShowOrgsLocs = ({ orgs, locs }) => (
  <Col sm={10} className="taxonomy-section">
    <ShowTaxonomyInline
      displayLabel={__('Affected Organizations')}
      items={orgs}
    />
    <ShowTaxonomyInline displayLabel={__('Affected Locations')} items={locs} />
  </Col>
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
