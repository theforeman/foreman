import Immutable from 'seamless-immutable';

import {
  INTERFACES_INITIALIZE,
  INTERFACES_ADD_INTERFACE,
  INTERFACES_UPDATE_INTERFACE,
  INTERFACES_REMOVE_INTERFACE,
  INTERFACES_TOGGLE_INTERFACE_EDITING,
  INTERFACES_SET_PRIMARY_INTERFACE_NAME,
  INTERFACES_SET_PRIMARY_INTERFACE,
  INTERFACES_SET_PROVISION_INTERFACE,
} from '../../../consts';

const initialState = Immutable({
  interfaces: [],
  destroyed: [],
});

export default (state = initialState, { type, payload }) => {
  let data;
  switch (type) {
    case INTERFACES_INITIALIZE:
      return state.set('interfaces', payload.interfaces);
    case INTERFACES_ADD_INTERFACE:
      ({ data } = payload);
      return state.set(
        'interfaces',
        state.interfaces
          .map(i =>
            Object.assign({}, i, {
              primary: !data.primary && i.primary,
              provision: !data.provision && i.provision,
            })
          )
          .concat(data)
      );
    case INTERFACES_UPDATE_INTERFACE:
      data = payload.newValues;
      return state.set(
        'interfaces',
        state.interfaces.map(i => {
          if (i.id === payload.id) return Object.assign({}, i, data);
          return Object.assign({}, i, {
            primary: !data.primary && i.primary,
            provision: !data.provision && i.provision,
          });
        })
      );
    case INTERFACES_REMOVE_INTERFACE:
      return state.merge({
        interfaces: state.interfaces.filter(i => i.id !== payload.id),
        destroyed: [...state.destroyed, payload.id],
      });
    case INTERFACES_TOGGLE_INTERFACE_EDITING:
      return state.set(
        'interfaces',
        state.interfaces.map(i => ({ ...i, editing: i.id === payload.id && payload.flag }))
      );
    case INTERFACES_SET_PRIMARY_INTERFACE:
      return state.set(
        'interfaces',
        state.interfaces.map(i => ({ ...i, primary: i.id === payload.id }))
      );
    case INTERFACES_SET_PROVISION_INTERFACE:
      return state.set(
        'interfaces',
        state.interfaces.map(i => ({ ...i, provision: i.id === payload.id }))
      );
    case INTERFACES_SET_PRIMARY_INTERFACE_NAME:
      return state.set(
        'interfaces',
        state.interfaces.map(i =>
          i.primary ? { ...i, name: payload.newName } : i
        )
      );
    default:
      return state;
  }
};
