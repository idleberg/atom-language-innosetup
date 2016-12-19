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
    showBuildNotifications:
      title: "Show Build Notifications"
      type: "boolean"
      default: true
      order: 1
  subscriptions: null

  activate: (state) ->
    require('atom-package-deps').install(meta.name)

    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'inno-setup:save-&-compile': => @buildScript(@consolePanel)

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

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

      consolePanel.clear()

      iscc = spawn pathToISCC, [script]

      iscc.stdout.on 'data', ( data ) ->
        consolePanel.log(data.toString())

      iscc.stderr.on 'data', ( data ) ->
        consolePanel.error(data.toString())

      iscc.on 'close', ( errorCode ) ->
        if errorCode > 0
          return atom.notifications.addError("Compile Error", dismissable: false) if atom.config.get('language-innosetup.showBuildNotifications')

        return atom.notifications.addSuccess("Compiled successfully", dismissable: false) if atom.config.get('language-innosetup.showBuildNotifications')
    else
      # Something went wrong
      atom.beep()
