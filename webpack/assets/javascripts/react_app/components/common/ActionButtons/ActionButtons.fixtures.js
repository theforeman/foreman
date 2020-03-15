import { noop } from '../../../common/helpers';

export const buttons = [
  { title: 'first', action: { onClick: noop } },
  { title: 'second', action: { href: 'some-url2', 'data-method': 'put' } },
  { title: 'third', action: { onClick: noop } },
];
