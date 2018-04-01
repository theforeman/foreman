export const ResourcesProps = {
  resources: [
    { caption: 'Host 1', url: '#' },
    { caption: 'Host 2', url: '#' },
    { caption: 'Host 3 with a very long name', url: '#' },
    { caption: 'Host 4', url: undefined, onClick: jest.fn() },
    { caption: 'Host 5', url: '#', onClick: undefined },
  ],
};
