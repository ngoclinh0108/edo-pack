local version = _VERSION:match("%d+%.%d+")
package.path = ("./?.lua;./?/init.lua;modules/share/lua/%s/?.lua;modules/share/lua/%s/?/init.lua;%s")
  :format(version, version, package.path)
package.cpath = ("modules/lib/lua/%s/?.dll;%s"):format(version, package.cpath)