module.exports = Util =
  getPath: (callback) ->
    { spawn } = require "child_process"
    { platform } = require "os"
    meta = require "../package.json"

    # If stored, return pathToISCC
    pathToISCC = atom.config.get("language-innosetup.pathToISCC")
    if pathToISCC.length > 0
      return callback(pathToISCC)

    if platform() isnt "win32" and atom.config.get("language-innosetup.buildOnWine") is true
      which = spawn "wine", ["where", "ISCC"]
    else
      which = spawn Util.which(), ["ISCC"]

    which.stdout.on "data", ( data ) ->
      path = data.toString().trim()
      atom.config.set("language-innosetup.pathToISCC", path)
      return callback(path)

    which.on "close", ( errorCode ) ->
      if errorCode > 0
        atom.notifications.addError("**#{meta.name}**: `ISCC.exe` is not in your PATH [environmental variable](http://superuser.com/a/284351/195953)", dismissable: true)

  openSettings: ->
    meta = require "../package.json"
    require("./ga").sendEvent "util", "Open Settings"

    options =
      pending: true
      searchAllPanes: true

    atom.workspace.open("atom://config/packages/#{meta.name}", options)

  which: ->
    { platform } = require "os"

    if platform() is "win32"
      return "where"

    return "which"