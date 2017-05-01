function Set(t)
   local s = {}
   for _,v in pairs(t) do s[v] = true end
   return s
end

function set_contains(t, e)
   return t[e]
end

-- The set of global shortcuts we don't want to swap cmd/alt.

global_excludes = Set{ "shift-cmd-tab",
                       "cmd-tab" ,
                       "cmd-1",
                       "cmd-2",
                       "cmd-3",
                       "cmd-4",
                       "cmd-5",
                       "cmd-6",
                       "cmd-7",
                       "cmd-8",
                       "cmd-9",
                       "cmd-space",
                       "control-cmd-1",
                       "control-cmd-2",
                       "control-cmd-3",
                       "control-cmd-4",
                       "control-cmd-5",
                       "control-cmd-6",
                       "control-cmd-7",
                       "control-cmd-8",
                       "control-cmd-9",
                      }

-- The set of apps we want to consider swapping keys for, with some
-- notable exclusions. The exclusion means that a "cmd-w" will do the
-- normal OS Terminal behaviour. If you omit items then you would
-- have to use "alt-w" to close a terminal window.

apps = {
  Terminal = { exclude = Set{} },
  iTerm = { exclude = Set{} }
}

-- Return true to swap cmd/alt, otherwise false.

-- This function is passed a table comprising the following keys:
--
--   key_str_seq	key sequence (e.g., "shift-cmd-e")
--   alt		true if the alt key was pressed
--   fn                 true if the fn key was pressed
--   control            true if the control key was pressed
--   shift              true if the shift key was pressed
--   cmd                true if the command key was pressed
--   keycode		numeric virtual keycode (e.g., 48)
--   appname            the frontmost application (e.g., Terminal)
--
-- The order of the modifier keys in key-str-eq is always:
--   shift control alt cmd fn, separated by a hyphen ("-").

function swap_keys(t)
   -- for i,v in pairs(t) do print(i,v) end
   -- print(t.appname)
   if set_contains(global_excludes, t.key_str_seq) then
      return false
   end
   if not apps[t.appname] then
      return false
   end
   local excludes = apps[t.appname]["exclude"]
   if set_contains(excludes, t.key_str_seq) then
      -- print("exluding: ", t.key_str_seq)
      return false
   end
   return true
end
