import { noop } from '../../../common/helpers';

export const diffModalMock = {
  diff: '\n---',
  isOpen: true,
  toggleModal: noop,
  changeViewType: noop,
  title: 'log1',
  diffViewType: 'split',
};
