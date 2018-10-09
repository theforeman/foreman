import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'patternfly-react';

const ShowTaxonomyInline = ({ displayLabel, items }) => {
  const listItems = items.map(
    ({ name, url, disabled, css_class: addCSS }, index) => (
      <a
        href={url}
        key={index}
        className={`apply-comma ${addCSS || ''}`}
        disabled={disabled}
      >
        {name}
      </a>
    )
  );

  return (
    <Row>
      <Col md={2}>
        <span>{displayLabel}</span>
      </Col>
      <Col md={10}>
        <strong>{items && listItems}</strong>
      </Col>
    </Row>
  );
};

ShowTaxonomyInline.propTypes = {
  displayLabel: PropTypes.string,
  items: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string,
      url: PropTypes.string,
      css_class: PropTypes.string,
      disabled: PropTypes.bool,
    })
  ),
};

ShowTaxonomyInline.defaultProps = {
  displayLabel: '',
  items: [],
};

export default ShowTaxonomyInline;
