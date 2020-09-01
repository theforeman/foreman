import React, { useState } from 'react';
import { Grid, Dropdown, MenuItem, Button } from 'patternfly-react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../common/I18n';
import {
  UNIT_NEVER,
  UNIT_HOURS,
  UNIT_DAYS,
  UNIT_WEEKS,
  UNIT_MONTHS,
} from '../UserJwtConstants';

const UserJwtForm = ({ handleSubmit }) => {
  const expirationUnits = [
    { label: __('Never'), value: UNIT_NEVER },
    { label: __('Hours'), value: UNIT_HOURS },
    { label: __('Days'), value: UNIT_DAYS },
    { label: __('Weeks'), value: UNIT_WEEKS },
    { label: __('Months'), value: UNIT_MONTHS },
  ];

  const [expirationUnit, setExpirationUnit] = useState(expirationUnits[0]);
  const [expirationValue, setExpirationValue] = useState('');

  const changeUnit = u => {
    if (u.value === UNIT_NEVER) {
      setExpirationValue('');
    }
    setExpirationUnit(u);
  };

  return (
    <React.Fragment>
      <Grid.Row>
        <Grid.Col md={8}>
          <label className="control-label col-md-2">{__('Expiration')}</label>
          <div className="user-jwt-form">
            <div className="input-group user-jwt-expiration">
              <input
                type="number"
                className="jwt-expiration-value form-control"
                min={1}
                disabled={expirationUnit.value === UNIT_NEVER}
                value={expirationValue}
                placeholder={__('Expire in')}
                onChange={e => setExpirationValue(e.target.value)}
              />
              <div className="input-group-btn">
                <Dropdown id="expiration_unit">
                  <Dropdown.Toggle>{expirationUnit.label}</Dropdown.Toggle>
                  <Dropdown.Menu id="settings-dropdown">
                    {expirationUnits.map(unit => (
                      <MenuItem
                        key={unit.value}
                        onClick={() => changeUnit(unit)}
                      >
                        {unit.label}
                      </MenuItem>
                    ))}
                  </Dropdown.Menu>
                </Dropdown>
                <Button
                  bsStyle="success"
                  onClick={() => handleSubmit(expirationUnit, expirationValue)}
                >
                  {__('Generate')}
                </Button>
              </div>
            </div>
          </div>
        </Grid.Col>
      </Grid.Row>
    </React.Fragment>
  );
};

UserJwtForm.propTypes = {
  handleSubmit: PropTypes.func.isRequired,
};

export default UserJwtForm;
