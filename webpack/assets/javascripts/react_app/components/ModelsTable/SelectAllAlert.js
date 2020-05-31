import React from 'react';
import PropTypes from 'prop-types';
import { Alert, Button } from 'patternfly-react';
import { sprintf, translate as __ } from '../../common/I18n';

export const SelectAllAlert = ({
  itemCount,
  perPage,
  selectAllRows,
  unselectAllRows,
  allRowsSelected,
}) => {
  const selectAllText = (
    <React.Fragment>
      {sprintf(
        'All %s models on this page are selected',
        Math.min(itemCount, perPage)
      )}
      <Button bsStyle="link" onClick={selectAllRows}>
        {__('Select All')}
        <b> {itemCount} </b> {__('models.')}
      </Button>
    </React.Fragment>
  );
  const undoSelectText = (
    <React.Fragment>
      {sprintf(__(`All %s models are selected. `), itemCount)}
      <Button bsStyle="link" onClick={unselectAllRows}>
        {__('Undo selection')}
      </Button>
    </React.Fragment>
  );
  const selectAlertText = allRowsSelected ? undoSelectText : selectAllText;
  return <Alert type="info">{selectAlertText}</Alert>;
};

SelectAllAlert.propTypes = {
  allRowsSelected: PropTypes.bool.isRequired,
  itemCount: PropTypes.number.isRequired,
  perPage: PropTypes.number.isRequired,
  selectAllRows: PropTypes.func.isRequired,
  unselectAllRows: PropTypes.func.isRequired,
};
