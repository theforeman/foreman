import React from 'react';
import PropTypes from 'prop-types';
import { ListView, Row } from 'patternfly-react';
import SearchLink from './SearchLink';
import ShowOrgsLocs from './ShowOrgsLocs';
import ActionLinks from './ActionLinks';
import ExpansiveView from './ExpansiveView';
import UserDetails from './UserDetails';
import { translate as __ } from '../../common/I18n';
import './audit.scss';

const isAuditLogin = (auditedChanges) => {
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
    <ListView.InfoItem key={index}>
      {item}
    </ListView.InfoItem>
  ));

const renderTimestamp = ({ title, value: formattedTimeString }) =>
  <span title={title} className='gray-text'>{formattedTimeString}</span>;

const renderResourceLink = (auditTitle, auditTitleUrl, id) => {
  if (auditTitleUrl) {
    return (
     <SearchLink url={auditTitleUrl} textValue={auditTitle}
              title={__('Filter audits for this resource only')} id={id}></SearchLink>
    );
  }
  return auditTitle;
};

const AuditsList = ({ data: { audits, isOrgEnabled, isLocEnabled } }) => (
  <ListView>
    {audits.map(({
        id,
        creation_time: creationTime,
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
      }, index) => (
      <ListView.Item id={id} key={id}
        className={remoteAddress ? 'main-info-minimize-padding' : 'main-info-maximize-padding' }
        actions={renderTimestamp(creationTime)}
        additionalInfo={
          renderAdditionalInfoItems([
            auditedTypeName.toUpperCase(),
            renderResourceLink(auditTitle, auditTitleUrl, id)])
        }
        heading={
          <UserDetails isAuditLogin={isAuditLogin(auditedChanges)}
            userInfo={userInfo} remoteAddress={remoteAddress} />
        }
        description={description(actionDisplayName)}
        stacked={false}
        hideCloseIcon={true}
      >
        <Row>
          <ShowOrgsLocs isOrgEnabled={isOrgEnabled} isLocEnabled={isLocEnabled}
            orgs={affectedOrganizations} locs={affectedLocations} />
          <ActionLinks allowedActions={allowedActions}/>
        </Row>

        <ExpansiveView {...{
          actionDisplayName,
          details,
          comment,
          auditTitle,
          auditedChanges,
          auditedChangesWithIdToLabel,
        }} />
      </ListView.Item>
    ))}
  </ListView>
);

AuditsList.propTypes = {
  data: PropTypes.shape({
    audits: PropTypes.array.isRequired,
    isOrgEnabled: PropTypes.bool,
    isLocEnabled: PropTypes.bool,
  }).isRequired,
};

export default AuditsList;
