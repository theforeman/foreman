import React, { Fragment, useState } from 'react';
import PropTypes from 'prop-types';
import { useSelector } from 'react-redux';
import { asMutable } from 'seamless-immutable';
import { Pagination, Tooltip } from '@patternfly/react-core';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';
import {
  CheckCircleIcon,
  ExclamationTriangleIcon,
  ExclamationCircleIcon,
} from '@patternfly/react-icons';
import { useAPI, useForemanUrl } from '../../common/hooks/API/APIHooks';
import { useForemanSettings } from '../../Root/Context/ForemanContext';
import RelativeDateTime from '../common/dates/RelativeDateTime';
import { translate as __ } from '../../common/I18n';
import { API_OPTIONS } from './RenderStatusesConstants';
import {
  selectRenderStatuses,
  selectTotalRenderStatuses,
} from './RenderStatusesSelectors';
import Empty from './Empty';

const RenderStatuses = ({ path }) => {
  const {
    perPage: perPageSetting,
    safemode: safemodeRenderSetting,
  } = useForemanSettings();
  const [page, setPage] = useState(1);
  const [perPage, setPerPage] = useState(perPageSetting);
  const url = useForemanUrl(path, {
    page,
    per_page: perPage,
    order: 'updated_at DESC',
    ...(safemodeRenderSetting && { search: 'safemode = true' }),
  });
  const { status: responseStatus } = useAPI('get', url, API_OPTIONS);
  const renderStatuses = useSelector(state => selectRenderStatuses(state));
  const totalRenderStatuses = useSelector(state =>
    selectTotalRenderStatuses(state)
  );

  const updatePerPage = newPerPage => {
    setPerPage(newPerPage);
    setPage(1);
  };

  const columnLabels = {
    success: '',
    safemode: '',
    host_or_hostgroup: __('Host/Hostgroup'),
    created_at: __('Created at'),
    updated_at: __('Updated at'),
  };

  const columns = [
    'success',
    'host_or_hostgroup',
    'created_at',
    'updated_at',
    ...(safemodeRenderSetting ? [] : ['safemode']),
  ];
  const cells = columns.map(name => [columnLabels[name]]);

  const rows = renderStatuses.map(
    ({
      success,
      safemode,
      created_at: createdAt,
      updated_at: updatedAt,
      host,
      hostgroup,
      provisioning_template: {
        name: provisioningTemplateName,
        path: provisioningTemplatePath,
      },
    }) => {
      const values = {
        success: () =>
          success ? (
            <CheckCircleIcon
              style={{ fill: 'var(--pf-global--success-color--100)' }}
            />
          ) : (
            <ExclamationCircleIcon
              style={{ fill: 'var(--pf-global--danger-color--100)' }}
            />
          ),
        safemode: () =>
          safemode ? (
            <Fragment />
          ) : (
            <Tooltip position="right" content={__('Unsafe Mode')}>
              <ExclamationTriangleIcon
                style={{ fill: 'var(--pf-global--warning-color--100)' }}
              />
            </Tooltip>
          ),
        created_at: () => (
          <RelativeDateTime date={createdAt} defaultValue="N/A" />
        ),
        updated_at: () => (
          <RelativeDateTime date={updatedAt} defaultValue="N/A" />
        ),
        host_or_hostgroup: () => {
          const { name: hName, path: hPath } = host || hostgroup;
          return hPath ? <a href={hPath}>{hName}</a> : hName;
        },
        provisioning_template: () =>
          provisioningTemplatePath ? (
            <a href={provisioningTemplatePath}>{provisioningTemplateName}</a>
          ) : (
            <Fragment>provisioningTemplateName</Fragment>
          ),
      };

      return columns.map(name => ({ title: values[name]() }));
    }
  );

  return (
    <Fragment>
      {totalRenderStatuses ? (
        <Fragment>
          <Table
            aria-label={__('Render Statuses')}
            variant="compact"
            cells={cells}
            rows={asMutable(rows)}
            ouiaId="render-statuses-table"
          >
            <TableHeader />
            <TableBody />
          </Table>

          <Pagination
            itemCount={totalRenderStatuses}
            perPage={perPage}
            page={page}
            onSetPage={(_event, newPage) => setPage(newPage)}
            onPerPageSelect={(_event, newPerPage) => updatePerPage(newPerPage)}
            widgetId="pagination-options-menu-top"
            isCompact
            ouiaId="render-statuses-pagination"
          />
        </Fragment>
      ) : (
        <Empty responseStatus={responseStatus} />
      )}
    </Fragment>
  );
};

RenderStatuses.propTypes = {
  path: PropTypes.string.isRequired,
};

export default RenderStatuses;
