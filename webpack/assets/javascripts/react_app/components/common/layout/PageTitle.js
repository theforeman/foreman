import React from 'react';

export default ({ text }) => {
  document.title = __(text);
  return (
    <div className="row form-group">
      <h1 className="col-md-8">{ __(text) }</h1>
    </div>
  );
};
