import {
  INTERFACES_ADD_INTERFACE,
  INTERFACES_UPDATE_INTERFACE,
} from '../../../consts';
import { defaultState, getInterfaceData } from './interfaces.fixtures';

import reducer from './index';

describe('interfaces reducer', () => {
  describe.each([['primary'], ['provision']])(
    '%s flag transering',
    flagName => {
      it('transfers on INTERFACES_ADD_INTERFACE', () => {
        const data = getInterfaceData();
        data[flagName] = true;
        const resultState = reducer(defaultState, {
          type: INTERFACES_ADD_INTERFACE,
          payload: { data },
        });
        const flagedIfces = resultState.interfaces.filter(i => i[flagName]);
        expect(flagedIfces).toHaveLength(1);
        expect(flagedIfces[0].id).toEqual(data.id);
      });

      it('transfers on INTERFACES_UPDATE_INTERFACE', () => {
        const data = getInterfaceData();
        const twoInterfaceState = defaultState.set(
          'interfaces',
          defaultState.interfaces.concat(data)
        );
        const newValues = {};
        newValues[flagName] = true;
        const resultState = reducer(twoInterfaceState, {
          type: INTERFACES_UPDATE_INTERFACE,
          payload: {
            id: data.id,
            newValues,
          },
        });
        const flagedIfces = resultState.interfaces.filter(i => i[flagName]);
        expect(flagedIfces).toHaveLength(1);
        expect(flagedIfces[0].id).toEqual(data.id);
      });
    }
  );
});
