import { copyToClipboard } from './clipboard';

describe('copyToClipboard', () => {
  beforeEach(() => {
    document.execCommand = jest.fn();
  });

  afterEach(() => {
    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: undefined,
    });
  });

  it('uses the Clipboard API when available', async () => {
    const writeText = jest.fn().mockResolvedValue();
    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: { writeText },
    });

    await copyToClipboard(undefined, 'registration command');

    expect(writeText).toHaveBeenCalledWith('registration command');
    expect(document.execCommand).not.toHaveBeenCalled();
  });

  it('falls back when the Clipboard API is unavailable', async () => {
    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: undefined,
    });

    await copyToClipboard(undefined, 'registration command');

    expect(document.execCommand).toHaveBeenCalledWith('copy');
    expect(document.querySelector('textarea')).toBeNull();
  });

  it('falls back when writing to the Clipboard API is rejected', async () => {
    const writeText = jest.fn().mockRejectedValue(new Error('Not allowed'));
    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: { writeText },
    });

    await copyToClipboard(undefined, 'registration command');

    expect(document.execCommand).toHaveBeenCalledWith('copy');
  });
});
