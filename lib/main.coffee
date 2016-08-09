# Dependencies
{exec} = require 'child_process'
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

      @getPath (stdout) ->
        isccBin  = atom.config.get('language-innosetup.pathToISCC')
        if !isccBin?
          atom.notifications.addError("**language-innosetup**: no valid `ISCC.exe` was specified in your config", dismissable: false)
          return

        exec "\"ISCC\" \"#{script}\"", (error, stdout, stderr) ->
          if error isnt null
            # isccBin error from stdout, not error!
            atom.notifications.addError("**#{script}**", detail: error, dismissable: true)
          else
            atom.notifications.addSuccess("Compiled successfully", detail: stdout, dismissable: false)
    else
      # Something went wrong
      atom.beep()

  getPath: (callback) ->
    # If stored, return pathToISCC
    pathToISCC = atom.config.get('language-innosetup.pathToISCC')
    if pathToISCC?
      callback pathToISCC
      return

    # Find ISCC
    exec "\"#{which}\" ISCC", (error, stdout, stderr) ->
      if error isnt null
        atom.notifications.addError("**language-innosetup**: `ISCC.exe` is not in your PATH [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
      else
        atom.config.set('language-innosetup.pathToISCC', stdout.trim())
        callback stdout
      return
