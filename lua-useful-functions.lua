local function debugElementParents(element)
  while element ~= nil do
    game.print(element.name)
    element = element.parent
  end
end
