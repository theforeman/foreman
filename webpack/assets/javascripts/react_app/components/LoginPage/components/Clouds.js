import React, { Fragment } from 'react';
import './Clouds.scss';

const Clouds = () => (
  <Fragment>
    <img
      className="small_clouds"
      src="/assets/small_clouds.png"
      alt="small clouds"
    />
    <img className="big_clouds" src="/assets/big_clouds.png" alt="big clouds" />
  </Fragment>
);

export default Clouds;
