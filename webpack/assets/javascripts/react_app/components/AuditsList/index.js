import React from 'react';
import PropTypes from 'prop-types';
import { ListView, Row } from 'patternfly-react';
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

const description = actionDisplayName => (
  <ListView.Description>
    <ListView.DescriptionText>{actionDisplayName}</ListView.DescriptionText>
  </ListView.Description>
);

const renderAdditionalInfoItems = items =>
  items &&
  items.map((item, index) => (
    <ListView.InfoItem key={index}>{item}</ListView.InfoItem>
  ));

const renderTimestamp = date => (
  <span className="gray-text">
    <ShortDateTime date={date} defaultValue={__('N/A')} />
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

const AuditsList = ({ audits }) => {
  const initExpanded = audits.length === 1;

  return (
    <div id="audit-list">
      <ListView>
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
            comment,
            audited_changes_with_id_to_label: auditedChangesWithIdToLabel,
            details,
          }) => (
            <ListView.Item
              id={id}
              key={id}
              className={
                remoteAddress
                  ? 'main-info-minimize-padding'
                  : 'main-info-maximize-padding'
              }
              actions={renderTimestamp(createdAt)}
              additionalInfo={renderAdditionalInfoItems([
                auditedTypeName.toUpperCase(),
                renderResourceLink(auditTitle, auditTitleUrl, id),
              ])}
              heading={
                <UserDetails
                  isAuditLogin={isAuditLogin(auditedChanges)}
                  userInfo={userInfo}
                  remoteAddress={remoteAddress}
                />
              }
              description={description(actionDisplayName)}
              stacked={false}
              hideCloseIcon
              initExpanded={initExpanded}
            >
              <Row>
                <ShowOrgsLocs
                  orgs={affectedOrganizations}
                  locs={affectedLocations}
                />
                <ActionLinks allowedActions={allowedActions} />
              </Row>

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
            </ListView.Item>
          )
        )}
      </ListView>
    </div>
  );
};
AuditsList.propTypes = {
  audits: PropTypes.array.isRequired,
};

export default AuditsList;
