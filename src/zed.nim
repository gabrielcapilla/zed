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
        echo "Directory deleted: ", item
      else:
        removeFile(item)
        echo "File deleted: ", item
    except OSError:
      echo "Error deleting item: ", item

proc main() =
  let currentDir: string = getCurrentDir()
  let selectedItems: seq[string] = fzfSelect(currentDir)
  if selectedItems.len > 0:
    echo "Selected items:"
    for item in selectedItems:
      echo "👉 ", item
    echo "\nDo you want to delete these items? (y/n)"
    let response: string = readLine(stdin)
    if response.toLowerAscii() == "y":
      deleteItems(selectedItems)
    else:
      echo "Items not deleted."
  else:
    echo "No items selected."

main()
