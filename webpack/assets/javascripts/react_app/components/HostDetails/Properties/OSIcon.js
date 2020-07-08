import PropTypes from 'prop-types';
import React, { useCallback, useState, useEffect } from 'react';

const OsIcon = ({ os, family }) => {
  const [image, setImage] = useState(null);
  const fileName = useCallback(() => {
    switch (true) {
      case /fedora/i.test(os):
        return 'fedora';
      case /ubuntu/i.test(os):
        return 'ubuntu';
      case /solaris|sunos/i.test(os):
        return 'stub/steelblue-s';
      case /darwin/i.test(os):
        return 'stub/darkred-d';
      case /centos/i.test(os):
        return 'centos';
      case /scientific/i.test(os):
        return 'scientific';
      case /archlinux/i.test(os):
        return 'archlinux';
      case /altlinux/i.test(os):
        return 'stub/goldenrod-a';
      case /gentoo/i.test(os):
        return 'gentoo';
      case /SLC/i.test(os):
        return 'stub/blue-s';
      case /FreeBSD/i.test(os):
        return 'freebsd';
      case /aix/i.test(os):
        return 'stub/forestgreen-a"';
      case /VRP/i.test(os):
        return 'stub/firebrick-h';
      case /Junos/i.test(os):
        return 'stub/darkblue-j';
      case /OracleLinux/i.test(os):
        return 'stub/firebrick-o';
      case /CoreOS|ContainerLinux|Container Linux/i.test(os):
        return 'coreos';
      case /Flatcar/i.test(os):
        return 'stub/darkblue-f';
      case /RancherOS/i.test(os):
        return 'rancheros';
      case /NXOS/i.test(os):
        return 'stub/darkslateblue-n';
      case /XenServer/i.test(os):
        return 'stub/black-x';
      case /Puppet/i.test(os):
        return 'stub/goldenrod-p';
      case /Windows/i.test(os):
        return 'stub/steelblue-w';
      default:
        if (!family || !family.length) return 'stub/black-x';
        return family.toLowerCase();
    }
  }, [os, family]);

  useEffect(() => {
    const file = fileName();
    const loadImage = async () => {
      const loaded = await import(
        `../../../../../images/icons16x16/${file}.png`
      );
      setImage(loaded.default);
    };
    loadImage();
  }, [os, fileName]);

  if (!os) return null;
  return <img height="16" width="16" alt="os-icon" src={image} />;
};

export default OsIcon;

OsIcon.propTypes = {
  family: PropTypes.string,
  os: PropTypes.string,
};
OsIcon.defaultProps = {
  family: '',
  os: '',
};
