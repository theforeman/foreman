import React from 'react';
import { addGlobalFill } from '../../../common/Fill/GlobalFill';
import Properties from '../Details/Cards/SystemProperties';

const cards = [
  { key: '[core]-properties-card', Component: Properties, weight: 4000 },
];

export const registerCoreCards = () => {
  cards.forEach(({ key, Component, weight }) => {
    addGlobalFill(
      'host-tab-details-cards',
      key,
      <Component key={key} />,
      weight
    );
  });
};
