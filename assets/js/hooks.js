let Hooks = {
  Login: {
    mounted() {
      this.handleEvent("token-created", (event) => {
        document.cookie = "session=" + event.token
        window.location.reload()
      });

      this.handleEvent("token-destroyed", (event) => {
        document.cookie = "session="
        window.location.reload()
      })
    }
  }
};

export { Hooks };