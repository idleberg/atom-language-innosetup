meta = require "../package.json"

# Dependencies
{ spawn } = require "child_process"
{ platform } = require "os"

module.exports = InnoSetupCore =
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
    useWine:
      title: "Use Wine"
      description: "When not on Windows, `ISCC.exe` will be launched in Wine. For better error detection, you might have to tweak `WINEDEBUG`."
      type: "boolean"
      default: false
      order: 4
    manageDependencies:
      title: "Manage Dependencies"
      description: "When enabled, third-party dependencies will be installed automatically"
      type: "boolean"
      default: true
      order: 5
  subscriptions: null

  activate: (state) ->
    {CompositeDisposable} = require "atom"

    # Events subscribed to in atom"s system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add "atom-workspace", "inno-setup:save-&-compile": => @buildScript(@consolePanel)
    @subscriptions.add atom.commands.add "atom-workspace", "inno-setup:satisfy-package-dependencies": => @satisfyDependencies()

    if atom.config.get("language-innosetup.manageDependencies")
      @satisfyDependencies()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  satisfyDependencies: () ->
    require("atom-package-deps").install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

  consumeConsolePanel: (@consolePanel) ->

  buildScript: (consolePanel) ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**#{meta.name}**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith "source.inno"
      editor.save() if editor.isModified()

      @getPath (pathToISCC) ->
        if not pathToISCC
          notification = atom.notifications.addWarning(
            "**#{meta.name}**: No valid `ISCC.exe` was specified in your settings",
            dismissable: true,
            buttons: [
              {
                text: "Open Settings"
                onDidClick: ->
                  atom.workspace.open("atom://config/packages/#{meta.name}")
                  notification.dismiss()
              }
            ]
          )
          return

        try
          consolePanel.clear()
        catch
          console.clear() if atom.config.get("language-innosetup.clearConsole")

        if platform() isnt "win32" and atom.config.get("language-innosetup.useWine") is true
          iscc = spawn "wine", [pathToISCC, script]
        else if atom.config.get("language-innosetup.useWine") is true
          iscc = spawn pathToISCC, [script]

        iscc.stdout.on "data", ( data ) ->
          try
            consolePanel.log(data.toString()) if atom.config.get("language-innosetup.alwaysShowOutput")
          catch
            console.log(data.toString())

        iscc.stderr.on "data", ( data ) ->
          try
            consolePanel.error(data.toString())
          catch
            console.error(data.toString())

        iscc.on "close", ( errorCode ) ->
          if errorCode > 0
            return atom.notifications.addError("Compile Error", dismissable: false) if atom.config.get("language-innosetup.showBuildNotifications")

          return atom.notifications.addSuccess("Compiled successfully", dismissable: false) if atom.config.get("language-innosetup.showBuildNotifications")
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    # If stored, return pathToISCC
    pathToISCC = atom.config.get("language-innosetup.pathToISCC")
    if pathToISCC.length > 0
      return callback(pathToISCC)

    if platform() isnt "win32" and atom.config.get("language-innosetup.useWine") is true
      which = spawn "wine", ["where", "ISCC"]
    else
      which = spawn @which(), ["ISCC"]

    which.stdout.on "data", ( data ) ->
      path = data.toString().trim()
      atom.config.set("language-innosetup.pathToISCC", path)
      return callback(path)

    which.on "close", ( errorCode ) ->
      if errorCode > 0
        atom.notifications.addError("**#{meta.name}**: `ISCC.exe` is not in your PATH [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)

  which: ->
    if platform() is "win32"
      return "where"
    
    return "which"
