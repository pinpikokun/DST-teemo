local CharacterSpecific = Class(function(self, inst)
    self.inst = inst

    self.character = nil
    self.storable = false
    self.comment = "That does not belong to me."
end)

function CharacterSpecific:SetOwner(name)
    self.character = name
end

function CharacterSpecific:IsStorable()
	return self.storable
end

function CharacterSpecific:SetStorable(value)
	self.storable = value
end

function CharacterSpecific:GetComment()
	return self.comment
end

function CharacterSpecific:SetComment(comment)
	self.comment = comment
end

return CharacterSpecific