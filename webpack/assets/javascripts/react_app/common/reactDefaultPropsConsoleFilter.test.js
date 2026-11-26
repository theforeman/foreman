import { handleReactDefaultPropsConsoleError } from './reactDefaultPropsConsoleFilter';

describe('handleReactDefaultPropsConsoleError', () => {
  it('suppresses a call whose own text matches and leaves the next calls alone', () => {
    expect(
      handleReactDefaultPropsConsoleError(
        'Foo: Support for defaultProps will be removed from function components in a future major release.'
      )
    ).toBe('suppress');

    expect(handleReactDefaultPropsConsoleError('real failure')).toBeNull();
    expect(handleReactDefaultPropsConsoleError('another real failure')).toBeNull();
    expect(handleReactDefaultPropsConsoleError('third real failure')).toBeNull();
  });

  it('suppresses a call when the match is in a later argument', () => {
    expect(
      handleReactDefaultPropsConsoleError(
        'Warning: %s',
        'Support for defaultProps will be removed from function components in a future major release.'
      )
    ).toBe('suppress');

    expect(handleReactDefaultPropsConsoleError('real failure')).toBeNull();
  });

  it('suppresses legacy context warnings from dependencies', () => {
    expect(
      handleReactDefaultPropsConsoleError(
        'IntlProvider uses the legacy childContextTypes API which is no longer supported.'
      )
    ).toBe('suppress');
    expect(
      handleReactDefaultPropsConsoleError(
        'Router uses the legacy contextTypes API which is no longer supported.'
      )
    ).toBe('suppress');
  });

  it('suppresses act warnings from async store updates', () => {
    expect(
      handleReactDefaultPropsConsoleError(
        'An update to Foo inside a test was not wrapped in act(...).'
      )
    ).toBe('suppress');
  });

  it('does not suppress synchronous unmount warnings', () => {
    expect(
      handleReactDefaultPropsConsoleError(
        'Attempted to synchronously unmount a root while React was already rendering.'
      )
    ).toBeNull();
  });
});
