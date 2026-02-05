

import std/os

{.define: nimpylib_has_imported_nimblefile_utils.}
proc getArgs(taskName: string): seq[string] =
  ## cmdargs: 1 2 3 4 5 -> 1 4 3 2 5
  var rargs: seq[string]
  let argn = paramCount()
  for i in countdown(argn, 0):
    let arg = paramStr i
    if arg == taskName:
      break
    rargs.add arg
  if rargs.len > 1:
    swap rargs[^1], rargs[0] # the file must be the last, others' order don't matter
  return rargs

template mytask(name: untyped, taskDesc: string, body){.dirty.} =
  task name, taskDesc:
    let taskName = astToStr(name)
    body

template taskWithArgs*(name, taskDesc, body){.dirty.} =
  bind mytask, getArgs
  mytask name, taskDesc:
    var args = getArgs taskName
    body

#XXX: due to Nim-implement limit, srcDir mixin-ed will be always `""`,
#  so I have to make it a param to be passed explicitly
template selfExecSrc*(srcPath; cmd: string; args: openArray[string]) =
  bind quoteShellCommand, `/`
  mixin srcName
  selfExec cmd & ' ' &
    quoteShellCommand(args) & ' ' & srcPath

template selfExecBuildSrc*(srcPath; cmd, outfile: string; args: openArray[string]) =
  bind selfExecSrc
  srcPath.selfExecSrc(cmd & " -o:" & outfile, args)


