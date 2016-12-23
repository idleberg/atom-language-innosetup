meta = require '../package.json'

# Dependencies
{spawn} = require 'child_process'
os = require 'os'

if os.platform() is 'win32'
  which  = "where"
else
  which  = "which"

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
    manageDependencies:
      title: "Manage Dependencies"
      description: "When enabled, this will automatically install third-party dependencies"
      type: "boolean"
      default: true
      order: 4
  subscriptions: null

  activate: (state) ->
    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'inno-setup:save-&-compile': => @buildScript(@consolePanel)
    @subscriptions.add atom.commands.add 'atom-workspace', 'inno-setup:setup-package-dependencies': => @setupPackageDeps()

    if atom.config.get('language-innosetup.manageDependencies')
      @setupPackageDeps()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  setupPackageDeps: () ->
    require('atom-package-deps').install(meta.name)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

  consumeConsolePanel: (@consolePanel) ->

  buildScript: (consolePanel) ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**language-innosetup**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.inno'
      editor.save() if editor.isModified()

      pathToISCC = atom.config.get('language-innosetup.pathToISCC')
      if not pathToISCC
        return atom.notifications.addError("**language-innosetup**: no valid `ISCC.exe` was specified in your config", dismissable: false)

      try
        consolePanel.clear()
      catch
        console.clear() if atom.config.get('language-innosetup.clearConsole')

      iscc = spawn pathToISCC, [script]

      iscc.stdout.on 'data', ( data ) ->
        try
          consolePanel.log(data.toString()) if atom.config.get('language-innosetup.alwaysShowOutput')
        catch
          console.log(data.toString())

      iscc.stderr.on 'data', ( data ) ->
        try
          consolePanel.error(data.toString())
        catch
          console.error(data.toString())

      iscc.on 'close', ( errorCode ) ->
        if errorCode > 0
          return atom.notifications.addError("Compile Error", dismissable: false) if atom.config.get('language-innosetup.showBuildNotifications')

        return atom.notifications.addSuccess("Compiled successfully", dismissable: false) if atom.config.get('language-innosetup.showBuildNotifications')
    else
      # Something went wrong
      atom.beep()
