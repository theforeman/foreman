import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';
import URI from 'urijs';
import classNames from 'classnames';
import {
  Pagination as PF4Pagination,
  PaginationVariant,
} from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import { useForemanSettings } from '../../Root/Context/ForemanContext';
import {
  getURIpage,
  getURIperPage,
  changeQuery,
} from '../../common/urlHelpers';
import './index.scss';

const Pagination = ({
  itemCount,
  onSetPage,
  onPerPageSelect,
  onChange,
  className,
  page: propsPage,
  perPage: propsPerPage,
  noSidePadding,
  variant,
  updateParamsByUrl,
  ...props
}) => {
  const { perPage: settingsPerPage = 20 } = useForemanSettings() || {};
  const [page, setPage] = useState(propsPage);
  const [perPage, setPerPage] = useState(propsPerPage || settingsPerPage);
  const history = useHistory();
  const { location: { search } = {} } = history || {};

  useEffect(() => {
    let nextPage = propsPage;
    let nextPerPage = propsPerPage;
    if (updateParamsByUrl) {
      if (search !== undefined) {
        const params = new URLSearchParams(search);
        nextPage = Number(params.get('page'));
        nextPerPage = Number(params.get('per_page'));
      } else {
        nextPage = getURIpage();
        nextPerPage = getURIperPage();
      }
    }
    setPerPage(current => nextPerPage || current || settingsPerPage);
    setPage(current => nextPage || current);
  }, [search, propsPage, propsPerPage, settingsPerPage, updateParamsByUrl]);

  const paginationTitles = {
    items: __('items'),
    page: '', // doesn't work well with translations as it adds 's' for plural, see: https://github.com/patternfly/patternfly-react/issues/6707
    itemsPerPage: __('Items per page'),
    perPageSuffix: __('per page'),
    toFirstPage: __('Go to first page'),
    toPreviousPage: __('Go to previous page'),
    toLastPage: __('Go to last page'),
    toNextPage: __('Go to next page'),
    optionsToggle: __('Items per page'),
    currPage: __('Current page'),
    paginationTitle: __('Pagination'),
  };

  const getPerPageOptions = () => {
    const options = new Set([5, 10, 15, 25, 50]);
    options.add(settingsPerPage);
    options.add(perPage);
    return [...options]
      .sort((a, b) => a - b)
      .map(value => ({ title: value.toString(), value }));
  };

  const _onSetPage = (e, nextPage) => {
    setPage(nextPage);
    if (onSetPage) return onSetPage(nextPage);
    const nextParams = { page: nextPage, per_page: perPage };
    if (onChange) return onChange(nextParams);
    return updateSearch(nextParams);
  };

  const _onPerPageSelect = (e, nextPerPage) => {
    setPerPage(nextPerPage);
    if (onPerPageSelect) return onPerPageSelect(nextPerPage);
    const nextParams = { per_page: nextPerPage, page: 1 };
    if (onChange) return onChange(nextParams);
    return updateSearch(nextParams);
  };

  const updateSearch = params => {
    if (!updateParamsByUrl) return;
    if (history) {
      const uri = new URI();
      uri.setSearch(params);
      history.push({ search: uri.search() });
    } else {
      changeQuery(params);
    }
  };

  const cx = classNames('tfm-pagination', className, {
    'no-side-padding': noSidePadding,
  });
  return (
    <PF4Pagination
      titles={paginationTitles}
      isCompact={variant === PaginationVariant.top}
      {...props}
      page={page}
      perPage={perPage}
      onSetPage={_onSetPage}
      onPerPageSelect={_onPerPageSelect}
      perPageOptions={getPerPageOptions()}
      data-per-page={perPage}
      data-total={itemCount}
      itemCount={itemCount}
      className={cx}
    />
  );
};

Pagination.propTypes = {
  onSetPage: PropTypes.func,
  onPerPageSelect: PropTypes.func,
  itemCount: PropTypes.number,
  className: PropTypes.string,
  page: PropTypes.number,
  perPage: PropTypes.number,
  noSidePadding: PropTypes.bool,
  variant: PropTypes.string,
  onChange: PropTypes.func,
  updateParamsByUrl: PropTypes.bool,
};

Pagination.defaultProps = {
  onSetPage: null,
  onPerPageSelect: null,
  onChange: null,
  itemCount: 0,
  className: null,
  page: 1,
  perPage: null,
  noSidePadding: false,
  variant: PaginationVariant.bottom,
  updateParamsByUrl: true,
};

export default Pagination;
