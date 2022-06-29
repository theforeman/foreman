/* eslint-disable camelcase */
import React, { useEffect, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';
import { Grid, GridItem } from '@patternfly/react-core';
import URI from 'urijs';
import SearchBar from '../../../SearchBar';
import Pagination from '../../../Pagination';
import { get } from '../../../../redux/API';
import {
  selectAPIStatus,
  selectAPIResponse,
  selectAPIErrorMessage,
} from '../../../../redux/API/APISelectors';
import { useForemanSettings } from '../../../../Root/Context/ForemanContext';
import ReportsTable from './ReportsTable';
import { getControllerSearchProps } from '../../../../constants';

const ReportsTab = ({ hostName, origin }) => {
  const dispatch = useDispatch();
  const history = useHistory();
  const API_KEY = `get-reports-${hostName}`;
  const { reports, itemCount } = useSelector(state =>
    selectAPIResponse(state, API_KEY)
  );
  const { perPage: settingsPerPage = 20 } = useForemanSettings() || {};
  const status = useSelector(state => selectAPIStatus(state, API_KEY));
  const error = useSelector(state => selectAPIErrorMessage(state, API_KEY));

  const fetchReports = useCallback(
    ({ search: searchParam, per_page: perPageParam, page: pageParam } = {}) => {
      if (!hostName) return;
      const {
        page: urlPage,
        perPage: urlPerPage,
        search: urlSearch,
      } = getUrlParams();
      const search = searchParam !== undefined ? searchParam : urlSearch;
      const page = pageParam || urlPage;
      const per_page = perPageParam || urlPerPage;
      dispatch(
        get({
          key: API_KEY,
          url: '/config_reports',
          params: {
            page,
            per_page,
            search: getServerQuery(search),
          },
        })
      );
      updateUrl({ page, per_page, search });
    },
    [API_KEY, dispatch, getServerQuery, getUrlParams, updateUrl, hostName]
  );

  useEffect(() => {
    fetchReports();
  }, [fetchReports, history.location]);

  const onPaginationChange = ({ page, per_page }) => {
    const { search } = getUrlParams();
    updateUrl({ page, per_page, search });
  };

  const getServerQuery = useCallback(
    search => {
      const serverQuery = [`host = ${hostName}`];
      if (origin) {
        serverQuery.push(`origin = ${origin}`);
      }
      if (search) {
        serverQuery.push(`(${search})`);
      }
      return serverQuery.join(' AND ');
    },
    [origin, hostName]
  );

  const getUrlParams = useCallback(() => {
    const params = { page: 1, perPage: settingsPerPage, search: '' };
    const urlSearch = history.location?.search;
    const urlParams = urlSearch && new URLSearchParams(urlSearch);
    if (urlParams) {
      params.search = urlParams.get('search') || params.search;
      params.page = Number(urlParams.get('page')) || params.page;
      params.perPage = Number(urlParams.get('per_page')) || params.perPage;
    }
    return params;
  }, [history.location, settingsPerPage]);

  const updateUrl = useCallback(
    ({ page, per_page, search = '' }) => {
      const uri = new URI();
      uri.search({ page, per_page, search });
      history.push({ search: uri.search() });
    },
    [history]
  );

  return (
    <Grid id="new_host_details_insights_tab" hasGutter style={{ padding: 24 }}>
      <GridItem span={6}>
        <SearchBar
          data={{
            ...getControllerSearchProps('/config_reports'),
            controller: 'config_reports',
          }}
          onSearch={search => fetchReports({ search, page: 1 })}
          onBookmarkClick={search => fetchReports({ search, page: 1 })}
          initialQuery={getUrlParams().search}
        />
      </GridItem>
      <GridItem span={6}>
        <Pagination
          variant="top"
          itemCount={itemCount}
          onChange={onPaginationChange}
        />
      </GridItem>
      <GridItem>
        <ReportsTable
          reports={reports}
          status={status}
          error={error}
          origin={origin}
          fetchReports={fetchReports}
        />
      </GridItem>
      <GridItem>
        <Pagination
          variant="bottom"
          itemCount={itemCount}
          onChange={onPaginationChange}
        />
      </GridItem>
    </Grid>
  );
};

ReportsTab.propTypes = {
  hostName: PropTypes.string,
  origin: PropTypes.string,
};

ReportsTab.defaultProps = {
  origin: null,
  hostName: null,
};

export default ReportsTab;
