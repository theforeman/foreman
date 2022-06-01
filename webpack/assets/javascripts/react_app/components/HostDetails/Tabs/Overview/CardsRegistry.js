import React from 'react';
import { addGlobalFill } from '../../../common/Fill/GlobalFill';
import AuditCard from '../../Audits';
import DetailsCard from '../../DetailsCard';
import RecentCommunicationCard from '../../RecentCommunicationCard';
import AggregateStatus from '../../Status/AggregateStatusCard';

const cards = [
  { key: '[core]-status-card', Component: AggregateStatus, weight: 4000 },
  {
    key: '[core]-recent-comms-card',
    Component: RecentCommunicationCard,
    weight: 3800,
  },
  { key: '[core]-detail-card', Component: DetailsCard, weight: 3400 },
  { key: '[core]-audit-card', Component: AuditCard, weight: 2400 },
];

export const registerCoreCards = () => {
  cards.forEach(({ key, Component, weight }) => {
    addGlobalFill('host-overview-cards', key, <Component key={key} />, weight);
  });
};
