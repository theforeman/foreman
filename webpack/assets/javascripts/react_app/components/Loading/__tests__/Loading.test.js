import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import Loading from '../Loading';

const loadingText = 'Loading';
const iconLabel = /loading icon/i;

test('Loading icon and text show by default', () => {
  const { getByText, getByLabelText } = render(<Loading />);

  expect(getByText(loadingText)).toBeInTheDocument();
  expect(getByLabelText(iconLabel)).toBeInTheDocument();
});

test('Text and icon size can be specified and component renders', () => {
  const { getByText, getByLabelText } = render(
    <Loading textSize="sm" iconSize="sm" />
  );

  expect(getByText(loadingText)).toBeInTheDocument();
  expect(getByLabelText(iconLabel)).toBeInTheDocument();
});

test('Loading text will not show when showText is false', () => {
  const { queryByText, getByLabelText } = render(<Loading showText={false} />);

  expect(queryByText(loadingText)).not.toBeInTheDocument();
  expect(getByLabelText(iconLabel)).toBeInTheDocument();
});
