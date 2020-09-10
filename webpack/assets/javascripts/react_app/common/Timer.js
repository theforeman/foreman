class Timer {
  constructor(func, delay) {
    this.timer = null;
    this.delay = delay;
    this.execute = func;
  }

  startTimer() {
    this.clearTimer();

    this.timer = setTimeout(this.execute, this.delay);
  }
  clearTimer() {
    if (this.timer) {
      clearTimeout(this.timer);
    }
  }
}

export default Timer;
