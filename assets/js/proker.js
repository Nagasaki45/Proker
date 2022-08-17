globalThis.openConfigurationModal = () => {
  document.getElementById("configurationModal").className = "modal is-active";
};

globalThis.closeConfigurationModal = () => {
  document.getElementById("configurationModal").className = "modal";
};
