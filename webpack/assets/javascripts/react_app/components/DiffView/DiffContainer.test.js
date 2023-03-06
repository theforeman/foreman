import React from 'react';
import { render, fireEvent } from '@testing-library/react';

import DiffContainer from './DiffContainer';
import { diffMock, PF_SELECTED, DIFF_SPLIT, DIFF_UNIFIED } from './Diff.fixtures';

test('Render DiffContainer & ensure DiffToggle buttons are in the document and working', async () => {

  const { getByText, getByRole, unmount } = await render(<DiffContainer {...diffMock} />);

  // Check that the text of the buttons is presented on the page
  const splitButton = getByText(/Split/i);
  const unifiedButton = getByText(/Unified/i);

  // We need to get the container of the buttons, because only they have the attribute PF_SELECTED
  const splitButtonContainer = splitButton.parentElement;
  const unifiedButtonContainer = unifiedButton.parentElement;

  // Check that only the selected button looks selected
  expect(splitButtonContainer.classList.contains(PF_SELECTED)).toBe(true);
  expect(unifiedButtonContainer.classList.contains(PF_SELECTED)).toBe(false);


  // This code checks that the view changes apply to the code editor, and that the selected button is presented as selected,
  // as we click on the buttons "Split" & "Unified":

  // Get the table of differences & check that it has the correct className in order to present the differences in the right view
  const divOfDiffTable = getByRole('table', { name: 'diff-table' });
  const tableOfDifferences = divOfDiffTable.firstChild;
  
  expect(tableOfDifferences.classList.contains(DIFF_SPLIT)).toBe(true);
  expect(tableOfDifferences.classList.contains(DIFF_UNIFIED)).toBe(false);


  // 1. Click on button "Unified"

  fireEvent.click(unifiedButton);
  
  // Check that only the selected button looks selected
  expect(splitButtonContainer.classList.contains(PF_SELECTED)).toBe(false);
  expect(unifiedButtonContainer.classList.contains(PF_SELECTED)).toBe(true);

  // Check that the view was changed
  expect(tableOfDifferences.classList.contains(DIFF_SPLIT)).toBe(false);
  expect(tableOfDifferences.classList.contains(DIFF_UNIFIED)).toBe(true);


  // 2. Click on button "Split"

  fireEvent.click(splitButton);
  
  // Check that only the selected button looks selected
  expect(splitButtonContainer.classList.contains(PF_SELECTED)).toBe(true);
  expect(unifiedButtonContainer.classList.contains(PF_SELECTED)).toBe(false);

  // Check that the view was changed
  expect(tableOfDifferences.classList.contains(DIFF_SPLIT)).toBe(true);
  expect(tableOfDifferences.classList.contains(DIFF_UNIFIED)).toBe(false);
  

  // Unmnount the component from the DOM
  unmount();
})
