import React from 'react';
import { addGlobalFill } from '../../../common/Fill/GlobalFill';
import Properties from '../Details/Cards/SystemProperties';
import OperatingSystem from '../Details/Cards/OperatingSystem';
import TemplatesCard from '../Details/Cards/TemplatesCard';

const cards = [
  { key: '[core] System properties', Component: Properties, weight: 4000 },
  { key: '[core] Operating systems', Component: OperatingSystem, weight: 3000 },
  {
    key: '[core] Templates',
    Component: TemplatesCard,
    weight: 200,
  },
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
