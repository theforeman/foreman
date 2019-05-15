import React from 'react';
import { DndProvider } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';

import OrderableSelect from './OrderableSelect';

export default (props) => (
  <DndProvider backend={HTML5Backend}>
    <OrderableSelect {...props} />
  </DndProvider>
);
