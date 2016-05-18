# Dependencies
{exec} = require 'child_process'

module.exports = InnoSetupCore =
  subscriptions: null
  debug: false
  which: null
  prefix: null

  activate: (state) ->
    {CompositeDisposable} = require 'atom'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'inno-setup:save-&-compile': => @buildScript()

  deactivate: ->
    @subscriptions.dispose()

  buildScript: ->
    editor = atom.workspace.getActiveTextEditor()
    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith 'source.inno'
      editor.save()

      @getPath (stdout) ->
        isccBin  = atom.config.get('language-inno.pathToISCC')
        if !isccBin?
          atom.notifications.addError("**language-inno**: no valid `ISCC.exe` was specified in your config", dismissable: false)
          return

        exec "\"ISCC\" \"#{script}\"", (error, stdout, stderr) ->
          if error isnt null
            # isccBin error from stdout, not error!
            atom.notifications.addError(script, detail: error, dismissable: true)
          else
            atom.notifications.addSuccess("Compiled successfully", detail: stdout, dismissable: false)
    else
      # Something went wrong
      atom.beep()
      if @debug?
        console.log "[language-inno] scope: #{scope}"

  getPath: (callback) ->
    @getPlatform()

    # If stored, return pathToISCC
    pathToISCC = atom.config.get('language-inno.pathToISCC')
    if pathToISCC?
      callback pathToISCC
      return

    # Find ISCC
    exec "\"#{@which}\" ISCC", (error, stdout, stderr) ->
      if error isnt null
        atom.notifications.addError("**language-inno**: `ISCC.exe` is not in your PATH [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)
      else
        atom.config.set('language-inno.pathToISCC', stdout.trim())
        callback stdout
      return

  getPlatform: ->
    os = require 'os'

    if os.platform() is 'win32'
      @which  = "where"
      @prefix = "/"
    else
      @which  = "which"
      @prefix = "-"
