import { createRoot } from 'react-dom/client';
import './MountingService';

jest.mock('react-dom/client', () => ({
  createRoot: jest.fn(() => ({
    render: jest.fn(),
    unmount: jest.fn(),
  })),
}));

jest.mock('./AwaitedMount', () => ({
  AwaitedMount: () => null,
}));

jest.mock('../redux/reducers/registerReducer', () => ({
  __esModule: true,
  default: jest.fn(),
}));

const rootFor = element => {
  const index = createRoot.mock.calls.findIndex(([node]) => node === element);
  return createRoot.mock.results[index].value;
};

describe('foreman-react-component', () => {
  beforeEach(() => {
    document.body.innerHTML = '';
    createRoot.mockClear();
  });

  const appendComponent = () => {
    const element = document.createElement('foreman-react-component');
    element.setAttribute('name', 'SomeComponent');
    element.setAttribute('data-props', '{}');
    document.body.appendChild(element);
    return element;
  };

  it('keeps the root when the element is moved in the DOM', async () => {
    const element = appendComponent();
    const root = rootFor(element);
    const nextParent = document.createElement('div');
    document.body.appendChild(nextParent);

    nextParent.appendChild(element);
    await Promise.resolve();

    expect(root.unmount).not.toHaveBeenCalled();
    expect(createRoot).toHaveBeenCalledTimes(1);
  });

  it('unmounts after the element is removed', async () => {
    const element = appendComponent();
    const root = rootFor(element);

    element.remove();
    expect(root.unmount).not.toHaveBeenCalled();

    await Promise.resolve();

    expect(root.unmount).toHaveBeenCalledTimes(1);
  });
});
