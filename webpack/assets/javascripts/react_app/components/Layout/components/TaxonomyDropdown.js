import React, { useReducer } from 'react';
import PropTypes from 'prop-types';
import NavItem from './NavItem';
import { foremanUrl, noop } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';

const TaxonomyDropdown = ({
  taxonomyType,
  currentTaxonomy,
  taxonomies,
  changeTaxonomy,
}) => {
  const [filteredTaxonomies, setSearch] = useReducer(
    (_, searchValue) =>
      taxonomies.filter(item =>
        item.title.toLowerCase().includes(searchValue.toLowerCase())
      ),
    taxonomies
  );

  const id = `${taxonomyType}-dropdown`;
  const anyTaxonomyURL = foremanUrl(`/${taxonomyType}s/clear`);
  const manageTaxonomyURL = foremanUrl(`/${taxonomyType}s`);
  const anyTaxonomyText =
    taxonomyType === 'organization'
      ? __('Any Organization')
      : __('Any Location');

  return (
    <NavItem className="dropdown org-switcher" id={id}>
      <a
        href="#"
        className="dropdown-toggle nav-item-iconic"
        data-toggle="dropdown"
      >
        {currentTaxonomy || anyTaxonomyText}
        <span className="caret" />
      </a>
      <ul className="dropdown-menu">
        <li className="dropdown-header">{__(taxonomyType)}</li>
        <li>
          <a
            className={`${taxonomyType}s_clear`}
            href={anyTaxonomyURL}
            onClick={() => {
              changeTaxonomy({ title: anyTaxonomyText });
            }}
          >
            {__(anyTaxonomyText)}
          </a>
        </li>
        <li>
          <a className={taxonomyType} href={manageTaxonomyURL}>
            {taxonomyType === 'organization'
              ? __('Manage Organizations')
              : __('Manage Locations')}
          </a>
        </li>
        <li className="divider" />
        {taxonomies.length > 6 && (
          <li>
            <input
              type="text"
              className="form-control taxonomy_search"
              id={`search_taxonomy_${taxonomyType}`}
              placeholder="Filter ..."
              onChange={e => {
                setSearch(e.target.value);
              }}
            />
          </li>
        )}
        {filteredTaxonomies.map((taxonomy, i) => (
          <li key={i}>
            <a
              className={`${taxonomyType}_menuitem`}
              id={`select_taxonomy_${taxonomy.title}`}
              href={taxonomy.href}
              onClick={() => {
                changeTaxonomy({ title: taxonomy.title, id: taxonomy.id });
              }}
            >
              {taxonomy.title}
            </a>
          </li>
        ))}
      </ul>
    </NavItem>
  );
};

TaxonomyDropdown.propTypes = {
  taxonomyType: PropTypes.string.isRequired,
  currentTaxonomy: PropTypes.string,
  taxonomies: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      title: PropTypes.string,
      href: PropTypes.string.isRequired,
    })
  ).isRequired,
  changeTaxonomy: PropTypes.func,
};

TaxonomyDropdown.defaultProps = {
  changeTaxonomy: noop,
  currentTaxonomy: undefined,
};

export default TaxonomyDropdown;
