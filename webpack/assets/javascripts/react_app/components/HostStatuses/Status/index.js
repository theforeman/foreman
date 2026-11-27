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
  Title,
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

  const cardClass = classNames('pf-v6-c-alert', {
    'pf-m-danger': errorTotalCount,
    'pf-m-warning': !errorTotalCount && warnTotalCount,
    'pf-m-success': !errorTotalCount && !warnTotalCount,
  });

  const unknownStatusesPresent = !!unknownTotalCount || !!unknownOwnedCount;

  return (
    <GridItem sm={12} xl2={6}>
      <Card ouiaId="status-card" className={cardClass} isExpanded={expanded}>
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
            <GridItem span={1} rowSpan={2}>
              {/* PF pairs icon sizes with title sizes: heading_2xl with Title xl */}
              <GlobalStatusIcon status={globalStatus} size="heading_2xl" />
            </GridItem>
            <GridItem span={unknownStatusesPresent ? 3 : 5}>
              <Title headingLevel="h2" size="xl" ouiaId="host-status-title">
                {name}
              </Title>
            </GridItem>
            {unknownStatusesPresent && (
              <GridItem
                span={2}
                rowSpan={2}
                className="status-count text-center"
              >
                <div>
                  <GlobalStatusIcon size="lg" />
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
              <div>
                <GlobalStatusIcon status={0} size="lg" />
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
              <div>
                <GlobalStatusIcon status={1} size="lg" />
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
              <div>
                <GlobalStatusIcon status={2} size="lg" />
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
