local RequestGate = Class(function(self, clock, timeout)
    self.clock = clock or GetTime
    self.timeout = timeout or 4
    self.pending_at = nil
    self.disposed = false
end)

function RequestGate:IsPending()
    if self.pending_at == nil then
        return false
    end
    if self.clock() - self.pending_at >= self.timeout then
        self.pending_at = nil
        return false
    end
    return true
end

function RequestGate:Try(send)
    if self.disposed or self:IsPending() then
        return false
    end
    self.pending_at = self.clock()
    send()
    return true
end

function RequestGate:Acknowledge()
    self.pending_at = nil
end

function RequestGate:Dispose()
    self.disposed = true
    self.pending_at = nil
end

return RequestGate
