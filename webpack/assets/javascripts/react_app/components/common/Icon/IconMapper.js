import React from 'react';
import {
  BookmarkIcon,
  BookIcon,
  UsersIcon,
  BuildingIcon,
  PlusCircleIcon,
  ListIcon,
  GlobeIcon,
  TableIcon,
  TasksIcon,
  LightbulbIcon,
  FileIcon,
  KeyIcon,
  ObjectGroupIcon,
  CubesIcon,
  NetworkIcon,
  InfoCircleIcon,
  CogIcon,
  EnterpriseIcon,
  LockIcon,
  GavelIcon,
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
  ThIcon,
} from '@patternfly/react-icons';

/**
 * Maps legacy icon names (from FontAwesome/PatternFly 3) to PatternFly 5 icon components
 */
export const iconMapper = iconName => {
  if (!iconName || typeof iconName !== 'string') return <PlusCircleIcon />;

  switch (iconName) {
    // foreman
    case 'bookmark':
      return <BookmarkIcon />;
    case 'book':
      return <BookIcon />;
    case 'file-text':
      return <FileIcon />;
    case 'project':
      return <UsersIcon />;
    case 'object-group':
      return <ObjectGroupIcon />;
    case 'building':
      return <BuildingIcon />;
    case 'globe':
      return <GlobeIcon />;
    case 'sitemap': // eslint-disable-line spellcheck/spell-checker
      return <NetworkIcon />;
    case 'cubes':
      return <CubesIcon />;
    case 'table':
      return <TableIcon />;
    case 'list-ul':
    case 'list-alt':
      return <ListIcon />;
    case 'tasks':
      return <TasksIcon />;
    case 'key':
      return <KeyIcon />;
    case 'lightbulb-o': // eslint-disable-line spellcheck/spell-checker
      return <LightbulbIcon />;
    case 'error-circle-o':
      return <ExclamationCircleIcon />;
    // foreman_puppet
    case 'info-circle':
      return <InfoCircleIcon />;
    case 'th':
      return <ThIcon />;
    // katello
    case 'enterprise':
      return <EnterpriseIcon />;
    // templates
    case 'exclamation-triangle':
      return <ExclamationTriangleIcon />;
    case 'lock':
      return <LockIcon />;
    // foreman_plugin_template
    case 'add-circle-o':
      return <PlusCircleIcon />;
    // foreman_statistics
    case 'info':
      return <InfoCircleIcon />;
    // foreman_discovery
    case 'gavel':
      return <GavelIcon />;
    case 'gears':
      return <CogIcon />;

    default:
      // eslint-disable-next-line no-console
      console.warn(
        `IconMapper: Unknown icon name "${iconName}". Please add mapping in IconMapper.js`
      );
      return <PlusCircleIcon />;
  }
};

export default iconMapper;
