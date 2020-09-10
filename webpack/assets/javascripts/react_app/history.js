import { createBrowserHistory } from 'history';
import forceSingleton from '../react_app/common/forceSingleton';

const history = forceSingleton('history', () => createBrowserHistory());
export default history;
