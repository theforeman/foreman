import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useSelector } from 'react-redux';
import { asMutable } from 'seamless-immutable';
import classNames from 'classnames';
import {
  Card,
  CardHeader,
  CardExpandableContent,
  Grid,
  GridItem,
} from '@patternfly/react-core';
import GlobalStatusIcon from './GlobalStatusIcon';
import { sprintf, translate as __ } from '../../../common/I18n';
import Details from './Details';
import LinkOrLabel from './LinkOrLabel';
import {
  selectGlobalStatus,
  selectHostStatusDetails,
  selectHostStatusDescription,
  selectHostStatusCounter,
  selectHostStatusTotalPaths,
  selectHostStatusOwnedPaths,
} from '../HostStatusesSelectors';

import './Status.scss';

const Status = ({ name }) => {
  const [expanded, setExpanded] = useState(false);

  const globalStatus = useSelector(state => selectGlobalStatus(state, name));
  const details = useSelector(state => selectHostStatusDetails(state, name));
  const description = useSelector(state =>
    selectHostStatusDescription(state, name)
  );
  const { okTotalPath, warnTotalPath, errorTotalPath } = useSelector(state =>
    selectHostStatusTotalPaths(state, name)
  );
  const { okOwnedPath, warnOwnedPath, errorOwnedPath } = useSelector(state =>
    selectHostStatusOwnedPaths(state, name)
  );

  const {
    unknown: { total: unknownTotalCount, owned: unknownOwnedCount },
    ok: { total: okTotalCount, owned: okOwnedCount },
    warn: { total: warnTotalCount, owned: warnOwnedCount },
    error: { total: errorTotalCount, owned: errorOwnedCount },
  } = useSelector(state => selectHostStatusCounter(state, name));

  const cardClass = classNames('pf-c-alert', {
    'pf-m-danger': errorTotalCount,
    'pf-m-warning': !errorTotalCount && warnTotalCount,
    'pf-m-success': !errorTotalCount && !warnTotalCount,
  });

  const unknownStatusesPresent = !!unknownTotalCount || !!unknownOwnedCount;

  return (
    <GridItem sm={12} xl2={6}>
      <Card className={cardClass} isExpanded={expanded} isHoverable>
        <CardHeader
          onExpand={(_event, _id) => setExpanded(!expanded)}
          toggleButtonProps={{
            id: 'toggle-button',
            'aria-label': 'Details',
            'aria-labelledby': 'titleId toggle-button',
            'aria-expanded': expanded,
          }}
        >
          <Grid className="w-100" hasGutter>
            <GridItem span={1} rowSpan={2} style={{ fontSize: '2.2em' }}>
              <GlobalStatusIcon status={globalStatus} />
            </GridItem>
            <GridItem
              span={unknownStatusesPresent ? 3 : 5}
              style={{ fontSize: '1.5em' }}
            >
              {name}
            </GridItem>
            {unknownStatusesPresent && (
              <GridItem
                span={2}
                rowSpan={2}
                className="status-count text-center"
              >
                <div style={{ fontSize: '1.5em' }}>
                  <GlobalStatusIcon />
                </div>
                <LinkOrLabel
                  label={sprintf(__('Total: %s'), unknownTotalCount)}
                />
                <LinkOrLabel
                  label={sprintf(__('Owned: %s'), unknownOwnedCount)}
                />
              </GridItem>
            )}
            <GridItem span={2} rowSpan={2} className="status-count text-center">
              <div style={{ fontSize: '1.5em' }}>
                <GlobalStatusIcon status={0} />
              </div>
              <LinkOrLabel
                path={okTotalPath}
                label={sprintf(__('Total: %s'), okTotalCount)}
              />
              <LinkOrLabel
                path={okOwnedPath}
                label={sprintf(__('Owned: %s'), okOwnedCount)}
              />
            </GridItem>
            <GridItem span={2} rowSpan={2} className="status-count text-center">
              <div style={{ fontSize: '1.5em' }}>
                <GlobalStatusIcon status={1} />
              </div>
              <LinkOrLabel
                path={warnTotalPath}
                label={sprintf(__('Total: %s'), warnTotalCount)}
              />
              <LinkOrLabel
                path={warnOwnedPath}
                label={sprintf(__('Owned: %s'), warnOwnedCount)}
              />
            </GridItem>
            <GridItem span={2} rowSpan={2} className="status-count text-center">
              <div style={{ fontSize: '1.5em' }}>
                <GlobalStatusIcon status={2} />
              </div>
              <LinkOrLabel
                path={errorTotalPath}
                label={sprintf(__('Total: %s'), errorTotalCount)}
              />
              <LinkOrLabel
                path={errorOwnedPath}
                label={sprintf(__('Owned: %s'), errorOwnedCount)}
              />
            </GridItem>
            <GridItem span={5}>{description}</GridItem>
          </Grid>
        </CardHeader>
        <CardExpandableContent>
          {details.length > 0 ? (
            <Details data={asMutable(details)} />
          ) : (
            __('Nothing to show')
          )}
        </CardExpandableContent>
      </Card>
    </GridItem>
  );
};

Status.propTypes = {
  name: PropTypes.string.isRequired,
};

export default Status;
