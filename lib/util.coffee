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

  satisfyDependencies: (autoRun = false) ->
    meta = require "../package.json"

    if autoRun is true
          require("./ga").sendEvent "util", "Satisfy Dependencies (auto)"
        else
          require("./ga").sendEvent "util", "Satisfy Dependencies (manual)"

    require("atom-package-deps").install(meta.name, true)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

  which: ->
    { platform } = require "os"

    if platform() is "win32"
      return "where"

    return "which"