XPTemplate priority=personal

XPTvar $BRloop      '\n'

XPT do wrap " do { .. } while ( .. )
do`$BRloop^{
    `cursor^
} while`$SPcmd^(`$SParg^`condition^`$SParg^);
