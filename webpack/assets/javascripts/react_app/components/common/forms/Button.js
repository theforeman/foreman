import React from 'react';

export default ({
  className,
  onClick,
  children,
  type = 'button',
  disabled = false,
}) => {
  const _className = `btn ${className}`;

  return (
    <button
      disabled={disabled}
      onClick={onClick}
      type={type}
      className={_className}
    >
      {children}
    </button>
  );
};
