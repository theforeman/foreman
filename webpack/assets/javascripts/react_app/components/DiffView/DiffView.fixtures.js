import { noop } from '../../common/helpers';

export const diffMock = {
  oldText: 'hello friend',
  newText: 'hello there friend',
  viewType: 'split',
};

export const radioMock = {
  stateView: 'split',
  changeState: noop,
};

export const patchMock = {
  viewType: 'unified',
  patch: '\n---',
};
