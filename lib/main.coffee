{ satisfyDependencies } = "atom-satisfy-dependencies"

module.exports =
  config:
    pathToISCC:
      title: "Path To ISCC"
      description: "Specify the full path to `ISCC.exe`"
      type: "string"
      default: ""
      order: 0
    alwaysShowOutput:
      title: "Always Show Output"
      description: "Displays compiler output in console panel. When deactivated, it will only show on errors"
      type: "boolean"
      default: true
      order: 1
    showBuildNotifications:
      title: "Show Build Notifications"
      description: "Displays color-coded notifications that close automatically after 5 seconds"
      type: "boolean"
      default: true
      order: 2
    clearConsole:
      title: "Clear Console"
      description: "When `console-panel` isn't available, build logs will be printed using `console.log()`. This setting clears the console prior to building."
      type: "boolean"
      default: true
      order: 3
    buildOnWine:
      title: "Build on Wine"
      description: "*Experimental* &mdash; When not on Windows, `ISCC.exe` will be launched in Wine. For better error detection, you might have to tweak `WINEDEBUG`."
      type: "boolean"
      default: true
      order: 4
    manageDependencies:
      title: "Manage Dependencies"
      description: "When enabled, third-party dependencies will be installed automatically"
      type: "boolean"
      default: true
      order: 5
  subscriptions: null

  activate: (state) ->
    { CompositeDisposable } = require "atom"
    { buildScript } = require "./iscc"
    { openSettings } = require "./util"
    meta = require "../package.json"

    # Events subscribed to in atom"s system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add "atom-workspace", "inno-setup:save-&-compile": => buildScript(@consolePanel)
    @subscriptions.add atom.commands.add "atom-workspace", "inno-setup:open-package-settings": -> openSettings()
    @subscriptions.add atom.commands.add "atom-workspace", "inno-setup:satisfy-package-dependencies": -> satisfyDependencies()

    satisfyDependencies() if atom.config.get("#{meta.name}.manageDependencies") is true

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  consumeConsolePanel: (@consolePanel) ->
