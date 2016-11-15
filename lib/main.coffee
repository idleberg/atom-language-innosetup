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
      description: "Specify the full path to `ISCC.exe`. On first compile, the package will run `#{which} ISCC` in order to detect it."
      type: "string"
      default: ""
  subscriptions: null

  activate: (state) ->
    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'inno-setup:save-&-compile': => @buildScript()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  buildScript: ->
    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**language-innosetup**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.inno'
      editor.save() if editor.isModified()

      @getPath (pathToISCC) ->
        if not pathToISCC
          atom.notifications.addError("**language-innosetup**: no valid `ISCC.exe` was specified in your config", dismissable: false)
          return

        iscc = spawn pathToISCC, [script]

        stdout = ""
        stderr = ""

        iscc.stderr.on 'data', ( data ) ->
          stderr += data

        iscc.stdout.on 'data', ( data ) ->
          stdout += data

        iscc.on 'close', ( errorCode ) ->
          if errorCode > 0
            return atom.notifications.addError("Compile Error", detail: stderr, dismissable: true)

          return atom.notifications.addSuccess("Compiled successfully", dismissable: false)
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    # If stored, return pathToISCC
    pathToISCC = atom.config.get('language-innosetup.pathToISCC')
    if pathToISCC.length > 0
      return callback(pathToISCC)

    which = spawn which, ["ISCC"]

    which.stdout.on 'data', ( data ) ->
      path = data.toString().trim()
      atom.config.set('language-innosetup.pathToISCC', path)
      return callback(path)

    which.on 'close', ( errorCode ) ->
      if errorCode > 0
        atom.notifications.addError("**language-innosetup**: `ISCC.exe` is not in your PATH [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
