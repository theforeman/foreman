import { toastType, toastTitle } from '../helpers'

const shortMessage = 'short message';
const longMessage = 'This is long message. Long, long, long, long, long, long, long, long, long, long, long. Too long.'

describe('toastType', () => {
  it('with type in AlertVariant', () => {
    expect(toastType('success')).toEqual('success');
  });

  it('with fallback type', () => {
    expect(toastType('alert')).toEqual('warning');
    expect(toastType('notice')).toEqual('info');
    expect(toastType('error')).toEqual('danger');
  });

  it('with invalid type', () => {
    expect(toastType('invalid')).toEqual('default');
  });
});

describe('toastTitle', () => {
  it('short message', () => {
    expect(toastTitle(shortMessage)).toEqual(shortMessage);
  });

  it('long message', () => {
    expect(toastTitle(longMessage, 'error')).toEqual('Error');
    expect(toastTitle(longMessage, 'warning')).toEqual('Warning');
    expect(toastTitle(longMessage, 'success')).toEqual('Success');
    expect(toastTitle(longMessage, 'info')).toEqual('Info');
  });
});
