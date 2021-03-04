import { noop } from '../../../common/helpers';

import { patch } from '../../DiffView/DiffView.fixtures'

export const diffModalMock = {
  diff: patch,
  isOpen: true,
  toggleModal: noop,
  changeViewType: noop,
  title: 'log1',
  diffViewType: 'split',
};
