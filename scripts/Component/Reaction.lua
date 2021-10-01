local Reaction = {}

function Reaction.react(unit, condition, reaction)
    if condition then
        if type(reaction) ~= "function" then
            reaction = unit[reaction]
        end

        if type(reaction) == "function" then
            return reaction(unit)
        end
    end
end

return Reaction