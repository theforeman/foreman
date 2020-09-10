import Immutable from 'seamless-immutable';

export const mapSelected = selected => selected.map(item => item.label || item);

const selectTypeAheadSelect = ({ typeAheadSelect }, id) =>
  typeAheadSelect[id] || {};

export const selectTypeAheadSelectExists = ({ typeAheadSelect }, id) =>
  !!typeAheadSelect[id];

export const selectOptions = (state, id) => {
  const typeAhead = selectTypeAheadSelect(state, id);
  const options = typeAhead.options || [];
  return Immutable.isImmutable(options) ? options.asMutable() : options;
};

export const selectSelected = (state, id) =>
  selectTypeAheadSelect(state, id).selected;
