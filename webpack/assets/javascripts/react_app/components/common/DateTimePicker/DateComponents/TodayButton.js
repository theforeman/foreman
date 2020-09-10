import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';

const TodayButton = ({ setSelected }) => (
  <table className="table-condensed">
    <tbody>
      <tr>
        <td>
          <button
            type="button"
            className="today-button"
            onClick={() => {
              if (setSelected) setSelected(new Date());
            }}
          >
            <span className="today-button-">{__('Today')}</span>
          </button>
        </td>
      </tr>
    </tbody>
  </table>
);

TodayButton.propTypes = {
  setSelected: PropTypes.func,
};

TodayButton.defaultProps = {
  setSelected: null,
};
export default TodayButton;
