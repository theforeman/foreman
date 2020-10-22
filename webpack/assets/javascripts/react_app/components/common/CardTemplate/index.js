import React from 'react';
import CardItem from './CardItem';

import { addGlobalFill } from '../../common/Fill/GlobalFill';

const CardTemplate = ({ content, header, slotID, cardID }) => {
  addGlobalFill(
    slotID,
    cardID,
    <CardItem content={content} header={header} />,
    200
  );
};

export default CardTemplate;
