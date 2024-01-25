import { createContext } from 'react';
import forceSingleton from '../../common/forceSingleton';

// creating context in a separate file to avoid circular imports
export default forceSingleton('ForemanModalContext', () => createContext(null));
