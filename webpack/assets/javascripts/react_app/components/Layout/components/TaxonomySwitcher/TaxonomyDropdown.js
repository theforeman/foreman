import React, { useMemo, useRef, useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  Divider,
  Dropdown,
  DropdownItem,
  DropdownList,
  MenuFooter,
  MenuSearch,
  MenuSearchInput,
  MenuToggle,
  SearchInput,
} from '@patternfly/react-core';
import { GlobeIcon, BuildingIcon } from '@patternfly/react-icons';
import { foremanUrl } from '../../../../common/helpers';
import { translate as __ } from '../../../../common/I18n';
import './TaxonomyDropdown.scss';

const TaxonomyDropdown = ({ taxonomyType, currentTaxonomy, taxonomies }) => {
  const id = `${taxonomyType}-dropdown`;
  const anyTaxonomyURL = foremanUrl(`/${taxonomyType}s/clear`);
  const manageTaxonomyURL = foremanUrl(`/${taxonomyType}s`);
  const isOrganization = taxonomyType === 'organization';
  const anyTaxonomyText = isOrganization
    ? __('Any organization')
    : __('Any location');
  const anyIcon = isOrganization ? <BuildingIcon /> : <GlobeIcon />;

  const [searchValue, setSearchValue] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const searchInputRef = useRef(null);

  const filteredItems = useMemo(() => {
    const search = searchValue.toLowerCase();
    return search === ''
      ? taxonomies
      : taxonomies.filter(item => item.title.toLowerCase().includes(search));
  }, [searchValue, taxonomies]);

  return (
    <div id={id}>
      <Dropdown
        ouiaId={`taxonomy-context-selector-${taxonomyType}`}
        className="context-selector"
        isOpen={isOpen}
        onSelect={() => setIsOpen(false)}
        onOpenChange={newIsOpen => setIsOpen(newIsOpen)}
        // like the PF5 ContextSelector: focus the filter on open, and let Tab
        // move through filter, items and footer instead of closing the menu
        onOpenChangeKeys={['Escape']}
        popperProps={{
          appendTo: 'inline',
          onShown: () => searchInputRef.current?.focus(),
        }}
        toggle={toggleRef => (
          <MenuToggle
            ref={toggleRef}
            className="taxonomy-dropdown-toggle"
            icon={currentTaxonomy ? undefined : anyIcon}
            isExpanded={isOpen}
            onClick={() => setIsOpen(!isOpen)}
          >
            {currentTaxonomy || anyTaxonomyText}
          </MenuToggle>
        )}
      >
        <MenuSearch>
          <MenuSearchInput>
            <SearchInput
              ref={searchInputRef}
              value={searchValue}
              aria-label={__('Filter')}
              onChange={(_event, value) => setSearchValue(value)}
              onClear={() => setSearchValue('')}
            />
          </MenuSearchInput>
        </MenuSearch>
        <Divider />
        <DropdownList>
          <DropdownItem
            key="any-taxonomy"
            className={`${taxonomyType}s_clear`}
            icon={anyIcon}
            isSelected={!currentTaxonomy}
            isDisabled={!currentTaxonomy}
            onClick={() => window.location.assign(anyTaxonomyURL)}
          >
            {anyTaxonomyText}
          </DropdownItem>
          {filteredItems.map(({ title, href }) => (
            <DropdownItem
              key={href}
              id={`select_taxonomy_${title}`}
              className={`${taxonomyType}_menuitem`}
              isSelected={title === currentTaxonomy}
              isDisabled={title === currentTaxonomy}
              onClick={() => {
                if (href) {
                  window.location.assign(href);
                }
              }}
            >
              {title}
            </DropdownItem>
          ))}
        </DropdownList>
        <MenuFooter>
          <Button
            ouiaId={`manage-taxonomy-button-${taxonomyType}`}
            size="sm"
            component="a"
            className={taxonomyType}
            variant="secondary"
            href={manageTaxonomyURL}
          >
            {isOrganization
              ? __('Manage Organizations')
              : __('Manage Locations')}
          </Button>
        </MenuFooter>
      </Dropdown>
    </div>
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
