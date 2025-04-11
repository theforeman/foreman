import React from 'react';
import PropTypes from 'prop-types';
import { Grid, GridItem, Button } from '@patternfly/react-core';

const ShowTaxonomyInline = ({ displayLabel, items }) => {
  const listItems = items.map(
    ({ name, url, disabled, css_class: addCSS }, index) => (
      <Button
        ouiaId="taxonomy-inline-btn"
        variant="link"
        isInline
        isDisabled={disabled}
        component="a"
        href={url}
        key={index}
        className={`apply-comma ${addCSS || ''}`}
      >
        {name}
      </Button>
    )
  );

  return (
    <Grid>
      <GridItem span={3}>
        <span>{displayLabel}</span>
      </GridItem>
      <GridItem span={9}>
        <strong>{items && listItems}</strong>
      </GridItem>
    </Grid>
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
