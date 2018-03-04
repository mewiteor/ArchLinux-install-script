XPTemplate priority=personal

XPTvar $BRif    '\n'
XPTvar $BRel    '\n'

XPT ifn  alias=if	" if ($NULL == ..) {..} else...
XSET condition=Embed('`$NULL^`$SPop^==`$SPop^`a^')

XPT ifnn alias=if	" if ($NULL != ..) {..} else...
XSET condition=Embed('`$NULL^`$SPop^!=`$SPop^`a^')

XPT if0  alias=if	" if (0 == ..) {..} else...
XSET condition=Embed('0`$SPop^==`$SPop^`a^')

XPT ifn0 alias=if	" if (0 != ..) {..} else...
XSET condition=Embed('0`$SPop^!=`$SPop^`a^')
