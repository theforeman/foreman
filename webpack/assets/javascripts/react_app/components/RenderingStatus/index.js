import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { get, max } from 'lodash';
import {
  Grid,
  GridItem,
  DataList,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
} from '@patternfly/react-core';
import {
  Table,
  TableHeader,
  TableBody,
  TableVariant,
} from '@patternfly/react-table';
import StatusIcon from './StatusIcon';
import { translate as __ } from '../../common/I18n';
import RelativeDateTime from '../../components/common/dates/RelativeDateTime';

const RenderingStatus = ({
  renderingStatus: {
    safemodeStatus,
    unsafemodeStatus,
    label,
    host: { name: hostName },
    combinations: { edges: combinations },
  },
  settings,
}) => {
  const isSafemodeEnabled = get(settings, 'edges[0].node.value') === 'true';

  const columns = [
    __('Template'),
    __('Updated at'),
    __('Safe mode status'),
    ...(isSafemodeEnabled ? [] : [__('Unsafe mode status')]),
  ];

  const rows = combinations.map(
    ({
      node: {
        updatedAt,
        safemodeStatus: safemodeCombinationStatus,
        unsafemodeStatus: unsafemodeCombinationStatus,
        template: { name: templateName, path: templatePath },
      },
    }) => ({
      cells: [
        {
          title: <a href={templatePath}>{templateName}</a> 
        },
        {
          title: <RelativeDateTime date={updatedAt} defaultValue="N/A" />,
        },
        {
          title: <StatusIcon status={safemodeCombinationStatus} />,
        },
        ...(isSafemodeEnabled
          ? []
          : [{ title: <StatusIcon status={unsafemodeCombinationStatus} /> }]),
      ],
    })
  );

  return (
    <Grid hasGutter>
      <GridItem span={12} lg={8} xl={4}>
        <DataList>
          <DataListItem>
            <DataListItemRow>
              <DataListItemCells
                dataListCells={[
                  <DataListCell key={1}>{__('Status')}</DataListCell>,
                  <DataListCell key={2}>
                    <StatusIcon
                      status={max([safemodeStatus, unsafemodeStatus])}
                    />
                    {label}
                  </DataListCell>,
                ]}
              />
            </DataListItemRow>
            {!isSafemodeEnabled && (
              <Fragment>
                <DataListItemRow>
                  <DataListItemCells
                    dataListCells={[
                      <DataListCell key={1}>
                        {__('Safe mode status')}
                      </DataListCell>,
                      <DataListCell key={2}>
                        <StatusIcon status={safemodeStatus} />
                      </DataListCell>,
                    ]}
                  />
                </DataListItemRow>
                <DataListItemRow>
                  <DataListItemCells
                    dataListCells={[
                      <DataListCell key={1}>
                        {__('Unsafe mode status')}
                      </DataListCell>,
                      <DataListCell key={2}>
                        <StatusIcon status={unsafemodeStatus} />
                      </DataListCell>,
                    ]}
                  />
                </DataListItemRow>
              </Fragment>
            )}
          </DataListItem>
        </DataList>
      </GridItem>
      <GridItem span={12} xl={8} xl2={6}>
        <Table
          aria-label={__('Rendering Combinations')}
          cells={columns}
          rows={rows}
          variant={TableVariant.compact}
          borders={false}
        >
          <TableHeader />
          <TableBody />
        </Table>
      </GridItem>
    </Grid>
  );
};

RenderingStatus.propTypes = {
  renderingStatus: PropTypes.shape({
    safemodeStatus: PropTypes.number,
    unsafemodeStatus: PropTypes.number,
    label: PropTypes.string.isRequired,
    host: PropTypes.shape({
      name: PropTypes.string.isRequired,
    }).isRequired,
    combinations: PropTypes.shape({
      edges: PropTypes.arrayOf(
        PropTypes.shape({
          node: PropTypes.shape({
            updatedAt: PropTypes.string,
            safemodeStatus: PropTypes.number,
            unsafemodeStatus: PropTypes.number,
            template: PropTypes.shape({
              name: PropTypes.string.isRequired,
              path: PropTypes.string.isRequired,
            }).isRequired,
          }).isRequired,
        })
      ).isRequired,
    }).isRequired,
  }).isRequired,
  settings: PropTypes.shape({
    edges: PropTypes.arrayOf(
      PropTypes.shape({
        node: PropTypes.shape({
          value: PropTypes.string.isRequired,
        }),
      })
    ),
  }).isRequired,
};

export default RenderingStatus;
