import React from 'react';
import { addGlobalFill } from '../../../common/Fill/GlobalFill';
import AuditCard from '../../Audits';
import DetailsCard from '../../DetailsCard';
import AggregateStatus from '../../Status/AggregateStatusCard';

const cards = [
  { key: '[core]-detail-card', Component: DetailsCard, weight: 4000 },
  { key: '[core]-status-card', Component: AggregateStatus, weight: 3500 },
  { key: '[core]-audit-card', Component: AuditCard, weight: 3000 },
];

export const registerCoreCards = () => {
  cards.forEach(({ key, Component, weight }) => {
    addGlobalFill('details-cards', key, <Component key={key} />, weight);
  });
};
