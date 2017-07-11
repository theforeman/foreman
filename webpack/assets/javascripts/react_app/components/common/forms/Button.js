import React from 'react';

export default ({ className, onClick, children, disabled = false }) => {
  const _className = `btn ${className}`;

  return (
    <button disabled={disabled} onClick={onClick} type="button" className={_className}>
      {children}
    </button>
  );
};
