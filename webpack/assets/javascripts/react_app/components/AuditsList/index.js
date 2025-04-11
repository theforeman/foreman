import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  DataList,
  DataListItem,
  DataListItemRow,
  DataListCell,
  DataListAction,
  DataListToggle,
  DataListContent,
  DataListItemCells,
  Grid,
} from '@patternfly/react-core';
import ShowInlineRequestUuid from './ShowInlineRequestUuid';
import SearchLink from './SearchLink';
import ShowOrgsLocs from './ShowOrgsLocs';
import ActionLinks from './ActionLinks';
import ExpansiveView from './ExpansiveView';
import UserDetails from './UserDetails';
import { translate as __ } from '../../common/I18n';
import ShortDateTime from '../common/dates/ShortDateTime';
import './audit.scss';

const isAuditLogin = auditedChanges => {
  let name;
  try {
    [name] = Object.keys(auditedChanges);
  } catch (e) {
    name = '';
  }
  return name === 'last_login_on';
};

const renderAdditionalInfoItems = items =>
  items && items.map((item, index) => <span key={index}>{item}</span>);

const renderTimestamp = date => (
  <span className="gray-text">
    <ShortDateTime
      date={date}
      defaultValue={__('N/A')}
      showRelativeTimeTooltip
    />
  </span>
);

const renderResourceLink = (auditTitle, auditTitleUrl, id) => {
  if (auditTitleUrl) {
    return (
      <SearchLink
        url={auditTitleUrl}
        textValue={auditTitle}
        title={__('Filter audits for this resource only')}
        id={id}
      />
    );
  }
  return auditTitle;
};

const AuditsList = ({ data: { audits }, fetchAndPush }) => {
  const [expandedRow, setExpandedRow] = useState([]);
  const isExpanded = id => expandedRow.includes(id);
  const newToggle = id => {
    const otherExpanded = expandedRow.filter(arrIds => arrIds !== id);
    return isExpanded(id)
      ? setExpandedRow(otherExpanded)
      : setExpandedRow([...otherExpanded, id]);
  };

  return (
    <DataList aria-label="Audits data list" id="audit-list" isCompact>
      {audits.map(
        ({
          id,
          created_at: createdAt,
          audited_type_name: auditedTypeName,
          audit_title: auditTitle,
          audit_title_url: auditTitleUrl,
          audited_changes: auditedChanges,
          user_info: userInfo,
          remote_address: remoteAddress,
          action_display_name: actionDisplayName,
          affected_organizations: affectedOrganizations,
          affected_locations: affectedLocations,
          allowed_actions: allowedActions,
          request_uuid: requestUuid,
          comment,
          audited_changes_with_id_to_label: auditedChangesWithIdToLabel,
          details,
        }) => (
          <DataListItem
            id={id}
            key={id}
            className={`audits-data-list ${
              remoteAddress
                ? 'main-info-minimize-padding'
                : 'main-info-maximize-padding'
            }`}
            isExpanded={isExpanded(id)}
          >
            <DataListItemRow
              onClick={() => newToggle(id)}
              className="audits-list-item-row"
            >
              <DataListToggle
                onClick={() => newToggle(id)}
                isExpanded={isExpanded(id)}
              />
              <DataListItemCells
                dataListCells={[
                  <DataListCell key="primary" width={3}>
                    <UserDetails
                      isAuditLogin={isAuditLogin(auditedChanges)}
                      userInfo={userInfo}
                      remoteAddress={remoteAddress}
                    />
                  </DataListCell>,
                  <DataListCell key="secondary" width={1}>
                    {actionDisplayName}
                  </DataListCell>,
                  <DataListCell
                    key="third"
                    className="additional-info-item item-name"
                    width={3}
                    alignRight
                  >
                    {renderAdditionalInfoItems([auditedTypeName.toUpperCase()])}
                  </DataListCell>,
                  <DataListCell
                    key="fourth"
                    className="additional-info-item item-resource"
                    width={5}
                    wrapModifier="truncate"
                  >
                    {renderAdditionalInfoItems([
                      renderResourceLink(auditTitle, auditTitleUrl, id),
                    ])}
                  </DataListCell>,
                ]}
              />
              <DataListAction className="audits-list-actions">
                {renderTimestamp(createdAt)}
              </DataListAction>
            </DataListItemRow>
            <DataListContent
              isHidden={!isExpanded(id)}
              className="data-list-content"
            >
              <Grid>
                <ActionLinks allowedActions={allowedActions} />
                <ShowOrgsLocs
                  orgs={affectedOrganizations}
                  locs={affectedLocations}
                />
                <ShowInlineRequestUuid
                  fetchAndPush={fetchAndPush}
                  requestUuid={requestUuid}
                  id={id}
                />
                <ExpansiveView
                  {...{
                    actionDisplayName,
                    details,
                    comment,
                    auditTitle,
                    auditedChanges,
                    auditedChangesWithIdToLabel,
                  }}
                />
              </Grid>
            </DataListContent>
          </DataListItem>
        )
      )}
    </DataList>
  );
};
AuditsList.propTypes = {
  data: PropTypes.shape({
    audits: PropTypes.array.isRequired,
  }).isRequired,
  fetchAndPush: PropTypes.func.isRequired,
};

export default AuditsList;
