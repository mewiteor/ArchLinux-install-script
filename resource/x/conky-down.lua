I3Bar =
{
    full_text = "",
    short_text = nil,
    color = "#ffffff",
    background = nil,
    border = nil,
    min_width = nil,
    align = "left",
    name = nil,
    instance = nil,
    urgent = false,
    separator = true,
    separator_block_width = nil
}
    function I3Bar:new(o,full_text,color)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        self.full_text = full_text or ""
        self.color = color or "#ffffff"
        return o
    end

    function I3Bar:Print(ed)
        local r='{ '
        local first = true
        if type(self.full_text)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"full_text" : "'..self.full_text..'"'
        end
        if type(self.short_text)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"short_text" : "'..self.short_text..'"'
        end 
        if type(self.color)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"color" : "'..self.color..'"'
        end 
        if type(self.background)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"background" : "'..self.background..'"'
        end 
        if type(self.border)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"border" : "'..self.border..'"'
        end 
        if type(self.min_width)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"min_width" : "'..self.min_width..'"'
        elseif type(self.min_width)=="number" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"min_width" : '..self.min_width
        end 
        if type(self.align)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"align" : "'..self.align..'"'
        end 
        if type(self.name)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"name" : "'..self.name..'"'
        end 
        if type(self.instance)=="string" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"instance" : "'..self.instance..'"'
        end 
        if type(self.urgent)=="boolean" then
            if first then
                first = false
            else
                r = r..', '
            end
            if self.urgent then
                r = r..'"urgent" : true'
            else
                r = r..'"urgent" : false'
            end
        end 
        if type(self.separator)=="boolean" then
            if first then
                first = false
            else
                r = r..', '
            end
            if self.separator then
                r = r..'"separator" : true'
            else
                r = r..'"separator" : false'
            end
        end 
        if type(self.separator_block_width)=="number" then
            if first then
                first = false
            else
                r = r..', '
            end
            r = r..'"separator_block_width" : '..self.separator_block_width
        end 
        r = r..' }'
        if not ed then
            r = r..', '
        end
        print(r)
    end

function conky_main()
    print("[")
    
    --[[
    local test = I3Bar:new(nil)
    test.full_text = os.getenv("LANG")
    if not test.full_text then
        test.full_text = "nil"
    end
    test:Print()
    ]]

    -- 线程
    local t = I3Bar:new(nil,"","#b3ecff")

    local threads=conky_parse("$threads")
    local running_threads=conky_parse("$running_threads")

    t.full_text = 'Threads '..string.rep(' ',#threads-#running_threads)..running_threads..'/'..threads
    t.name="Threads"
    t.instance="Threads"
    t:Print()

    -- 进程
    local p = I3Bar:new(nil,"","#b3ecff")
    local processes=conky_parse("$processes")
    local running_processes=conky_parse("$running_processes")

    p.full_text = 'Processes '..string.rep(' ',#processes-#running_processes)..running_processes..'/'..processes
    p.name="Processes"
    p.instance="Processes"
    p:Print()

    -- 文件系统
    local fs = I3Bar:new(nil,"","#ffcccc")
    fs.full_text = conky_parse('FS($fs_type) $fs_used(${fs_used_perc}%)/$fs_free/$fs_size')
    fs.name="Fs"
    fs.instance="Fs"
    fs:Print()

    -- IO
    local fsio = I3Bar:new(nil,"","#ffcccc")
    fsio.full_text = string.format('IO %5s/%5s/%5s',conky_parse("$diskio_read"),conky_parse("$diskio_write"),conky_parse("$diskio"))
    fsio.name="Io"
    fsio.instance="Io"
    fsio:Print()

    -- CPU
    local cpu = I3Bar:new(nil,string.format("\xef\x86\xa5 %sGHz%3s%%", conky_parse("$freq_g"),conky_parse("${cpu cpu0}")),"#99ccff")
    cpu.name = "cpu"
    cpu.instance = "cpu"
    cpu:Print()

    -- RAM
    local ram = I3Bar:new(nil, "\xef\x8b\x9b "..conky_parse("$mem($memperc%)/$memmax"))
    local memperc=tonumber(conky_parse("$memperc"))
    if memperc<90 then
        ram.color="#99ffbb"
    else
        ram.color="#ff0066"
    end
    ram.name = "ram"
    ram.instance = "ram"
    ram:Print()

    -- Swap
    local swap = I3Bar:new(nil, "Swap "..conky_parse("$swap($swapperc%)/$swapmax"))
    local swapperc=tonumber(conky_parse("$swapperc"))
    if swapperc<90 then
        swap.color="#ffff99"
    else
        swap.color="#ff0066"
    end
    swap.name = "swap"
    swap.instance = "swap"
    swap:Print(true)


    print("],")
    return ''
end

function center_string(str,len)
    local slen=#str
    if slen>=len then
        return str
    end
    local rsp=math.modf((len-slen)/2)
    local lsp=len-slen-rsp
    return string.rep(" ",lsp)..str..string.rep(" ",rsp)
end
