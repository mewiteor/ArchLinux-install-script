function conky_main()
    print("[")

    -- IP地址
    print('{ "full_text" : "IP '..conky_parse("${addr enp0s10f0}")..'" , "color" : "#ffffff" },')

    -- 网速
    print(string.format('{ "full_text" : "v %5s/s %5s" , "color" : "#ffffff" },',conky_parse("${downspeed enp0s10f0}"),conky_parse("${totaldown enp0s10f0}")))
    print(string.format('{ "full_text" : "^ %5s/s %5s" , "color" : "#ffffff" },',conky_parse("${upspeed enp0s10f0}"),conky_parse("${totalup enp0s10f0}")))

    -- 电池
    battery_percent=tonumber(conky_parse("$battery_percent"))
    if battery_percent>0 then
        s=string.format('{ "full_text" : "Battery %3d%%',battery_percent)
        battery_time=conky_parse("$battery_time")
        if string.len(battery_time)>0 then
            s=s..string.format(" (%10s)",battery_time)
        end
        s=s..'" , "color" : "#ffffff" }.'
        print(s)
    end

    -- 线程与进程
    threads=conky_parse("$threads")
    running_threads=conky_parse("$running_threads")
    print('{ "full_text" : "Thread '..string.rep(' ',string.len(threads)-string.len(running_threads))..running_threads..'/'..threads..'" , "color" : "#ffffff" },')
    processes=conky_parse("$processes")
    running_processes=conky_parse("$running_processes")
    print('{ "full_text" : "Processes '..string.rep(' ',string.len(processes)-string.len(running_processes))..running_processes..'/'..processes..'" , "color" : "#ffffff" },')

    -- 文件系统
	print(conky_parse('{ "full_text" : "FS($fs_type) $fs_used(${fs_used_perc}%)/$fs_free(${fs_free_perc}%)/$fs_size"')..', "color" : "#ffffff" },')

    -- IO
    print(string.format('{ "full_text" : "IO %5s/%5s/%5s" , "color" : "#ffffff" },',conky_parse("$diskio_read"),conky_parse("$diskio_write"),conky_parse("$diskio")))

    -- CPU
    print(string.format('{ "full_text" : "CPU %sGHz%3s%%" , "color" : "#ffffff" },',conky_parse("$freq_g"),conky_parse("${cpu cpu0}")))

    -- RAM
    s='{ "full_text" : "RAM '..conky_parse("$mem($memperc%)/$memmax")..'" , "color" : "'
    memperc=tonumber(conky_parse("$memperc"))
    if memperc<90 then
        s=s.."#ffffff"
    else
        s=s.."#ff0000"
    end
    s=s..'" },'
	print(s)

    -- Swap
    s='{ "full_text" : "Swap '..conky_parse("$swap($swapperc%)/$swapmax")..'" , "color" : "'
    swapperc=tonumber(conky_parse("$swapperc"))
    if swapperc<90 then
        s=s.."#ffffff"
    else
        s=s.."#ff0000"
    end
    s=s..'" },'
	print(s)

    -- user
    -- print('{ "full_text" : "'..conky_parse("$user_names")..'" , "color" : "#ffffff" },')

    -- time
    print('{ "full_text" : "'..conky_parse("${time %Y-%m-%d %H:%M:%S %a}")..'" , "color" : "#ffffff" }')

    print("],")
    return ''
end

function center_string(str,len)
    local slen=string.len(str)
    if slen>=len then
        return str
    end
    local rsp=math.modf((len-slen)/2)
    local lsp=len-slen-rsp
    return string.rep(" ",lsp)..str..string.rep(" ",rsp)
end
