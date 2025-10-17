import { noop } from '../../../common/helpers';

export const buttons = [
  { title: 'first', action: { id: 1, onClick: noop } },
  { title: 'second', action: { id: 2, href: 'some-url2', 'data-method': 'put' } },
  { title: 'third', action: { id: 3, onClick: noop } },
  { title: 'fourth', action: { id: 4, onClick: noop, disabled: true } },
];
