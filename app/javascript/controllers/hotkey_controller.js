import ApplicationController from 'controllers/application_controller';
import { install, uninstall } from '@github/hotkey';

// https://github.com/github/hotkey#usage

export default class extends ApplicationController {
  static targets = ['shortcut'];

  initialize() {
    if (this.hasShortcutTarget) {
      this.shortcutTarget.innerHTML = this.shortcutTarget.textContent.replace('Control+', '^');
    }
  }

  connect() {
    if (this.disabled) return;
    install(this.element);
  }

  disconnect() {
    uninstall(this.element);
  }

  get disabled() {
    return document.body.hasAttribute('data-hotkeys-disabled');
  }
}
