module.exports = Iscc =
  buildScript: (consolePanel) ->
    { spawn } = require "child_process"
    { platform } = require "os"
    meta = require "../package.json"

    require("./ga").sendEvent "main", "Save & Compile",

    editor = atom.workspace.getActiveTextEditor()

    unless editor?
      atom.notifications.addWarning("**#{meta.name}**: No active editor", dismissable: false)
      return

    script = editor.getPath()
    scope  = editor.getGrammar().scopeName

    if script? and scope.startsWith "source.inno"
      { getPath } = require "./util"

      editor.save().then ->
        getPath (pathToISCC) ->
          if not pathToISCC
            notification = atom.notifications.addWarning(
              "**#{meta.name}**: No valid `ISCC.exe` was specified in your settings",
              dismissable: true,
              buttons: [
                {
                  text: "Open Settings"
                  onDidClick: ->
                    atom.workspace.open("atom://config/packages/#{meta.name}", {pending: true, searchAllPanes: true})
                    notification.dismiss()
                }
              ]
            )
            return

          try
            consolePanel.clear()
          catch
            console.clear() if atom.config.get("language-innosetup.clearConsole")

          if platform() isnt "win32" and atom.config.get("language-innosetup.buildOnWine") is true
            iscc = spawn "wine", [pathToISCC, script]
          else if atom.config.get("language-innosetup.buildOnWine") is true
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