import { EventEmitter } from 'events';
const CHANGE_EVENT = 'CHANGE';
const ERROR_EVENT = 'ERROR';

export default class AppEventEmitter extends EventEmitter {
  emitChange(event) {
    this.emit(CHANGE_EVENT, event);
  }

  emitError(info) {
    this.emit(ERROR_EVENT, info);
  }

  addChangeListener(callback) {
    this.on(CHANGE_EVENT, callback);
  }

  addErrorListener(callback) {
    this.on(ERROR_EVENT, callback);
  }

  removeChangeListener(callback) {
    this.removeListener(CHANGE_EVENT, callback);
  }
  removeErrorListener(callback) {
    this.removeListener(ERROR_EVENT, callback);
  }
}
