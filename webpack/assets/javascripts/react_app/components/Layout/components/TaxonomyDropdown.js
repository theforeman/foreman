import React from 'react';
import PropTypes from 'prop-types';
import { ContextSelectorItem } from '@patternfly/react-core';
import CustomContextSelector from './CustomContextSelector';
import { noop } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';

class TaxonomyDropdown extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      searchValue: '',
      isOpen: false,
      filteredItems: props.taxonomies,
    };
    this.allItems = props.taxonomies;
    this.onToggle = (event, isOpen) => {
      this.setState({
        isOpen,
      });
    };
    this.onSelect = (event, value) => {
      this.setState({
        isOpen: !this.state.isOpen,
      });
    };
    this.onSearchInputChange = (value, event) => {
      this.setState(
        { searchValue: event.target.value },
        this.onSearchButtonClick
      );
    };
    this.onSearchButtonClick = event => {
      const filtered =
        this.state.searchValue === ''
          ? this.allItems
          : this.allItems.filter(item =>
              item.title
                .toLowerCase()
                .includes(this.state.searchValue.toLowerCase())
            );

      this.setState({ filteredItems: filtered || [] });
    };
  }

  render() {
    const {
      taxonomyType,
      currentTaxonomy,
      taxonomies,
      changeTaxonomy,
      anyTaxonomyText,
      manageTaxonomyText,
      anyTaxonomyURL,
      manageTaxonomyURL,
      ...props
    } = this.props;

    const { isOpen, searchValue, filteredItems } = this.state;

    return (
      <CustomContextSelector
        toggleText={__(currentTaxonomy)}
        onSearchInputChange={this.onSearchInputChange}
        isOpen={isOpen}
        searchInputValue={searchValue}
        onToggle={this.onToggle}
        onSelect={this.onSelect}
        onSearchButtonClick={this.onSearchButtonClick}
        screenReaderLabel="Selected Taxonomy:"
        showFilter={taxonomies.length > 6}
        searchProps={{
          className: 'taxonomy_search',
          id: `search_taxonomy_${taxonomyType.toLowerCase()}`,
        }}
        staticGroup={{
          title: __(taxonomyType),
          items: [
            {
              title: __(anyTaxonomyText),
              href: anyTaxonomyURL,
              onClick: () => {
                changeTaxonomy({ title: anyTaxonomyText });
              },
              className: `${taxonomyType.toLowerCase()}s_clear`,
            },
            {
              title: __(manageTaxonomyText),
              href: manageTaxonomyURL,
              className: taxonomyType.toLowerCase(),
            },
          ],
        }}
        {...props}
      >
        {filteredItems.map((taxonomy, i) => (
          <ContextSelectorItem key={i}>
            <a
              id={`select_taxonomy_${taxonomy.title}`}
              className={`${taxonomyType.toLowerCase()}_menuitem`}
              href={taxonomy.href}
              onClick={() => {
                changeTaxonomy({ title: taxonomy.title, id: taxonomy.id });
              }}
              style={{ textDecoration: 'inherit', color: 'inherit' }}
            >
              {__(taxonomy.title)}
            </a>
          </ContextSelectorItem>
        ))}
      </CustomContextSelector>
    );
  }
}

TaxonomyDropdown.propTypes = {
  taxonomyType: PropTypes.string.isRequired,
  currentTaxonomy: PropTypes.string.isRequired,
  taxonomies: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      title: PropTypes.string,
      href: PropTypes.string.isRequired,
    })
  ).isRequired,
  id: PropTypes.string.isRequired,
  changeTaxonomy: PropTypes.func,
  anyTaxonomyText: PropTypes.string.isRequired,
  manageTaxonomyText: PropTypes.string.isRequired,
  anyTaxonomyURL: PropTypes.string.isRequired,
  manageTaxonomyURL: PropTypes.string.isRequired,
};

TaxonomyDropdown.defaultProps = {
  changeTaxonomy: noop,
};

export default TaxonomyDropdown;
