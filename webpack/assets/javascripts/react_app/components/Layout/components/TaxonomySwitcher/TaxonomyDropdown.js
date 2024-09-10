import React, { useState, useEffect, useCallback } from 'react';
import PropTypes from 'prop-types';
import { Button, Grid, GridItem, Icon } from '@patternfly/react-core';
import {
  ContextSelector,
  ContextSelectorItem,
  ContextSelectorFooter,
} from '@patternfly/react-core/deprecated';
import { CheckIcon, GlobeIcon, BuildingIcon } from '@patternfly/react-icons';
import { foremanUrl } from '../../../../common/helpers';
import { translate as __ } from '../../../../common/I18n';
import './TaxonomyDropdown.scss';

const TaxonomyDropdown = ({ taxonomyType, currentTaxonomy, taxonomies }) => {
  const id = `${taxonomyType}-dropdown`;
  const anyTaxonomyURL = foremanUrl(`/${taxonomyType}s/clear`);
  const manageTaxonomyURL = foremanUrl(`/${taxonomyType}s`);
  const anyTaxonomyText =
    taxonomyType === 'organization'
      ? __('Any organization')
      : __('Any location');

  const [searchValue, setSearchValue] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [filteredItems, setFilteredItems] = useState(taxonomies);

  const onSearchButtonClick = useCallback(() => {
    const filtered =
      searchValue === ''
        ? taxonomies
        : taxonomies.filter(item =>
            item.title.toLowerCase().includes(searchValue.toLowerCase())
          );
    setFilteredItems(filtered || []);
  }, [searchValue, taxonomies]);

  useEffect(() => {
    onSearchButtonClick();
  }, [searchValue, onSearchButtonClick]);

  const onToggle = (event, newIsOpen) => {
    setIsOpen(newIsOpen);
  };
  const onSelect = () => {
    setIsOpen(!isOpen);
  };
  const onSearchInputChange = (value, event) => {
    setSearchValue(event.target.value);
  };

  const selectedIcon = (
    <Icon size="sm">
      <CheckIcon className="current-taxonomy-v" />
    </Icon>
  );
  const anyIcon =
    taxonomyType === 'organization' ? (
      <BuildingIcon style={{ marginRight: '5px', marginTop: '3px' }} />
    ) : (
      <GlobeIcon style={{ marginRight: '5px', marginTop: '3px' }} />
    );

  const anyTaxonomyItem = (
    <ContextSelectorItem
      key={0}
      className={`${taxonomyType}s_clear`}
      onClick={() => {
        window.location.assign(anyTaxonomyURL);
      }}
      isDisabled={!currentTaxonomy}
    >
      <Grid hasGutter>
        <GridItem span={1}>{anyIcon}</GridItem>
        <GridItem span={9} style={{ textAlign: 'left' }}>
          {anyTaxonomyText}
        </GridItem>
        <GridItem span={2}>{!currentTaxonomy && selectedIcon}</GridItem>
      </Grid>
    </ContextSelectorItem>
  );
  const footer = (
    <ContextSelectorFooter>
      <Button
        ouiaId={`manage-taxonomy-button-${taxonomyType}`}
        size="sm"
        component="a"
        className={taxonomyType}
        variant="secondary"
        href={manageTaxonomyURL}
      >
        {taxonomyType === 'organization'
          ? __('Manage Organizations')
          : __('Manage Locations')}
      </Button>
    </ContextSelectorFooter>
  );
  return (
    <ContextSelector
      ouiaId={`taxonomy-context-selector-${taxonomyType}`}
      id={id}
      toggleText={
        currentTaxonomy || (
          <>
            {anyIcon}
            {anyTaxonomyText}
          </>
        )
      }
      onSearchInputChange={onSearchInputChange}
      isOpen={isOpen}
      searchInputValue={searchValue}
      onToggle={onToggle}
      onSelect={onSelect}
      onSearchButtonClick={onSearchButtonClick}
      screenReaderLabel="Selected Taxonomy:"
      className="context-selector"
      footer={footer}
    >
      {anyTaxonomyItem}
      {filteredItems.map(({ title, href }, i) => (
        <ContextSelectorItem
          key={i + 1}
          id={`select_taxonomy_${title}`}
          className={`${taxonomyType}_menuitem`}
          onClick={() => {
            if (href) {
              window.location.assign(href);
            }
          }}
          isDisabled={title === currentTaxonomy}
        >
          <Grid hasGutter>
            <GridItem span={10} style={{ textAlign: 'left' }}>
              {title}
            </GridItem>
            <GridItem span={1}>
              {title === currentTaxonomy && selectedIcon}
            </GridItem>
          </Grid>
        </ContextSelectorItem>
      ))}
    </ContextSelector>
  );
};

TaxonomyDropdown.propTypes = {
  taxonomyType: PropTypes.oneOf(['organization', 'location']).isRequired,
  currentTaxonomy: PropTypes.string,
  taxonomies: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      title: PropTypes.string,
      href: PropTypes.string.isRequired,
    })
  ).isRequired,
};

TaxonomyDropdown.defaultProps = {
  currentTaxonomy: undefined,
};

export default TaxonomyDropdown;
