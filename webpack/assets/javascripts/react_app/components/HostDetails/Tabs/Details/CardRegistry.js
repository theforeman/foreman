import React from 'react';
import { addGlobalFill } from '../../../common/Fill/GlobalFill';
import Properties from '../Details/Cards/SystemProperties';
import OperatingSystem from '../Details/Cards/OperatingSystem';
import Bios from '../Details/Cards/Bios';
import NetworkingInterfaces from '../Details/Cards/NetworkingInterfaces';
import TemplatesCard from '../Details/Cards/TemplatesCard';
import ProvisioningCard from '../Details/Cards/Provisioning';

const cards = [
  { key: '[core] System properties', Component: Properties, weight: 4000 },
  { key: '[core] Operating systems', Component: OperatingSystem, weight: 3000 },
  { key: '[core] Provisioning', Component: ProvisioningCard, weight: 2900 },
  { key: '[core] BIOS', Component: Bios, weight: 2000 },
  {
    key: '[core] Templates',
    Component: TemplatesCard,
    weight: 200,
  },
  {
    key: '[core] Network interfaces',
    Component: NetworkingInterfaces,
    weight: 100,
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
