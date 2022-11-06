import ApplicationController from 'controllers/application_controller';

export default class extends ApplicationController {
  static targets = ['input'];

  copy() {
    const copyText = this.inputTarget;
    copyText.select();
    copyText.setSelectionRange(0, 99999); /* For mobile devices */
    document.execCommand('copy');
  }
}
