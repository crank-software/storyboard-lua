-- This module is used to help measure string content.
Measure = {}
Measure.__index = Measure

function Measure.create(font_name, font_size, wrap_text, text)
    local l = {}
    setmetatable(l, Measure)
    
    l.font_name = font_name
    l.font_size = font_size
    l.wrap_text = wrap_text
    l.text = text or ""
    l.text_x = text_x or 0
    l.text_y = text_y or 0
    
    l.cur_x = 0
    l.cur_y = 0
    
    return l
end

function Measure:getMaxWidth()
    return self.max_x
end

function Measure:getMaxHeight()
    return self.max_y
end

function Measure:getLineCount()
    return self.line_count
end

--Initialize the values for the Measure object based on new text content
--@param target_width The width to target or nil to use the control width
function Measure:init(ctrl_width)
    local line, ret

    --Reference variable for line height, use x height
    --'line_height' was introduced in a later version of sbengine so fallback to 'X'
    ret = gre.get_string_size(self.font_name, self.font_size, "X")
    
    self.line_height = ret.line_height or ret.height
    
    self.max_y = self.line_height
    self.max_x = ret.width
    
    --Control width/height, used to limit scrolling and handle wrapping    
    local txt = self.text
    
    -- Calculate the number of lines, the max width and adjust the max line height
    self.line_count = 0
    local lines = {}
    local i = 0
    for line in string.gmatch(txt, "([^\r\n]*[\r\n]?)") do
      table.insert(lines, line)
    end
    
    for i=1, #lines do
      local line = lines[i]
    
--        print("Line: " .. tostring(self.line_count) .. " [" .. line .. "]")
        
        --If there was a newline at the end of the line, strip it out
        line = string.gsub(line, "[\r\n]", "")
--        print("Line NewLine Stripped: [" .. tostring(line) .."]")
         
        local substring = line
        local substring_length = #substring
        
        if(substring_length == 0) then            -- Newline only line, bump up the count
          if(i ~= #lines) then
              self.line_count = self.line_count + 1
          end
        else
            while(substring_length > 0) do
                --Determine the size of the string, clipped to the rect
                ret = gre.get_string_size(self.font_name, self.font_size, substring, 0, ctrl_width)
                if(ret.nchars == nil) then
                    if(ret.nbytes ~= nil) then
                        ret.nchars = ret.nbytes
                    else
                        ret.nchars = 0
                    end
                end
--                print(string.format("Substring Measure [%s] length %d vs %d", substring, ret.nchars, substring_length))
                if(self.wrap_text and ret.nchars < substring_length) then
                    --Back up and find the last space if we can and measure to that, else clip string
                    local clip_string = string.sub(substring, 1,ret.nchars)
                    local ms,me = string.find(clip_string, ".*%s")
                    local clipped_nchars = me or ret.nchars
--                    print("Clip@ " .. tostring(ret.nchars) .. " Break@ " .. tostring(clipped_nchars) .. " Line: " .. substring)
                    ret = gre.get_string_size(self.font_name, self.font_size, substring, clipped_nchars, ctrl_width)
                    if(ret.nchars == nil) then
                        if(ret.nbytes ~= nil) then
                            ret.nchars = ret.nbytes
                        else
                            ret.chars = 0
                        end
                    end
                end
            
                if(ret.width > self.max_x) then
                    self.max_x = ret.width
                end
                if(ret.height > self.max_y) then
                    self.max_y = ret.height
                end
                
                self.line_count = self.line_count + 1
    
                --If there is any kind of encoding glitch, then nchars will be 0 so bail            
                if(ret.nchars == nil or ret.nchars == 0) then
                    substring = ""
                    substring_length = 0
                else
                    substring = string.sub(substring, ret.nchars+1)
                    substring_length = #substring    
                end
            end        
        end
    end
--    self.line_count = self.line_count+1 -- so that the last text line clears the container 
  
--  print("max_y = ", self.line_count, "*", self.max_y)
    --Adjust the max_y to encompass all of the text, max_y is either line_height or max character height
    self.max_y = self.line_count * self.max_y    
end
