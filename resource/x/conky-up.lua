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
    
    -- IP地址
    -- local ifaces=conky_parse("${exec \"$(ls /sys/class/net | egrep '^(eth|wlan|enp|wlp)')\"}")
    local ips = I3Bar:new(nil, "\xef\x82\xac "..conky_parse("${addr eth0}")..' / '..conky_parse("${texeci 60 curl -s icanhazip.com}"), "#b3d9ff")
    ips.name="net"
    ips.instance="net"
    ips:Print()

    -- 网速
    local upspeed = I3Bar:new(nil, string.format("\xef\x81\xb7 %5s/s %5s",conky_parse("${upspeed eth0}"),conky_parse("${totalup eth0}")),"#809fff")
    upspeed.name="netspeed"
    upspeed.instance="up"
    upspeed.min_width="\xef\x81\xb7 8.88B/s 88.8M"
    upspeed:Print()

    local downspeed = I3Bar:new(nil, string.format("\xef\x81\xb8 %5s/s %5s",conky_parse("${downspeed eth0}"),conky_parse("${totaldown eth0}")),"#809fff")
    downspeed.name="netspeed"
    downspeed.instance="down"
    downspeed.min_width="\xef\x81\xb8 8.88B/s 88.8M"
    downspeed:Print()

    -- 电池
    local battery_percent=tonumber(conky_parse("$battery_percent"))
    if battery_percent>0 then
        local bstr=""
        if battery_percent>=90 then
            bstr="\xef\x89\x80"
        elseif battery_percent>=65 then
            bstr="\xef\x89\x81"
        elseif battery_percent>=35 then
            bstr="\xef\x89\x82"
        elseif battery_percent>=10 then
            bstr="\xef\x89\x83"
        else
            bstr="\xef\x89\x84"
        end
        local battery = I3Bar:new(nil)
        battery.full_text = string.format("%s%3d%%",bstr,battery_percent)
        local battery_time = conky_parse("$battery_time")
        if #battery_time>0 then
            battery.full_text = battery.full_text..string.format(" (%10s)",battery_time)
        end
        if battery_percent>=10 then
            battery.color="#ffff66"
        else
            battery.color="#ff0022"
        end
        battery.name="battery"
        battery.instance="battery"
        battery.Print()
    end

    -- time
    local d = I3Bar:new(nil,"","#b3ff66")
    d.full_text = '\xef\x81\xb3 '..conky_parse("${time %Y-%m-%d %a}")
    d.name = "date"
    d.instance = "date"
    d:Print()

    local t = I3Bar:new(nil,"","#b3ff66")
    t.full_text = '\xef\x80\x97 '..conky_parse("${time %H:%M:%S}")
    t.name = "time"
    t.instance = "time"
    t:Print(true)

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
