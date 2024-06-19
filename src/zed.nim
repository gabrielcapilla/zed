import os, osproc, strutils

proc fzfSelect(currentDir: string): seq[string] =
  let fzfCmd: string = "fzf --multi --layout=reverse --header='Use <TAB> to select more than one item'"
  var items: seq[string] = @[]
  for kind, path in walkDir(currentDir):
    items.add(path)
  let itemList: string = items.join("\n")
  let (output, exitCode) = execCmdEx(fzfCmd, input = itemList)
  if exitCode == 0:
    return output.strip().splitLines()
  else:
    return @[]

proc deleteItems(items: seq[string]) =
  for item in items:
    try:
      if dirExists(item):
        removeDir(item)
        stdout.writeLine "Directory deleted: ", item
      else:
        removeFile(item)
        stdout.writeLine "File deleted: ", item
    except OSError:
      stdout.writeLine "Error deleting item: ", item

proc main() =
  let currentDir: string = getCurrentDir()
  let selectedItems: seq[string] = fzfSelect(currentDir)
  if selectedItems.len > 0:
    stdout.writeLine "Selected items:"
    for item in selectedItems:
      stdout.writeLine "👉 ", item
    stdout.write "\nDo you want to delete these items? (y/n) "
    let response: string = readLine(stdin)
    if response.toLowerAscii() == "y":
      deleteItems(selectedItems)
    else:
      stdout.write "Items not deleted."
  else:
    stdout.write "No items selected."

main()
